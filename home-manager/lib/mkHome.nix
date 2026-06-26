{ home-manager, pkgs, pkgsUnstable }:

{
  userProfile,
  enableAI ? false,
}:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit enableAI pkgsUnstable userProfile;
  };
  modules = [
    ../home.nix
  ];
}
