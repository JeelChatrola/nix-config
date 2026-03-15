---
name: python-standards
description: Enforce Python best practices for linting, formatting, typing, testing, and project structure. Use when writing, reviewing, or refactoring Python code.
---

# Python Standards

## Toolchain

| Tool | Purpose | Command |
|---|---|---|
| ruff | Linting + formatting (replaces flake8, isort, black) | `ruff check --fix .` / `ruff format .` |
| uv | Package management (replaces pip, virtualenv) | `uv sync` / `uv run pytest` |
| pytest | Testing | `pytest -xvs` |

These are installed via home-manager. Prefer them over alternatives.

## Code Rules

### Style
- Format with ruff (line length 88, double quotes, trailing commas).
- Imports: stdlib, then third-party, then local. Let ruff sort them.
- No wildcard imports (`from x import *`).

### Typing
- Add type hints to all function signatures (args + return).
- Use `from __future__ import annotations` for modern syntax.
- Prefer `str | None` over `Optional[str]`.
- Use `collections.abc` types (`Sequence`, `Mapping`) over `typing` equivalents.

### Structure
- One class per file unless tightly coupled.
- `__init__.py` should only re-export public API, no logic.
- Constants at module top, `ALL_CAPS`.
- Private helpers prefixed with `_`.

### Error Handling
- Catch specific exceptions, never bare `except:`.
- Use custom exception classes for domain errors.
- Let unexpected exceptions propagate.

### Testing
- Test file mirrors source: `src/foo/bar.py` → `tests/foo/test_bar.py`.
- Use fixtures over setUp/tearDown.
- One assert per test when practical.
- Name tests: `test_<function>_<scenario>_<expected>`.

### Dependencies
- Pin versions in `pyproject.toml` or `requirements.txt`.
- Use `uv` for venv and dependency management.
- Never install into system Python.

## When Reviewing

Flag these as issues:
- Missing type hints on public functions
- Bare `except` clauses
- Mutable default arguments (`def f(x=[])`)
- Global mutable state
- Missing `__init__.py` in package directories
- Print statements in library code (use `logging`)
