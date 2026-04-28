# Main home-manager configuration
# This file imports all program configurations and sets up the environment

{ config, pkgs, lib, enableAI ? false, aiConfigRoot ? null, ... }:

let
  # Mutable checkout: default ~/nix-config (matches historical zsh-aliases). Override aiConfigRoot in flake extraSpecialArgs if needed.
  nixConfigRepo =
    if aiConfigRoot != null then aiConfigRoot else config.home.homeDirectory + "/nix-config";
  aiStackDir = nixConfigRepo + "/ai-stack";
in
{
  # =============================================================================
  # BASIC CONFIGURATION
  # =============================================================================
  home.username = "jeel";
  home.homeDirectory = "/home/jeel";
  # Pin stateVersion; only bump when you intend to migrate Home Manager state (see home-manager release notes).
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
    # ai-up / ai-proj / deploy.sh expect this repo’s ai-stack/; set from flake path at switch time.
    AI_STACK_DIR = aiStackDir;
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
