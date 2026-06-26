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
3. Deploy base: `cd ~/nix-config && ./deploy.sh`
4. Deploy with AI: `./deploy.sh --ai` (requires `~/ai-stack` checkout)

### Daily

```bash
./deploy.sh              # Home Manager only (.#$USER)
./deploy.sh --ai         # .#$USER-ai + ~/ai-stack/bin/ai-stack deploy
nix-refresh --ai         # same from any directory (zsh alias)
```

Skip Docker: `./deploy.sh --ai --no-docker`

## Repository structure

```
nix-config/
├── flake.nix
├── deploy.sh
├── home-manager/
│   ├── home.nix
│   ├── programs/       # zsh, tmux, ghostty, ai-tools.nix (*-ai only)
│   └── configs/
└── overlays/
```

## AI integration

When `enableAI` is true (flake output `*-ai`), `ai-tools.nix` installs:

- `opencode`, `hermes`, `ai-stack` wrappers on PATH
- `AI_STACK_DIR` and `NIX_CONFIG_DIR` session variables
- Activation: `~/ai-stack/bin/ai-stack sync` + `~/ai-stack/bin/agent-sync opencode`

Skills, MCP catalog, agent profiles, and Docker compose live in the private **ai-stack** repo. Shell aliases (`ai-up`, `ai-skills`, `ai-boot`, …) call `$AI_STACK_DIR/bin/ai-stack` or `bin/skills`.

Hermes runs from the nix-config flake (`#hermes`); `~/ai-stack/bin/hermes` delegates to it.

## Terminal

Ghostty config is managed at `~/.config/ghostty/config`. Install the Ghostty binary via system-setup (`./install.sh ghostty` — apt or PPA, not Nix).

tmux is installed and configured directly (no oh-my-zsh tmux plugin).

## Adding packages

Edit `home-manager/programs/packages.nix`, then `./deploy.sh`.

## Troubleshooting

```bash
nix flake check
```

- Missing ai-stack on `--ai`: clone to `~/ai-stack`
- `--impure` on deploy: allows HM to reference `~/ai-stack` paths outside the flake store

## Learning

- https://search.nixos.org/packages
- https://nix-community.github.io/home-manager/options.xhtml
