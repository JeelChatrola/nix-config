---
name: repo-documenter
description: Analyze a repository's build system, dependencies, and structure, then generate or update documentation. Use when the user asks to document a project, generate a README, or understand how to build/run/test a codebase.
---

# Repo Documenter

## When to Use

Activate when asked to document, explain, or generate setup instructions for a repository.

## Detection Order

Scan the repo root and one level deep for these markers (check all, a project may use several):

| Build System | Marker Files |
|---|---|
| CMake | `CMakeLists.txt` |
| Make | `Makefile`, `GNUmakefile` |
| Ninja | `build.ninja` |
| Meson | `meson.build` |
| Bazel | `BUILD`, `WORKSPACE` |
| Colcon/ROS | `package.xml`, `colcon.meta` |
| Python pip | `pyproject.toml`, `setup.py`, `setup.cfg` |
| Poetry | `pyproject.toml` with `[tool.poetry]` |
| uv | `pyproject.toml` with `[tool.uv]`, `uv.lock` |
| Conda | `environment.yml`, `environment.yaml`, `conda.yaml` |
| venv | `requirements.txt`, `.venv/`, `venv/` |
| npm/Node | `package.json` |
| Cargo/Rust | `Cargo.toml` |
| Docker | `Dockerfile`, `docker-compose.yml` |
| Nix | `flake.nix`, `shell.nix`, `default.nix` |

## Output Structure

Generate a concise README or doc section covering:

1. **What it is** -- one sentence purpose
2. **Prerequisites** -- system deps, runtime versions, hardware
3. **Setup** -- exact commands to clone, install deps, configure
4. **Build** -- exact build commands with common variants (debug/release)
5. **Run** -- how to execute, with example arguments
6. **Test** -- how to run tests
7. **Project layout** -- key directories and what they contain (max 10 entries)

## Rules

- Use the actual commands from the project (don't invent generic ones).
- If multiple build systems coexist (e.g., CMake + Python), document both.
- Note any env vars, config files, or secrets needed.
- If a CI config exists (`.github/workflows/`, `.gitlab-ci.yml`), extract the canonical build/test steps from it.
- Keep it under 100 lines. No fluff.
