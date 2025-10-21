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
    
    # Import tmux config from external file
    extraConfig = builtins.readFile ../configs/tmux.conf;
  };
}
