# Nix Home-Manager Configuration

Modular, declarative configuration for development tools and CLI utilities using Nix home-manager.

## Three-repo layout

| Repo | Role |
|------|------|
| [system-setup](https://github.com/JeelChatrola/system-setup) | Host bootstrap: Nix, Docker, Ghostty, desktop |
| **nix-config** (this repo) | Home Manager, shell, tmux, editor, CLI wrappers |
| [ai-stack](https://github.com/JeelChatrola/ai-stack) (private) | MCP, Docker services, skills, Hermes/OpenCode config at `~/ai-stack` |

`AI_STACK_DIR` defaults to `$HOME/ai-stack`. Secrets and `generated/` MCP output live in the private ai-stack repo, not here.

## Quick Start

### New machine

1. Run `system-setup` (`./install.sh`).
2. Set up git/SSH, then clone your **nix-config** and **ai-stack** repos yourself.
3. Deploy base: `cd ~/nix-config && ./deploy.sh`. On macOS, this automatically selects `.#jeel-mac`; on Linux, `.#$USER`.
4. Deploy with AI: `./deploy.sh --ai` (requires `~/ai-stack`; its first Docker run creates a private local SearXNG secret).

### macOS branch/profile

This branch includes Apple Silicon Home Manager outputs for a 1-1 shell/editor/tmux experience:

```bash
cd ~/nix-config
./deploy.sh                  # macOS auto-selects .#jeel-mac
./deploy.sh --ai             # macOS auto-selects .#jeel-mac-ai
home-manager switch --flake .#jeel-mac --impure      # explicit base target
home-manager switch --flake .#jeel-mac-ai --impure   # explicit AI target
```

The mac profile uses `/Users/jeel`, `aarch64-darwin`, and skips Linux-only pieces (`xclip`, `gcc/gdb`, Linux man-db pages, default-shell activation, RTK binary). Docker Desktop/Colima still owns the daemon on macOS; Nix installs client CLIs and the same terminal workflow tools.

### Daily

```bash
./deploy.sh              # Home Manager only (.#$USER)
./deploy.sh --ai         # .#$USER-ai + ~/ai-stack/bin/ai-stack deploy
nix-refresh --ai         # same from any directory (Home Manager-installed command)
```

Skip Docker and secret provisioning: `./deploy.sh --ai --no-docker`.

## Repository structure

```
nix-config/
├── flake.nix
├── deploy.sh
├── docs/              # Workflow and keyboard guide
├── home-manager/
│   ├── home.nix
│   ├── programs/       # zsh, tmux, ghostty, ai-tools.nix (*-ai only)
│   └── configs/
└── overlays/
```

## AI integration

When `enableAI` is true (flake output `*-ai`), `ai-tools.nix` installs:

- `opencode`, `codex`, `agent-browser`, `hermes`, `deeptutor`, `ai-stack`, and `rtk` wrappers/tools on PATH
- `AI_STACK_DIR` and `NIX_CONFIG_DIR` session variables
- Nix-store wrappers for ai-stack entrypoints

Skills, MCP catalog, agent profiles, Docker compose, and Ollama commands live in the private **ai-stack** repo. Use `ai-stack --help`; Nix only installs its wrapper and environment.

Runtime setup is explicit: use `./deploy.sh --ai` or `ai-stack deploy` after Home Manager has installed the wrappers. Deployment downloads Agent Browser's Chrome assets to `~/.agent-browser`; Hermes and DeepTutor install via uv (`bin/ai-stack install-agents`), RTK configures Claude Code, OpenCode, Hermes, and Codex integrations, and the ai-stack Compose wrapper creates its ignored `.env` and SearXNG secret with mode `0600` when Docker is first used. Config and data remain in `~/.hermes`, `~/deeptutor`, and `~/ai-stack`.

## Terminal

Ghostty config is managed at `~/.config/ghostty/config`. Install the Ghostty binary via system-setup (`./install.sh ghostty` — apt or PPA, not Nix).

Ghostty, tmux, Oh My Posh, FZF, and AstroNvim use Gruvbox styling. Neovim's AstroNvim configuration exposes its which-key command groups under the `Space` leader. The tmux status uses the maintained `tmux-cpu` plugin for CPU/GPU utilization. Sesh manages project sessions; Resurrect and Continuum persist layouts.

Press `Ctrl+a ?` inside tmux or run `workflow-help` from any shell to search shortcuts across tmux, Zsh, Neovim, Harpoon, previews, and Ghostty.

Read [Keyboard Workflow](docs/KEYBOARD_WORKFLOW.md) for the mental model, complete shortcut tables, and practice guidance.

## Adding packages

Edit `home-manager/programs/packages.nix`, then `./deploy.sh`.

## Troubleshooting

```bash
nix flake check
```

- Missing ai-stack on `--ai`: clone to `~/ai-stack`
- `hermes: command not found`: activate the AI profile with `./deploy.sh --ai`; the base profile intentionally excludes AI wrappers
- `--impure` on deploy: allows HM to reference `~/ai-stack` paths outside the flake store

## Learning

- https://search.nixos.org/packages
- https://nix-community.github.io/home-manager/options.xhtml
