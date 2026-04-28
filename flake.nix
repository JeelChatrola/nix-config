{
  description = "Nix - For Config Management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      # system = "aarch64-linux"; If you are running on ARM powered computer
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        overlays = import ./overlays/default.nix;
      };
      lib = nixpkgs.lib;

      mkHome = import ./home-manager/lib/mkHome.nix {
        inherit home-manager pkgs pkgsUnstable;
      };

      # One attrset entry per login name → Linux `$HOME` owner for home-manager.
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
