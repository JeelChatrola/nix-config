{
  identity,
  host,
  capabilities,
  ...
}:

{
  imports = map (name: ./capabilities/${name}.nix) capabilities;

  home.username = identity.username;
  home.homeDirectory = host.homeDirectory;
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  manual.manpages.enable = false;

  home.sessionVariables = {
    TERM = "xterm-256color";
    EDITOR = "nvim";
    SHELL = "zsh";
  };
}
