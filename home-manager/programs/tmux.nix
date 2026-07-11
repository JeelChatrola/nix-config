# Tmux program configuration
# This file configures tmux with custom settings

{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    clock24 = false;
    keyMode = "vi";
    mouse = true;

    # Tmux plugins managed by Nix
    plugins = with pkgs.tmuxPlugins; [
      sensible # Basic tmux settings everyone can agree on
      yank # Copy to system clipboard
      vim-tmux-navigator # Shared Ctrl+h/j/k/l movement with Neovim
      resurrect # Prefix+Ctrl-s saves; Prefix+Ctrl-r restores
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
          set -g @thumbs-bg-color '#1d2021'
          set -g @thumbs-fg-color '#98971a'
          set -g @thumbs-hint-bg-color '#83a598'
          set -g @thumbs-hint-fg-color '#1d2021'
          set -g @thumbs-select-bg-color '#d3869b'
          set -g @thumbs-select-fg-color '#1d2021'
        '';
      }
      {
        plugin = fzf-tmux-url; # Open URLs with fzf
        extraConfig = ''
          set -g @fzf-url-bind 'u'
        '';
      }
    ];

    extraConfig = builtins.readFile ../configs/tmux.conf + ''
      # tmux-cpu expands the CPU/GPU format tokens in the status bar.
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
  };
}
