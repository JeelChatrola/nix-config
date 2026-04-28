{ home-manager, pkgs, pkgsUnstable }:

{
  userProfile,
  enableAI ? false,
  aiConfigRoot ? null,
}:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit enableAI pkgsUnstable aiConfigRoot userProfile;
  };
  modules = [
    ../home.nix
  ];
}
