{
  description = "Nix - For Config Management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      lib = nixpkgs.lib;
      overlays = import ./overlays/default.nix;
      presetLib = import ./home-manager/lib/presets.nix { inherit lib; };

      identities.jeel = import ./home-manager/identities/jeel.nix;
      hosts.main-workstation = import ./home-manager/hosts/main-workstation.nix;

      macHost = {
        name = "jeel-mac";
        system = "aarch64-darwin";
        identity = "jeel";
        homeDirectory = "/Users/jeel";
      };

      mkPkgs = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "obsidian" ];
      };

      mkHome = import ./home-manager/lib/mkHome.nix {
        inherit home-manager nixpkgs overlays;
      };

      mkHostHome = host:
        let
          identity = identities.${host.identity} or (throw "Unknown identity: ${host.identity}");
          capabilities = presetLib.resolve {
            inherit (host) preset additions removals;
          };
        in
        mkHome {
          inherit (host) system;
          profile = host.preset;
          inherit capabilities identity host;
        };

      mkMacHome = profile: capabilities: mkHome {
        inherit (macHost) system;
        inherit profile capabilities;
        identity = identities.jeel;
        host = macHost;
      };

      darwinCliCapabilities = presetLib.resolve {
        preset = "base";
        additions = [ "development" ];
      };
      darwinFallbackCapabilities = presetLib.resolve { preset = "workstation"; };
      darwinFallbackAiCapabilities = darwinFallbackCapabilities ++ [ "ai" ];

      mainWorkstationHome = mkHostHome hosts.main-workstation;
      serverHome = mkHome {
        system = "x86_64-linux";
        profile = "server";
        capabilities = presetLib.resolve { preset = "server"; };
        identity = identities.jeel;
        host = hosts.main-workstation // { homeDirectory = "/home/jeel"; };
      };
      personalHome = mkHome {
        system = "x86_64-linux";
        profile = "personal";
        capabilities = presetLib.resolve { preset = "personal"; };
        identity = identities.jeel;
        host = hosts.main-workstation;
      };
      darwinSystem = nix-darwin.lib.darwinSystem {
        specialArgs = {
          host = macHost;
          identity = identities.jeel;
        };
        modules = [
          ./darwin/hosts/jeel-mac.nix
          home-manager.darwinModules.home-manager
          ({ ... }: {
            nixpkgs = {
              inherit overlays;
              config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "obsidian" ];
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                capabilities = darwinCliCapabilities;
                profile = "darwin-cli";
                host = macHost;
                identity = identities.jeel;
              };
              users.${identities.jeel.username}.imports = [ ./home-manager/home.nix ];
            };
          })
        ];
      };
      integratedDarwinHome = darwinSystem.config.home-manager.users.${identities.jeel.username};

      packageNames = home: map lib.getName home.config.home.packages;
      hasPackages = home: names: lib.all (name: builtins.elem name (packageNames home)) names;
      lacksPackages = home: names: lib.all (name: !(builtins.elem name (packageNames home))) names;
      aiToolsSource = builtins.readFile ./home-manager/programs/ai-tools.nix;
      deploySource = builtins.readFile ./deploy.sh;
      unknownCapability = builtins.tryEval ((mkMacHome "invalid" [ "unknown" ]).activationPackage.drvPath);
      systemIsRequired = (builtins.functionArgs mkHome).system == false;

      mkCheck = system: name: conditions:
        let
          pkgs = mkPkgs system;
        in
        assert lib.all (condition: condition) conditions;
        pkgs.runCommand name { } "touch $out";
    in
    {
      lib = {
        inherit (presetLib) capabilities presets resolve;
      };

      packages = lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ] (system:
        let
          pkgs = mkPkgs system;
        in
        {
          nh = pkgs.nh;
        } // lib.optionalAttrs pkgs.stdenv.isLinux { rtk = pkgs.rtk; });

      homeConfigurations = {
        "jeel@main-workstation" = mainWorkstationHome;
        jeel-mac = mkMacHome "workstation" darwinFallbackCapabilities;
        jeel-mac-ai = mkMacHome "workstation-ai" darwinFallbackAiCapabilities;
      };

      darwinConfigurations.jeel-mac = darwinSystem;

      checks.x86_64-linux = {
        canonical-host = mkCheck "x86_64-linux" "canonical-host" [
          (mainWorkstationHome.activationPackage.drvPath != "")
          (hosts.main-workstation.system == "x86_64-linux")
          (presetLib.resolve {
            preset = "workstation";
            additions = [
              "ai"
              "base"
            ];
            removals = [ ];
          } == [
            "base"
            "desktop"
            "development"
            "containers"
            "ai"
          ])
          (!unknownCapability.success)
          systemIsRequired
          (hasPackages mainWorkstationHome [
            "opencode"
            "codex"
            "agent-browser"
          ])
          (lib.hasInfix "exec \${pkgs.opencode}/bin/opencode" aiToolsSource)
          (lib.hasInfix "exec \${pkgs.codex}/bin/codex" aiToolsSource)
          (lib.hasInfix "exec \${pkgs.agent-browser}/bin/agent-browser" aiToolsSource)
          (!(lib.hasInfix "/bin/npx" aiToolsSource))
          (!(lib.hasInfix "npx -y" aiToolsSource))
          (lib.hasInfix ''nix run "$FLAKE_PATH#nh"'' deploySource)
          (!(lib.hasInfix "nixpkgs#" deploySource))
        ];
        profile-exclusions = mkCheck "x86_64-linux" "profile-exclusions" [
          (lacksPackages serverHome [
            "firefox"
            "nerd-fonts-fira-code"
            "obsidian"
            "xclip"
          ])
          (!(serverHome.config.home.sessionVariables ? BROWSER))
          (!(serverHome.config.home.file ? ".config/ghostty/config"))
          (!serverHome.config.fonts.fontconfig.enable)
          (lacksPackages personalHome [
            "gh"
            "gcc"
            "lazydocker"
            "dive"
            "ctop"
          ])
        ];
      };

      checks.aarch64-darwin.profile-exclusions = mkCheck "aarch64-darwin" "profile-exclusions" [
        (lacksPackages { config = integratedDarwinHome; } [
          "obsidian"
          "opencode"
          "codex"
          "agent-browser"
          "llmfit"
          "nerd-fonts-fira-code"
        ])
        (!(integratedDarwinHome.home.sessionVariables ? BROWSER))
        (!(integratedDarwinHome.home.sessionVariables ? CODEX_HOME))
        (!(integratedDarwinHome.home.file ? ".config/ghostty/config"))
      ];
    };
}
