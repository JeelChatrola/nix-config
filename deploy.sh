#!/bin/bash

# Deploy home-manager configuration
# This script will build and switch to the new home-manager configuration

set -e

echo "🚀 Deploying home-manager configuration..."

# Navigate to the nix directory
cd "$(dirname "$0")"

# Build and switch to the new configuration
echo "📦 Building home-manager configuration..."
nix run nixpkgs#home-manager -- switch --flake . --impure
exec zsh

echo "✅ Home-manager configuration deployed successfully!"
echo ""
echo "🎉 Your development environment is now configured with:"
echo "   • Development tools: curl, wget, git, zsh, tmux"
echo "   • Oh-my-zsh with plugins and green-on-black theme"
echo "   • GUI applications: Cursor, Zen Browser"
echo "   • Additional tools: tree, htop, ripgrep, fd, bat, exa, fzf"
echo ""
echo "💡 To apply changes:"
echo "   • Restart your terminal or run: exec zsh"
echo "   • Start tmux: tmux"
echo "   • Launch Cursor: cursor"
echo "   • Launch Zen Browser: zen-browser"
echo ""
echo "🔧 To update your configuration:"
echo "   1. Edit home-manager/home.nix"
echo "   2. Run: ./deploy.sh"
