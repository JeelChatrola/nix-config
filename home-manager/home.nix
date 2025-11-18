# Main home-manager configuration
# This file imports all program configurations and sets up the environment

{ config, pkgs, lib, ... }:

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
  # CONFIG FILES
  # =============================================================================
  home.file.".config/ohmyposh/powerlevel10k_rainbow.omp.json".source = ./configs/powerlevel10k_rainbow.omp.json;
  
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
  
  # =============================================================================
  # ACTIVATION SCRIPTS
  # =============================================================================
  # Automatically set ZSH as default shell on standalone Home Manager
  # This works around the limitation that Home Manager can't modify /etc/shells
  # without root permissions. This script will prompt for sudo password when needed.
  home.activation.setDefaultShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Get the ZSH path from the Nix profile
    ZSH_PATH="${config.home.homeDirectory}/.nix-profile/bin/zsh"
    
    # Ensure we have access to system binaries
    export PATH="/usr/bin:/bin:$PATH"
    
    # Check if zsh is already the default shell
    # Use /etc/passwd directly as getent might not be available in all environments
    CURRENT_SHELL=$(grep "^${config.home.username}:" /etc/passwd | cut -d: -f7)
    
    if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "Setting ZSH as default shell..."
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      
      # Check if zsh is in /etc/shells, if not add it
      if ! grep -q "^$ZSH_PATH$" /etc/shells 2>/dev/null; then
        echo "Adding $ZSH_PATH to /etc/shells (requires sudo)..."
        $DRY_RUN_CMD echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
      fi
      
      # Change the default shell
      echo "Changing default shell to ZSH (may require password)..."
      $DRY_RUN_CMD sudo chsh -s "$ZSH_PATH" ${config.home.username}
      
      echo "✓ ZSH is now set as the default shell!"
      echo "  Please log out and log back in for changes to take effect."
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
      echo "✓ ZSH is already set as the default shell"
    fi
  '';
}
