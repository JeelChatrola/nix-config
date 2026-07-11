# FZF program configuration
# This file configures fzf with useful settings

{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    # Default options
    # Tokyo Night color scheme
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--info=inline"
      "--border=rounded"
      "--prompt='> '"
      "--pointer=▶"
      "--marker=✓"
      "--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7"
      "--color=fg+:#c0caf5,bg+:#292e42,hl+:#bb9af7"
      "--color=info:#7dcfff,prompt:#7aa2f7,pointer:#f7768e"
      "--color=marker:#9ece6a,spinner:#ff9e64,header:#565f89"
      "--color=border:#3b4261,label:#7dcfff,query:#c0caf5"
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
