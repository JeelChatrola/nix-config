{ ... }:

{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    configFile = ../configs/gruvbox-dark.omp.json;
  };
}
