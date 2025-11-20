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
  # LF FILE MANAGER CONFIGURATION
  # =============================================================================
  home.file.".config/lf/lfrc".text = ''
    # Basic settings
    set hidden true
    set icons true
    set ignorecase true
    
    # Gruvbox colors
    set color256 true
    
    # Use pistol for previews if available
    set previewer ~/.config/lf/preview
    
    # Key bindings
    map <enter> open
    map <delete> delete
  '';
  
  home.file.".config/lf/preview".text = ''
    #!/bin/sh
    case "$1" in
        *.tar*) tar tf "$1";;
        *.zip) unzip -l "$1";;
        *.rar) unrar l "$1";;
        *.7z) 7z l "$1";;
        *.pdf) pdftotext "$1" -;;
        *) bat --color=always --style=plain "$1" 2>/dev/null || cat "$1";;
    esac
  '';
  
  home.file.".config/lf/preview".executable = true;
  
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
    ./programs/gnome.nix
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
