# Nix Home Manager Configuration

Host-oriented Home Manager and nix-darwin configuration built from reusable identities, host facts, presets, and capabilities.

## Repository ownership

| Repository | Ownership |
|---|---|
| `system-setup` | Host bootstrap and system services, including the Docker daemon/CLI bundle on Linux and Tailscale |
| `nix-config` | Home Manager, nix-darwin integration, shell/editor tools, and non-AI applications |
| `ai-stack` | AI client installation and updates, optional local services, generated configuration, and private runtime data |

Secrets, SOPS data, and SSH keys are not managed here.

## Architecture

Configuration is assembled in this order:

1. `home-manager/identities/` contains reusable person-level facts such as Git name and email.
2. `home-manager/hosts/` contains platform and host facts, including `system`, home directory, identity, preset, additions, and removals.
3. `home-manager/lib/presets.nix` resolves a preset, additions, then removals; it rejects unknown capabilities and deduplicates the result.
4. `home-manager/capabilities/` allocates packages and focused program modules by role.
5. `home-manager/home.nix` contains common Home Manager state and imports only the resolved capabilities.

Available presets:

| Preset | Capabilities |
|---|---|
| `base` | `base` |
| `personal` | `base desktop` |
| `workstation` | `base desktop development containers` |
| `server` | `base containers` |

The canonical Linux output is `homeConfigurations."jeel@main-workstation"`. It uses the `workstation` preset. AI tools are managed separately in `ai-stack`.

The `development` capability includes [mise](https://mise.jdx.dev/) (with Zsh integration) for per-project runtimes. Nix still provides the system Node 24 / uv / Python toolchain; mise only takes effect where a project directory pins its own tools, and no global tool versions are set here.

## Deploy

Linux deployment requires an explicit host and selects `USER@HOST`:

```bash
./deploy.sh --host main-workstation
```

`nix-refresh --host main-workstation` runs the same script from any directory. It resolves the checkout at runtime from `NIX_CONFIG_DIR`, defaulting to `$HOME/nix-config`; generated wrappers do not embed a machine-specific checkout path.

Both commands use the existing lockfile unless `--update` is passed. To update all flake inputs and then apply the Linux Home Manager configuration:

```bash
nix-upgrade --host main-workstation
```

For the initial upgrade, before the wrapper is installed:

```bash
./deploy.sh --host main-workstation --update
```

`nix-upgrade` resolves the checkout exactly like `nix-refresh` and forwards user arguments to `deploy.sh --update`. The script validates arguments and requires a host before running `nix flake update --flake "$FLAKE_PATH"`, then switches from that same checkout. An update failure stops deployment. If updating changes `flake.lock` and the update or switch later fails, the lockfile remains modified; there is no automatic rollback. Review the diff before retrying or restoring it.

This updates flake inputs, not manually pinned package overrides. It does not run apt or update AI services; those remain separate workflows.

If `nh` is not already on `PATH`, deployment runs the flake's locked `.#nh` package. This keeps the fallback tied to `flake.lock` and also works when the checkout path contains spaces.

AI client deployment is separate and does not start local services:

```bash
ai-stack deploy
```

From the ai-stack checkout, use `bin/ai-stack deploy` for the first installation. It links its commands into `~/.local/bin`, which must be on PATH. Individual updates belong to that repo:

```bash
ai-stack update codex
ai-stack update hermes
ai-stack add PACKAGE
```

For the ownership migration, install ai-stack clients first, then apply this Home Manager configuration and open a new shell. Check `command -v codex` and `command -v hermes`: both should resolve through `~/.local/bin`. Existing authentication and agent state stay in their existing directories.

Nix no longer supplies AI launchers, AI environment variables, or `llmfit`. RTK remains a general CLI utility in the development capability. Existing editor, shell, and desktop choices are retained; further package pruning can be done as those workflows are reviewed.

## macOS

The integrated nix-darwin output is deliberately CLI-only: `base + development`, without desktop or AI capabilities.

```bash
sudo darwin-rebuild switch --flake .#jeel-mac
```

Temporary standalone Home Manager fallbacks remain available:

```bash
home-manager switch --flake .#jeel-mac
```

The legacy `jeel-mac-ai` output has been removed. The integrated Mac configuration is unchanged; AI tools are managed outside Nix.

Docker Desktop or Colima owns the daemon on macOS. The `containers` capability supplies client tools there. On Linux, Home Manager leaves `docker` and `docker-compose` to `system-setup` while retaining `lazydocker`, `dive`, and `ctop`.

## Launcher

Press `Ctrl+Space` on GNOME to open the Rofi command center. The initial search combines applications, shell commands, open windows, and calculations. Use `Ctrl+Tab` and `Ctrl+Shift+Tab` to move through file browsing, emoji, and actions for clipboard history, web search, screen locking, suspend, restart, and power off. Destructive power actions require confirmation.

## Neovim

AstroNvim configuration and `lazy-lock.json` are store-managed. Update plugins and the lockfile in `home-manager/configs/nvim/` in the source checkout before deployment; deployed files are immutable.

## Validation

```bash
nix flake check --no-build
nix build .#checks.x86_64-linux.deploy-workflow --print-build-logs
nix build '.#homeConfigurations."jeel@main-workstation".activationPackage'
nix eval .#homeConfigurations.jeel-mac.activationPackage.drvPath
nix eval .#darwinConfigurations.jeel-mac.system.drvPath
```

Flake checks cover required `system`, unknown capability rejection, preset resolution/deduplication, server and personal exclusions, integrated Darwin GUI/AI exclusions, absence of AI packages and environment variables on Linux, and the locked `nh` deploy fallback.

The `deploy-workflow` check tests deployment and the generated refresh/upgrade wrappers with mocked commands, including validation before updates, failure handling, checkout paths with spaces, and the `nh` fallback. CI runs it without updating inputs or activating a configuration.

See [Keyboard Workflow](docs/KEYBOARD_WORKFLOW.md) for terminal and editor shortcuts.
