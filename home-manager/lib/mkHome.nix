{ home-manager, pkgs, pkgsUnstable, aiStack }:

{
  userProfile,
  enableAI ? false,
  aiConfigRoot ? null,
}:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit enableAI pkgsUnstable aiConfigRoot userProfile;
    aiStackSrc = aiStack;
  };
  modules = [
    ../home.nix
  ];
}
