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
      lib = nixpkgs.lib;
      overlays = import ./overlays/default.nix;

      mkPkgs = system: import nixpkgs {
        inherit system overlays;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "obsidian"
            "vim-polyglot"
          ];
      };

      mkHomeFor = login: userProfile:
        let
          system = userProfile.system or "x86_64-linux";
          pkgs = mkPkgs system;
          mkHome = import ./home-manager/lib/mkHome.nix {
            inherit home-manager pkgs;
            pkgsUnstable = pkgs;
          };
        in
        {
          ${login} = mkHome {
            inherit userProfile;
            enableAI = false;
          };
          "${login}-ai" = mkHome {
            inherit userProfile;
            enableAI = true;
          };
        };

      users = {
        jeel = import ./home-manager/users/jeel.nix;
        jeel-mac = import ./home-manager/users/jeel-mac.nix;
      };

      packageSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    {
      packages = lib.genAttrs packageSystems (system:
        let
          pkgs = mkPkgs system;
        in
        lib.optionalAttrs pkgs.stdenv.isLinux {
          rtk = pkgs.rtk;
        }
      );

      homeConfigurations = lib.concatMapAttrs mkHomeFor users;
    };
}
