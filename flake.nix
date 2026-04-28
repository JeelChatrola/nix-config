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
  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  }: let
    # system = "aarch64-linux"; If you are running on ARM powered computer
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      overlays = import ./overlays/default.nix;
    };
  in {
    homeConfigurations = {
      jeel = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          enableAI = false;
          pkgsUnstable = pkgsUnstable;
          # If this flake lives outside ~/nix-config, set e.g. aiConfigRoot = "/path/to/nix-config";
          aiConfigRoot = null;
        };
        modules = [
          ./home-manager/home.nix
        ];
      };
      jeel-ai = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          enableAI = true;
          pkgsUnstable = pkgsUnstable;
          aiConfigRoot = null;
        };
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}


