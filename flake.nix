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
  };

  outputs =
    { nixpkgs, home-manager, aiStack, ... }:
    let
      # system = "aarch64-linux"; If you are running on ARM powered computer
      system = "x86_64-linux";
      # Single nixpkgs pin with overlays (llmfit, etc.). pkgsUnstable in modules is the same set.
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays/default.nix;
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
