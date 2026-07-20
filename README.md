# Nix Home Manager Configuration

Host-oriented Home Manager and nix-darwin configuration built from reusable identities, host facts, presets, and capabilities.

## Repository ownership

| Repository | Ownership |
|---|---|
| `system-setup` | Host bootstrap and system services, including the Docker daemon/CLI bundle on Linux and Tailscale |
| `nix-config` | Home Manager, nix-darwin integration, shell/editor tools, desktop user applications, and AI wrappers |
| `ai-stack` | AI services, agents, generated configuration, and private runtime data |

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

The canonical Linux output is `homeConfigurations."jeel@main-workstation"`. It uses the `workstation` preset plus `ai`.

## Deploy

Linux deployment requires an explicit host and selects `USER@HOST`:

```bash
./deploy.sh --host main-workstation
```

`nix-refresh --host main-workstation` runs the same script from any directory. It resolves the checkout at runtime from `NIX_CONFIG_DIR`, defaulting to `$HOME/nix-config`; generated wrappers do not embed a machine-specific checkout path.

If `nh` is not already on `PATH`, deployment runs the flake's locked `.#nh` package. This keeps the fallback tied to `flake.lock` and also works when the checkout path contains spaces.

AI runtime deployment is separate:

```bash
ai-stack deploy
```

The wrappers resolve `AI_STACK_DIR` at runtime, defaulting to `$HOME/ai-stack`.

OpenCode, Codex, and Agent Browser wrappers execute packages from the nixpkgs revision in `flake.lock`; they do not download npm packages at runtime. The current locked versions are OpenCode `1.17.4`, Codex `0.139.0`, Agent Browser `0.27.0`, and `nh` `4.3.2`.

Update these tools by updating the lock file, reviewing the version changes, and running validation:

```bash
nix flake update nixpkgs
nix eval --raw .#packages.x86_64-linux.nh.version
nix eval --raw --impure --expr 'let f = builtins.getFlake (toString ./.); p = import f.inputs.nixpkgs { system = "x86_64-linux"; }; in p.opencode.version'
nix eval --raw --impure --expr 'let f = builtins.getFlake (toString ./.); p = import f.inputs.nixpkgs { system = "x86_64-linux"; }; in p.codex.version'
nix eval --raw --impure --expr 'let f = builtins.getFlake (toString ./.); p = import f.inputs.nixpkgs { system = "x86_64-linux"; }; in p.agent-browser.version'
nix flake check
```

Commit `flake.lock` only after reviewing and validating the resulting package updates.

## macOS

The integrated nix-darwin output is deliberately CLI-only: `base + development`, without desktop or AI capabilities.

```bash
sudo darwin-rebuild switch --flake .#jeel-mac
```

Temporary standalone Home Manager fallbacks remain available:

```bash
home-manager switch --flake .#jeel-mac
home-manager switch --flake .#jeel-mac-ai
```

`jeel-mac-ai` installs AI client wrappers only. The current local Docker stack
requires Linux with NVIDIA support; on macOS or non-NVIDIA hosts, keep Docker
deployment disabled with `AI_STACK_DOCKER=0`.

Docker Desktop or Colima owns the daemon on macOS. The `containers` capability supplies client tools there. On Linux, Home Manager leaves `docker` and `docker-compose` to `system-setup` while retaining `lazydocker`, `dive`, and `ctop`.

## Neovim

AstroNvim configuration and `lazy-lock.json` are store-managed. Update plugins and the lockfile in `home-manager/configs/nvim/` in the source checkout before deployment; deployed files are immutable.

## Validation

```bash
nix flake check --no-build
nix build '.#homeConfigurations."jeel@main-workstation".activationPackage'
nix eval .#homeConfigurations.jeel-mac.activationPackage.drvPath
nix eval .#homeConfigurations.jeel-mac-ai.activationPackage.drvPath
nix eval .#darwinConfigurations.jeel-mac.system.drvPath
```

Flake checks cover required `system`, unknown capability rejection, preset resolution/deduplication, server and personal exclusions, integrated Darwin GUI/AI exclusions, locked AI wrapper dependencies, and the locked `nh` deploy fallback.

See [Keyboard Workflow](docs/KEYBOARD_WORKFLOW.md) for terminal and editor shortcuts.
