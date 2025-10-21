# FZF program configuration
# This file configures fzf with useful settings

{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    # Default options
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
      "--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9"
      "--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6"
      "--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    ];
    
    # File finder command
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    
    # Change directory command
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };
}
