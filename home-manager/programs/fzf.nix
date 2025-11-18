# FZF program configuration
# This file configures fzf with useful settings

{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    # Default options
    # Gruvbox dark color scheme
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--info=inline"
      "--border=rounded"
      "--prompt=> "
      "--pointer=▶"
      "--marker=✓"
      "--color=fg:#ebdbb2,bg:#282828,hl:#fabd2f"
      "--color=fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f"
      "--color=info:#83a598,prompt:#b8bb26,pointer:#fb4934"
      "--color=marker:#8ec07c,spinner:#fabd2f,header:#928374"
      "--color=border:#504945,label:#a89984,query:#ebdbb2"
    ];
    
    # File finder command
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    
    # Change directory command
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };
}
