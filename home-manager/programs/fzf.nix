# FZF program configuration
# This file configures fzf with useful settings

{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    # Default options
    # Gruvbox Dark color scheme
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--info=inline"
      "--border=sharp"
      "--prompt='> '"
      "--pointer=▶"
      "--marker=✓"
      "--color=fg:#ebdbb2,bg:#282828,hl:#fabd2f"
      "--color=fg+:#fbf1c7,bg+:#3c3836,hl+:#d3869b"
      "--color=info:#8ec07c,prompt:#83a598,pointer:#fb4934"
      "--color=marker:#b8bb26,spinner:#fe8019,header:#928374"
      "--color=border:#504945,label:#8ec07c,query:#ebdbb2"
    ];
    
    # File finder command
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    
    # Change directory command
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

    # Ctrl+R history widget: use a taller layout and a preview pane so that
    # long / multi-line commands render cleanly instead of wrapping and
    # overlapping with adjacent entries (the garbled "clear1520 gs1519 ..."
    # look that happens with the default 40% height).
    historyWidgetOptions = [
      "--height=90%"
      "--layout=reverse"
      "--scheme=history"
      "--tiebreak=index"
      "--preview 'echo {}'"
      "--preview-window=down:3:wrap"
      "--bind 'ctrl-/:toggle-preview'"
      "--bind 'ctrl-r:toggle-sort'"
      "--header 'Ctrl-R: toggle sort | Ctrl-/: toggle preview'"
    ];
  };
}
