# Main home-manager configuration
# This file imports all program configurations and sets up the environment

{ config, pkgs, lib, enableAI ? false, aiConfigRoot ? null, userProfile, ... }:

{
  # =============================================================================
  # BASIC CONFIGURATION
  # =============================================================================
  home.username = userProfile.username;
  home.homeDirectory = userProfile.homeDirectory;
  # Pin stateVersion; only bump when you intend to migrate Home Manager state (see home-manager release notes).
  home.stateVersion = "26.05";

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
    ./modules/default-shell.nix
    ./programs/packages.nix
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/tmux.nix
    ./programs/ssh.nix
    ./programs/fzf.nix
    ./programs/neovim.nix
    ./programs/lf.nix
    ./programs/alacritty.nix
  ] ++ lib.optionals enableAI [
    ./programs/ai-tools.nix
  ];
}