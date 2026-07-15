# Optional activation: set Nix profile zsh as login shell (needs sudo).

{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.homeManager.setDefaultShellOnActivate = mkOption {
    type = types.bool;
    default = true;
    description = ''
      When true, activation ensures ~/.nix-profile/bin/zsh is in /etc/shells and runs chsh.
      Set to false on hosts where another mechanism manages the default shell.
      Linux-only; Home Manager on macOS leaves the login shell untouched.
    '';
  };

  config = mkIf (config.custom.homeManager.setDefaultShellOnActivate && pkgs.stdenv.isLinux) {
    home.activation.setDefaultShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ZSH_PATH="${config.home.homeDirectory}/.nix-profile/bin/zsh"
      export PATH="/usr/bin:/bin:$PATH"
      CURRENT_SHELL=$(grep "^${config.home.username}:" /etc/passwd | cut -d: -f7)

      if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Setting ZSH as default shell..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if ! grep -q "^$ZSH_PATH$" /etc/shells 2>/dev/null; then
          echo "Adding $ZSH_PATH to /etc/shells (requires sudo)..."
          $DRY_RUN_CMD echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
        fi

        echo "Changing default shell to ZSH (may require password)..."
        $DRY_RUN_CMD sudo chsh -s "$ZSH_PATH" ${config.home.username}

        echo "✓ ZSH is now set as the default shell!"
        echo "  Please log out and log back in for changes to take effect."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      else
        echo "✓ ZSH is already set as the default shell"
      fi
    '';
  };
}
