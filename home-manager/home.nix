# Main home-manager configuration
# This file imports all program configurations and sets up the environment

{ config, pkgs, ... }:

{
  # =============================================================================
  # BASIC CONFIGURATION
  # =============================================================================
  home.username = "jeel";
  home.homeDirectory = "/home/jeel";
  home.stateVersion = "23.05";
  
  # Enable home-manager
  programs.home-manager.enable = true;
  
  # =============================================================================
  # FONTS & DISPLAY
  # =============================================================================
  fonts.fontconfig.enable = true;
  
  # =============================================================================
  # SESSION VARIABLES
  # =============================================================================
  home.sessionVariables = {
    TERM = "xterm-256color";
    EDITOR = "nvim";
    BROWSER = "firefox";
    SHELL = "zsh";
  };
  
  # =============================================================================
  # IMPORT ALL PROGRAM CONFIGURATIONS
  # =============================================================================
  imports = [
    ./programs/packages.nix
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/tmux.nix
    ./programs/ssh.nix
    ./programs/fzf.nix
    ./programs/neovim.nix
  ];
}
