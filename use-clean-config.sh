#!/bin/bash

# Clean configuration switcher
# Usage: ./use-clean-config.sh

set -e

echo "🧹 Switching to clean modular configuration..."

# Navigate to the nix directory
cd "$(dirname "$0")"

# Backup current config if it exists
if [[ -f "home-manager/home.nix" ]]; then
    cp "home-manager/home.nix" "home-manager/home.nix.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backed up current config"
fi

# Copy the clean config
cp "home-manager/home-clean.nix" "home-manager/home.nix"
echo "✅ Switched to clean configuration"

# Deploy the new configuration
echo "🚀 Deploying clean configuration..."
nix run nixpkgs#home-manager -- switch --flake . --impure

echo ""
echo "🎉 Clean configuration deployed successfully!"
echo ""
echo "📁 Your configuration is now organized as:"
echo "   • home-manager/home.nix - Main configuration"
echo "   • home-manager/programs/ - Individual program configs"
echo "   • home-manager/configs/ - External config files"
echo ""
echo "🔧 To add new applications:"
echo "   1. Add package to programs/packages.nix"
echo "   2. Create config in programs/your-app.nix (if needed)"
echo "   3. Add import to home.nix"
echo "   4. Run ./deploy.sh"
echo ""
echo "💡 Restart your terminal or run: exec zsh"
