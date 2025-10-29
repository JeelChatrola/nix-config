# Tmux program configuration
# This file configures tmux with custom settings

{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
    
    # Tmux plugins managed by Nix
    plugins = with pkgs.tmuxPlugins; [
      sensible          # Basic tmux settings everyone can agree on
      yank              # Copy to system clipboard
      resurrect         # Save/restore tmux sessions
      continuum         # Auto-save sessions every 15min
      {
        plugin = fzf-tmux-url;  # Open URLs with fzf
        extraConfig = ''
          set -g @fzf-url-bind 'u'
        '';
      }
    ];
    
    # Import tmux config from external file
    extraConfig = builtins.readFile ../configs/tmux.conf;
  };
}
