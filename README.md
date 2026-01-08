# Nix Home-Manager Configuration

A modular, declarative configuration for development tools and CLI utilities using Nix home-manager.

## What This Is

Traditional package management (apt, yum, brew) installs packages system-wide and scatters configuration across your home directory. This Nix setup:

- Declares all packages and their configurations in this repository
- Generates config files in `~/.config/` and other standard locations
- Allows you to reproduce your entire environment on any machine
- Keeps your actual configuration source-controlled here, not in `~/.config/`

## How It Differs from Traditional Setup

Traditional approach:
```
apt install zsh tmux neovim
# Then manually edit ~/.zshrc, ~/.tmux.conf, ~/.config/nvim/init.vim
# Config files scattered, hard to track changes
```

This Nix approach:
```
# Edit home-manager/programs/zsh.nix
# Edit home-manager/configs/tmux.conf
# Run ./deploy.sh
# All configs tracked here, generated files placed automatically
```

## Where Files Live

Source files (you edit these):
- This repository: Configuration source
- `flake.nix`: Nix flake definition
- `home-manager/home.nix`: Main config importing all modules
- `home-manager/programs/*.nix`: Tool configurations
- `home-manager/configs/*`: Raw config files

Generated files (Nix manages these):
- `~/.config/`: Application configs (nvim, etc)
- `~/.zshrc`: Generated from zsh.nix
- `~/.tmux.conf`: Symlinked from configs/tmux.conf
- `~/.nix-profile/`: Installed packages

Key concept: You edit files in this repo. Nix generates the dotfiles in your home directory. Never edit generated files directly.

## Repository Structure

```
nix-config/
├── flake.nix                 # Nix flake entry point
├── flake.lock                # Locked dependency versions
├── deploy.sh                 # Deployment script
└── home-manager/
    ├── home.nix             # Main config, imports all programs
    ├── programs/            # Modular program configurations
    │   ├── packages.nix     # List of packages to install
    │   ├── git.nix         # Git program configuration
    │   ├── zsh.nix         # Zsh with oh-my-zsh
    │   ├── tmux.nix        # Tmux configuration
    │   ├── ssh.nix         # SSH configuration
    │   ├── fzf.nix         # FZF fuzzy finder
    │   └── neovim.nix      # Neovim with plugins
    └── configs/             # Raw config files
        ├── gitconfig        # Git aliases and settings
        ├── tmux.conf       # Tmux key bindings
        └── zsh-aliases.sh  # Shell aliases and functions
```

## Quick Start

### Initial Setup (New Machine)

1. **Set up SSH key for GitHub** (required for git operations):
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t ed25519 -f ~/.ssh/github_auth -C "your-email@example.com"
   
   # Or copy existing key to the required location
   # The key MUST be named: ~/.ssh/github_auth
   # The public key MUST be named: ~/.ssh/github_auth.pub
   
   # Set correct permissions
   chmod 600 ~/.ssh/github_auth
   chmod 644 ~/.ssh/github_auth.pub
   
   # Add public key to GitHub
   cat ~/.ssh/github_auth.pub
   # Copy output and add to: https://github.com/settings/keys
   ```

2. **Deploy configuration**:
   ```bash
   ./deploy.sh
   ```

3. **Restart shell to load changes**:
   ```bash
   exec zsh
   ```

### SSH Key Requirements

This configuration expects your GitHub SSH key to be:
- **Location**: `~/.ssh/github_auth` (private key)
- **Public key**: `~/.ssh/github_auth.pub`
- **Permissions**: `600` for private key, `644` for public key

The SSH configuration in `home-manager/programs/ssh.nix` is hardcoded to use `github_auth`. If you use a different key name, update the `identityFile` in `ssh.nix`.

After deployment, your SSH key will be automatically loaded when you open a new terminal, and git will use SSH for all GitHub operations.

## Installed Tools

CLI development tools (no GUI applications):

Development: curl, wget, git, zsh, tmux, neovim, fzf
System utilities: tree, htop, ripgrep, fd, bat, eza, jq, neofetch
File tools: unzip, zip, gzip, which, file, less, more, man-pages
Networking: openssh, tailscale

GUI applications are installed through system package manager to avoid driver/integration issues.

## Adding New Packages

Two approaches depending on complexity:

### Simple Package (no configuration needed)

1. Add to `home-manager/programs/packages.nix`:
```nix
home.packages = with pkgs; [
  # ... existing packages
  your-package-name
];
```

2. Deploy: `./deploy.sh`

### Package with Configuration

1. Create `home-manager/programs/your-tool.nix`:
```nix
{ config, pkgs, ... }:

