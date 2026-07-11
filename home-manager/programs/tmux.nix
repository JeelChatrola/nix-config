# Tmux program configuration
# This file configures tmux with custom settings

{ config, pkgs, ... }:

let
  marmonitor = pkgs.buildNpmPackage {
    pname = "marmonitor";
    version = "0.2.6";
    src = pkgs.fetchFromGitHub {
      owner = "mjjo16";
      repo = "marmonitor";
      rev = "v0.2.6";
      hash = "sha256-Oaw8ahspeXdXEFARxkxtanfMyBaRuG5BzMtAM0CNQsY=";
    };
    npmDepsHash = "sha256-DW6R/5ISeOOyv1p/OHpSddXRNnQqKdOk99Cchn2GOq8=";
    npmFlags = [ "--ignore-scripts" ];
  };
  marmonitorTmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "marmonitor";
    version = "unstable-2026-07-10";
    src = pkgs.fetchFromGitHub {
      owner = "mjjo16";
      repo = "marmonitor-tmux";
      rev = "d13bfef026cf6787da4318a12da465532ed96713";
      hash = "sha256-1JnYCm2mLg33EwEKh+wsxPOrNka+9EzjEK9vR+FPjVo=";
    };
    rtpFilePath = "marmonitor.tmux";
  };
in
{
  home.packages = [ marmonitor ];

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
      {
        plugin = marmonitorTmux;
        extraConfig = ''
          set -g @marmonitor-format 'tmux-badges'
          set -g @marmonitor-status-line '1'
          set -g @marmonitor-interval '5'
        '';
      }
    ];
    
    # Import tmux config from external file
    extraConfig = builtins.readFile ../configs/tmux.conf;
  };

  systemd.user.services.marmonitor = {
    Unit = {
      Description = "Monitor AI coding agents for tmux";
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${marmonitor}/bin/marmonitor start";
      ExecStop = "${marmonitor}/bin/marmonitor stop";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
