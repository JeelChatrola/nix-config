rec {
  username = "jeel";
  homeDirectory = "/home/jeel";
  fullName = "JeelChatrola";
  email = "jeelchatrola046@gmail.com";

  repoRoot = homeDirectory;
  aiStackDir = "${repoRoot}/ai-stack";
  nixConfigDir = "${repoRoot}/nix-config";
  projectRoots = [
    "${homeDirectory}/Projects"
    "${homeDirectory}/personal_setup"
    "${homeDirectory}/Downloads"
  ];
}