{
  programs.your-tool = {
    enable = true;
    # Add configuration options here
  };
}
```

2. Add import to `home-manager/home.nix`:
```nix
imports = [
  ./programs/packages.nix
  ./programs/git.nix
  # ... other imports
  ./programs/your-tool.nix
];
```

3. Deploy: `./deploy.sh`

### Using External Config Files

For tools with complex configurations, use the configs directory:

1. Create `home-manager/configs/your-tool.conf`
2. Reference it in your program's .nix file:
```nix
programs.your-tool = {
  enable = true;
  extraConfig = builtins.readFile ../configs/your-tool.conf;
};
```

This pattern is used for zsh aliases, tmux conf, and git config.

## Finding Packages

Search available packages:
```bash
nix search nixpkgs package-name
```

Or browse: https://search.nixos.org/packages

## Configuration Pattern

This setup follows standard Nix home-manager patterns:

1. Modular design: Each tool gets its own file in `programs/`
2. Declarative: State what you want, not how to get it
3. Composable: Import modules in home.nix to enable them
4. Version controlled: All config is tracked in git

## Understanding the Deploy Process

When you run `./deploy.sh`:

1. Nix reads `flake.nix` to understand your system
2. Evaluates `home-manager/home.nix` and all imported modules
3. Builds packages and generates config files
4. Symlinks or copies files to their final locations in ~
5. Activates the new configuration

This is why you never edit `~/.zshrc` directly - it's generated from this repo.

## Modifying Existing Configurations

To change tool behavior:

1. Find the tool's config:
   - Check `home-manager/programs/tool-name.nix`
   - Or check `home-manager/configs/` for external configs

2. Edit the source file here (not in `~/.config/`)

3. Deploy changes with `./deploy.sh`

4. Reload affected programs (restart terminal, `tmux source-file ~/.tmux.conf`, etc)

## Troubleshooting

Configuration validation:
```bash
nix flake check
```

Verbose deployment:
```bash
nix run home-manager/master -- switch --flake . --show-trace
```

Common issues:

- "Package not found": Check package name with `nix search`
- "Config not applied": Restart the program or terminal
- "Syntax error": Run `nix flake check` to validate
- "File exists": Nix won't overwrite unmanaged files, back them up first
- "Git push/pull fails": Ensure `~/.ssh/github_auth` exists and is added to GitHub
- "SSH key not loading": Check that `~/.ssh/github_auth` has correct permissions (600)

## Nix Standards Used

This configuration follows these conventions:

- Uses flakes (modern Nix approach)
- home-manager for user-level packages and configs
- Modular structure (one program per file)
- External config files for complex configurations
- Declarative package lists in packages.nix
- Standard Nix module structure ({ config, pkgs, ... }: { ... })

## Why These Choices

Flakes: Reproducible, locked dependencies
home-manager: User-level, doesn't require root
Modular files: Easy to enable/disable features
External configs: Familiar formats, easier to edit
No GUI apps: Avoid system integration issues

## Learning Resources

Nix package search: https://search.nixos.org/packages
home-manager options: https://nix-community.github.io/home-manager/options.xhtml
Nix language basics: https://nixos.org/manual/nix/stable/language/

For understanding a specific option, check the home-manager documentation or look at examples in this repo.
