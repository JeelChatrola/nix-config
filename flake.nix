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
    pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
  in {
    homeConfigurations = {
      jeel = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { enableAI = false; pkgsUnstable = pkgsUnstable; };
        modules = [
          ./home-manager/home.nix
        ];
      };
      jeel-ai = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { enableAI = true; pkgsUnstable = pkgsUnstable; };
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}


