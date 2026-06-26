{
  description = "Nix - For Config Management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pin: 0.17.0 hermes-web/tui npm build fails in Nix sandbox (esbuild @esbuild/linux-x64).
    hermes-agent.url = "github:NousResearch/hermes-agent/6b76284c7769e0ca80012a5a4b7e22b1cea05b6b";
  };

  outputs =
    { nixpkgs, home-manager, hermes-agent, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays/default.nix;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [ "vim-polyglot" ];
      };
      hermesMessaging = hermes-agent.packages.${system}.default.override {
        extraDependencyGroups = [ "messaging" ];
      };
      lib = nixpkgs.lib;

      mkHome = import ./home-manager/lib/mkHome.nix {
        inherit home-manager pkgs;
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
          };
          "${login}-ai" = mkHome {
            inherit userProfile;
            enableAI = true;
          };
        })
          users;
    };
}
