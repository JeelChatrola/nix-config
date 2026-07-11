{ ... }:

{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    configFile = ../configs/gruvbox-dark-hard.omp.json;
  };
}
