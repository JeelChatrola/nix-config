# Zsh program configuration
# This file configures zsh with oh-my-zsh and plugins

{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Set zsh as default shell
    defaultKeymap = "emacs";
    
    # Oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "kubectl"
        "terraform"
        "aws"
        "python"
        "node"
        "npm"
        "yarn"
        "tmux"
        "sudo"
        "z"
        "extract"
        "colored-man-pages"
        "command-not-found"
        "fzf"
        "ssh-agent"
      ];
      theme = "robbyrussell";
    };
    
    # Shell options and initialization
    initExtraBeforeCompInit = ''
      # Enable useful shell options
      setopt AUTO_CD
      setopt CORRECT
      setopt CORRECT_ALL
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      # Initialize ZSH_HIGHLIGHT_HIGHLIGHTERS array
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root line)
      
      # Import aliases and environment from external file
      ${builtins.readFile ../configs/zsh-aliases.sh}
    '';
  };
}
