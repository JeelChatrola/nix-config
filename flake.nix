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
    hermes-agent.url = "github:NousResearch/hermes-agent";
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
      packages.${system}.hermes = hermesMessaging;

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
