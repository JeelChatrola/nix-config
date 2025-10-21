# Home-Manager Configuration

A clean, modular home-manager configuration for development environments.

## 🚀 Quick Start

```bash
# Deploy configuration
./deploy.sh

# Restart terminal
exec zsh
```

## 📁 Structure

```
nix/
├── deploy.sh                    # Deploy script
├── README.md                   # This file
├── flake.nix                   # Nix flake configuration
└── home-manager/
    ├── home.nix               # Main configuration
    ├── programs/              # Program configurations
    │   ├── packages.nix       # All packages
    │   ├── git.nix           # Git configuration
    │   ├── zsh.nix           # Zsh + oh-my-zsh
    │   ├── tmux.nix          # Tmux configuration
    │   ├── ssh.nix           # SSH configuration
    │   ├── fzf.nix           # FZF configuration
    │   └── neovim.nix        # Neovim configuration
    └── configs/              # External config files
        ├── gitconfig         # Git settings
        ├── tmux.conf         # Tmux settings
        └── zsh-aliases.sh    # Shell aliases
```

## 📦 Included Tools

### Development Tools
- curl, wget, git, zsh, tmux
- neovim (with plugins)
- fzf (fuzzy finder)
- ripgrep, fd, bat, eza

### System Utilities
- tree, htop, jq, neofetch
- unzip, zip, gzip, which, file, less, more

### Networking & Security
- openssh (optimized configuration)
- tailscale (VPN)

### GUI Applications
- firefox, chromium

## 🔧 Adding New Applications

1. **Add package** to `home-manager/programs/packages.nix`
2. **Create config** in `home-manager/programs/your-app.nix` (if needed)
3. **Add import** to `home-manager/home.nix`
4. **Deploy** with `./deploy.sh`

## 📚 Documentation

- `COMPLETE-SUMMARY.md` - Complete overview
- `CLEAN-CONFIG-GUIDE.md` - Detailed guide with examples

## 🎯 Benefits

- ✅ Modular and extensible
- ✅ Easy to maintain
- ✅ Familiar config file formats
- ✅ Safe with automatic backups
- ✅ Portable across machines