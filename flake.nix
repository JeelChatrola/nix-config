{
  description = "Nix - For Config Management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aiStack = {
      url = "path:./ai-stack";
      flake = false;
    };
    # Pin: 0.17.0 hermes-web/tui npm build fails in Nix sandbox (esbuild @esbuild/linux-x64).
    hermes-agent.url = "github:NousResearch/hermes-agent/6b76284c7769e0ca80012a5a4b7e22b1cea05b6b";
  };

  outputs =
    { nixpkgs, home-manager, aiStack, hermes-agent, ... }:
    let
      # system = "aarch64-linux"; If you are running on ARM powered computer
      system = "x86_64-linux";
      # Single nixpkgs pin with overlays (llmfit, etc.). pkgsUnstable in modules is the same set.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays/default.nix;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [ "vim-polyglot" ];
      };
      # Gateway needs discord.py; upstream default Nix package is [all] only (no messaging extra).
      hermesMessaging = hermes-agent.packages.${system}.default.override {
        extraDependencyGroups = [ "messaging" ];
      };
      lib = nixpkgs.lib;

      mkHome = import ./home-manager/lib/mkHome.nix {
        inherit home-manager pkgs aiStack;
        pkgsUnstable = pkgs;
      };

      users = {
        jeel = import ./home-manager/users/jeel.nix;
      };
    in
    {
      packages.${system} = {
        hermes = hermesMessaging;
        rtk = pkgs.rtk;
      };

      apps.${system}.hermes = {
        type = "app";
        program = "${hermesMessaging}/bin/hermes";
      };

      homeConfigurations =
        lib.concatMapAttrs (login: userProfile: {
          ${login} = mkHome {
            inherit userProfile;
            enableAI = false;
            aiConfigRoot = null;
          };
          "${login}-ai" = mkHome {
            inherit userProfile;
            enableAI = true;
            aiConfigRoot = null;
          };
        })
          users;
    };
}
