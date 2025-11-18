# FZF program configuration
# This file configures fzf with useful settings

{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    # Default options
    # Colors match Oh My Posh powerlevel10k_rainbow theme
    # Blue #3465a4 (path/highlights), Green #4e9a06 (prompt), Yellow #c4a000 (pointer/changes)
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--info=right"
      "--border=rounded"
      "--border-label="
      "--preview-window=border-rounded"
      "--margin=1"
      "--prompt=> "
      "--pointer=◆"
      "--marker=>"
      "--separator=─"
      "--scrollbar=│"
      "--color=fg:#e4e4e4,fg+:#ffffff,bg:#1a1a1a,bg+:#2a2a2a"
      "--color=hl:#3465a4,hl+:#5a85c4,info:#d3d7cf,marker:#c4a000"
      "--color=prompt:#4e9a06,spinner:#689f63,pointer:#c4a000,header:#888888"
      "--color=border:#3a3a3a,label:#b0b0b0,query:#e4e4e4"
    ];
    
    # File finder command
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    
    # Change directory command
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };
}
