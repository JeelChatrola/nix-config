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

- This repository: configuration source
- `flake.nix`: Nix flake definition and home-manager outputs
- `home-manager/home.nix`: Main config importing all modules
- `home-manager/programs/*.nix`: Tool configurations
- `home-manager/configs/*`: Raw config files (tmux, zsh aliases, etc.)
- `ai-stack/`: AI agents, MCP JSON, Docker compose, skills (see below)
- `overlays/`: Nix overlays (for example `llmfit`)

Git identity is configured in `home-manager/programs/git.nix`, not a standalone `gitconfig` file in `configs/`.

Generated files (Nix manages these):

- `~/.config/`: Application configs (nvim, etc.)
- `~/.zshrc`: Generated from zsh.nix
- `~/.tmux.conf`: Linked from configs consumed by tmux.nix
- `~/.nix-profile/`: Installed packages

Key concept: you edit files in this repo. Nix generates the dotfiles in your home directory. Never edit generated files directly.

## Repository Structure

```
nix-config/
├── flake.nix                 # Flake entry point (inputs, homeConfigurations)
├── flake.lock                # Locked dependency versions
├── deploy.sh                 # Runs home-manager switch; optional --ai for AI stack
├── overlays/
│   └── llmfit.nix            # Example overlay (pinned llmfit version)
├── ai-stack/                 # Claude/OpenCode/MCP, Docker stack (see ai-stack/README.md)
│   ├── README.md
│   ├── docker-compose.yml
│   └── ...
└── home-manager/
    ├── home.nix              # Main config, imports all programs
    ├── programs/             # Modular program configurations
    │   ├── packages.nix      # Package list
    │   ├── git.nix           # Git (programs.git)
    │   ├── zsh.nix
    │   ├── tmux.nix
    │   ├── ssh.nix
    │   ├── fzf.nix
    │   ├── neovim.nix
    │   └── ai-tools.nix      # Only when enableAI is true (flake output *-ai)
    └── configs/
        ├── tmux.conf
        └── zsh-aliases.sh
```

## Quick Start

### Initial Setup (New Machine)

1. **Set up SSH key for GitHub** (required for git operations):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/github_auth -C "your-email@example.com"

   # Or copy an existing key to this location.
   # Private key: ~/.ssh/github_auth
   # Public key:  ~/.ssh/github_auth.pub

   chmod 600 ~/.ssh/github_auth
   chmod 644 ~/.ssh/github_auth.pub

   cat ~/.ssh/github_auth.pub
   # Add at https://github.com/settings/keys
   ```

2. **Deploy base configuration** (CLI tools and dotfiles only):

   ```bash
   ./deploy.sh
   ```

   Optional **AI stack** (Claude Code, OpenCode, MCP configs, optional Docker for Ollama/Lobe/SearXNG):

   ```bash
   ./deploy.sh --ai
   ```

   Skip Docker on that run:

   ```bash
   ./deploy.sh --ai --no-docker
   ```

   Details: [ai-stack/README.md](ai-stack/README.md).

3. **Restart shell** so PATH and env pick up changes:

   ```bash
   exec zsh
   ```

### SSH Key Requirements

This configuration expects your GitHub SSH key at:

- Private key: `~/.ssh/github_auth`
- Public key: `~/.ssh/github_auth.pub`
- Permissions: `600` private, `644` public

`home-manager/programs/ssh.nix` uses `identityFile` for `github.com`. Change it there if you use another key name.

### Why `deploy.sh` uses `--impure`

`deploy.sh` invokes:

```bash
home-manager switch --flake ".#<target>" --impure
```

Home Manager evaluation may reference paths outside the flake (for example where this repo lives on disk). `--impure` allows those references. The flake inputs (`nixpkgs`, `home-manager`) are still locked by `flake.lock`.

### Submodule (robotics skills only)

Optional robotics skills live under `ai-stack/skills/robotics/robotics-agent-skills` as a git submodule. Initialize only if you need them:

```bash
git submodule update --init ai-stack/skills/robotics/robotics-agent-skills
```

## Installed Tools

CLI-focused stack (GUI apps stay on the system package manager):

- Development: curl, wget, git, zsh, tmux, neovim, fzf, nodejs (for agents when AI is enabled)
- System utilities: tree, htop, ripgrep, fd, bat, eza, jq, fastfetch
- File tools: unzip, zip, gzip, which, file, less, more, man-pages
- Networking: openssh, tailscale

## Adding New Packages

### Simple package (no extra configuration)

1. Add to `home-manager/programs/packages.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages
  your-package-name
];
```

2. Deploy: `./deploy.sh`

### Package with configuration

1. Create `home-manager/programs/your-tool.nix` with `programs.your-tool.enable = true` and options as needed.
2. Import it from `home-manager/home.nix`.
3. Deploy: `./deploy.sh`

### External config files

1. Add `home-manager/configs/your-tool.conf`
2. In the program module: `extraConfig = builtins.readFile ../configs/your-tool.conf;`

This matches tmux and zsh aliases.

## Finding Packages

```bash
nix search nixpkgs package-name
```

Or browse: https://search.nixos.org/packages

## Configuration Pattern

1. Modular design: one file per tool under `programs/`
2. Declarative: declare desired state
3. Composable: import modules in `home.nix`
4. Version controlled in git

## Understanding the Deploy Process

When you run `./deploy.sh`:

1. Nix reads `flake.nix` and locked inputs
2. Evaluates `home-manager/home.nix` and imported modules
3. Builds packages and generates config files
4. Links them into `~`
5. Activates the configuration

Do not edit `~/.zshrc` directly; it is generated from this repo.

## Modifying Existing Configurations

1. Edit `home-manager/programs/<tool>.nix` or files under `home-manager/configs/`
2. Run `./deploy.sh`
3. Restart affected programs or the terminal

## Troubleshooting

```bash
nix flake check
```

Verbose:

```bash
nix run home-manager/master -- switch --flake . --show-trace
```

Common issues:

- **`builtins.toFile` … `options.json` … without a proper context**: Harmless warning while Home Manager builds option documentation. Not a broken flake. See [home-manager#7935](https://github.com/nix-community/home-manager/issues/7935). You can try `manual.manpages.enable = false;` in `home.nix` if you do not need `man home-configuration.nix`.
- Package not found: use `nix search`
- Config not applied: restart the program or shell
- Syntax error: `nix flake check`
- File exists: back up unmanaged files blocking Nix
- Git over SSH fails: ensure `~/.ssh/github_auth` exists and is on GitHub

## Nix Standards Used

- Flakes with `flake.lock`
- home-manager for user-level config
- One program module per file where practical
- Raw configs in `configs/` when helpful

## Why These Choices

| Choice | Reason |
|--------|--------|
| Flakes | Reproducible, locked inputs |
| home-manager | User scope, no full system rebuild |
| Modular files | Toggle features by imports |
| CLI in Nix, GUI via system | Fewer driver/integration surprises |

## Learning Resources

- Packages: https://search.nixos.org/packages
- home-manager options: https://nix-community.github.io/home-manager/options.xhtml
- Nix language: https://nixos.org/manual/nix/stable/language/

For a specific option, see home-manager docs or examples in this repo.
