{
  home-manager,
  nixpkgs,
  overlays,
}:

{
  system,
  profile,
  capabilities,
  identity,
  host,
}:

let
  presetLib = import ./presets.nix { lib = nixpkgs.lib; };
  unknown = nixpkgs.lib.filter (name: !(builtins.elem name presetLib.capabilities)) capabilities;
  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "obsidian" ];
  };
in
if unknown != [ ] then
  throw "Unknown capabilities: ${nixpkgs.lib.concatStringsSep ", " unknown}"
else
  home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      inherit
        capabilities
        host
        identity
        profile
        ;
    };
    modules = [ ../home.nix ];
  }
