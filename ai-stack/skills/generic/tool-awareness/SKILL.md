---
name: tool-awareness
description: Tells the AI agent what CLI tools are installed and available on this machine via home-manager. Use this skill in every project so the agent uses real tools instead of reinventing them.
---

# Available Tools

These tools are installed on this machine via Nix home-manager.
Use them directly instead of writing scripts that replicate their functionality.

## Search & Navigation
- `rg` (ripgrep) -- fast recursive grep. Use instead of `grep -r`.
- `fd` -- fast file finder. Use instead of `find`.
- `fzf` -- fuzzy finder. Pipe anything into it for interactive selection.
- `zoxide` (`z`) -- smart directory jumper. Use instead of `cd` for known paths.
- `bat` -- cat with syntax highlighting. Use for displaying file contents.
- `eza` -- modern ls with git status and icons.
- `tree` -- directory structure display.
- `lf` -- terminal file manager.

## Code Quality
- `ruff` -- Python linter + formatter. Replaces flake8, isort, black. Fast.
- `clang-format` -- C/C++ code formatter.
- `clang-tidy` -- C/C++ static analysis.
- `clangd` -- C/C++ LSP server (via clang-tools).
- `bear` -- generates `compile_commands.json` from Makefiles for clangd.

## Build Systems
- `cmake` + `ninja` -- C/C++ builds. Prefer `cmake -B build -G Ninja`.
- `make` (gnumake) -- standard make.
- `gcc` / `g++` -- GNU compiler.
- `gdb` / `lldb` -- debuggers.
- `ccache` -- compiler cache for faster rebuilds.

## Python
- `python3` -- Python interpreter.
- `uv` -- fast package/venv manager. Use instead of pip/virtualenv.
- `ruff` -- lint and format (see Code Quality above).

## Data Processing
- `jq` -- JSON processor. Use for parsing API responses, configs.
- `yq` -- YAML processor. Same idea as jq but for YAML.
- `ffmpeg` -- video/audio processing.

## Git & Collaboration
- `git` + `git-lfs` -- version control.
- `lazygit` -- TUI for git operations.
- `gh` -- GitHub CLI. Create PRs, issues, browse repos.

## Containers
- `docker` + `docker-compose` -- container management.
- `lazydocker` -- TUI for Docker.
- `dive` -- inspect Docker image layers.
- `ctop` -- container resource monitoring.

## Network & System
- `curl` / `wget` -- HTTP requests.
- `htop` -- process viewer.
- `gping` -- ping with graph.
- `tailscale` -- mesh VPN.
- `rsync` / `rclone` -- file sync (local and cloud).

## Knowledge
- `tldr` -- simplified man pages with examples.
- `navi` -- interactive cheat sheets.
- `buku` -- bookmark manager.

## Rules

- When a task can be done with an installed tool, use it.
- Don't install alternatives via pip/npm when the tool is already here.
- For Python: use `uv`, not `pip` or `virtualenv`.
- For search: use `rg`, not `grep`. Use `fd`, not `find`.
- For formatting: use `ruff` (Python) or `clang-format` (C++), not ad-hoc scripts.
