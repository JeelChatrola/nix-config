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
      resurrect         # Prefix+Ctrl-s saves; Prefix+Ctrl-r restores
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-interval '15'
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = tmux-thumbs;
        extraConfig = ''
          set -g @thumbs-key Space
          set -g @thumbs-alphabet qwerty-homerow
          set -g @thumbs-reverse enabled
          set -g @thumbs-unique enabled
          set -g @thumbs-contrast 1
          set -g @thumbs-osc52 1
          set -g @thumbs-bg-color '#1a1b26'
          set -g @thumbs-fg-color '#9ece6a'
          set -g @thumbs-hint-bg-color '#7aa2f7'
          set -g @thumbs-hint-fg-color '#1a1b26'
          set -g @thumbs-select-bg-color '#bb9af7'
          set -g @thumbs-select-fg-color '#1a1b26'
        '';
      }
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
