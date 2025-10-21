# 🎯 Clean Home-Manager Configuration Guide

This guide explains how to use and extend your clean, modular home-manager configuration.

## 📁 File Structure

```
nix/home-manager/
├── home.nix                    # Main configuration (imports everything)
├── home-clean.nix              # Clean configuration template
├── programs/                   # Individual program configurations
│   ├── packages.nix           # All packages to install
│   ├── git.nix                # Git configuration
│   ├── zsh.nix                # Zsh + oh-my-zsh configuration
│   ├── tmux.nix               # Tmux configuration
│   ├── ssh.nix                # SSH configuration
│   ├── fzf.nix                # FZF configuration
│   └── neovim.nix             # Neovim configuration
└── configs/                    # External config files
    ├── gitconfig               # Git settings and aliases
    ├── tmux.conf              # Tmux settings and key bindings
    └── zsh-aliases.sh         # Shell aliases and environment
```

## 🚀 Quick Start

```bash
# Switch to clean configuration
./use-clean-config.sh

# Deploy changes
./deploy.sh
```

## ➕ Adding New Applications

### **Step 1: Add Package**
Edit `home-manager/programs/packages.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages
  
  # Add your new package here
  your-new-package
];
```

### **Step 2: Create Program Configuration (Optional)**
If the application needs configuration, create `home-manager/programs/your-app.nix`:

```nix
{ config, pkgs, ... }:

{
  programs.your-app = {
    enable = true;
    # Add configuration here
  };
}
```

### **Step 3: Import Configuration**
Edit `home-manager/home.nix` and add to imports:

```nix
imports = [
  ./programs/packages.nix
  ./programs/git.nix
  ./programs/zsh.nix
  ./programs/tmux.nix
  ./programs/ssh.nix
  ./programs/fzf.nix
  ./programs/neovim.nix
  ./programs/your-app.nix  # Add this line
];
```

### **Step 4: Deploy**
```bash
./deploy.sh
```

## 📝 Examples

### **Adding Cursor Editor**

1. **Add to packages.nix**:
```nix
home.packages = with pkgs; [
  # ... existing packages
  cursor  # If available in nixpkgs
];
```

2. **If not in nixpkgs, install manually**:
```bash
# Download and install Cursor manually
# Then add alias in zsh-aliases.sh
alias cursor='cursor'
```

### **Adding Tailscale**

1. **Add to packages.nix**:
```nix
home.packages = with pkgs; [
  # ... existing packages
  tailscale
];
```

2. **Create tailscale.nix** (optional):
```nix
{ config, pkgs, ... }:

{
  programs.tailscale = {
    enable = true;
  };
}
```

3. **Add import to home.nix**:
```nix
imports = [
  # ... existing imports
  ./programs/tailscale.nix
];
```

### **Adding Custom Aliases**

Edit `home-manager/configs/zsh-aliases.sh`:

```bash
# Add your custom aliases
alias myalias='your command here'
alias ll='ls -alF --color=auto'
```

## 🔧 Configuration Files

### **Zsh Aliases** (`configs/zsh-aliases.sh`)
- Environment variables
- Shell aliases
- Custom functions
- Application shortcuts

### **Git Config** (`configs/gitconfig`)
- User information
- Git aliases
- Color settings
- Branch settings

### **Tmux Config** (`configs/tmux.conf`)
- Key bindings
- Status bar settings
- Color scheme
- Window management

## 🎨 Customization

### **Changing Themes**
Edit `programs/zsh.nix`:
```nix
oh-my-zsh = {
  enable = true;
  theme = "powerlevel10k/powerlevel10k";  # Change theme here
  plugins = [ /* ... */ ];
};
```

### **Adding Oh-My-Zsh Plugins**
Edit `programs/zsh.nix`:
```nix
plugins = [
  "git"
  "docker"
  "your-new-plugin"  # Add here
];
```

### **Customizing Tmux**
Edit `configs/tmux.conf`:
```bash
# Add your custom bindings
bind-key C-s save-buffer ~/tmux-buffer
bind-key C-r run-shell "tmux neww ~/.local/bin/tmux-sessionizer"
```

## 🔄 Workflow

### **Daily Usage**
1. Edit config files as needed
2. Run `./deploy.sh` to apply changes
3. Restart terminal or run `exec zsh`

### **Adding New Tools**
1. Add package to `packages.nix`
2. Create config file if needed
3. Add import to `home.nix`
4. Deploy with `./deploy.sh`

### **Backing Up**
- Configurations are automatically backed up when switching
- All configs are in version control
- Easy to replicate on new machines

## 🐛 Troubleshooting

### **Configuration Issues**
```bash
# Check configuration
nix flake check

# Deploy with verbose output
nix run nixpkgs#home-manager -- switch --flake . --impure --show-trace
```

### **Package Not Found**
- Check [nixpkgs search](https://search.nixos.org/packages)
- Use `nixpkgs-unstable` for newer packages
- Install manually if not available

### **Config Not Applied**
- Restart terminal: `exec zsh`
- Check if config file exists
- Verify import in `home.nix`

## 📚 Best Practices

1. **Keep it organized**: One program per file
2. **Use external configs**: For complex tool configurations
3. **Document changes**: Add comments to your configs
4. **Test before deploying**: Use `nix flake check`
5. **Version control**: Commit your configuration changes
6. **Start simple**: Add complexity gradually

## 🎯 Benefits of This Approach

- ✅ **Modular**: Easy to enable/disable features
- ✅ **Maintainable**: Clear separation of concerns
- ✅ **Extensible**: Easy to add new applications
- ✅ **Readable**: Familiar config file formats
- ✅ **Portable**: Easy to replicate on new machines
- ✅ **Safe**: Automatic backups and version control

This clean approach gives you the best of both worlds: the power of Nix with the familiarity of traditional config files! 🚀
