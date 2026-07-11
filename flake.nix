{
  description = "Nix - For Config Management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays/default.nix;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [ "vim-polyglot" ];
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
        rtk = pkgs.rtk;
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
