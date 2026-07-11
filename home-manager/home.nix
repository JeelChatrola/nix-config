# Main home-manager configuration
# This file imports all program configurations and sets up the environment

{ config, pkgs, lib, enableAI ? false, userProfile, ... }:

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
  # Avoid the generated options.json derivation, which loses Nix store context
  # under current Nix and is not needed on this workstation.
  manual.manpages.enable = false;

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
    ./programs/starship.nix
    ./programs/neovim.nix
    ./programs/lf.nix
    ./programs/ghostty.nix
  ] ++ lib.optionals enableAI [
    ./programs/ai-tools.nix
  ];
}
