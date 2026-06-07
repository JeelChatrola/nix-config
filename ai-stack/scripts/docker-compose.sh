#!/usr/bin/env bash
# docker compose wrapper for ai-stack (optional ai-stack/.env for SEARXNG_PORT, HF_TOKEN, etc.)
set -euo pipefail

STACK_DIR="${AI_STACK_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
args=(-f "$STACK_DIR/docker-compose.yml")
if [[ -f "$STACK_DIR/.env" ]]; then
  args+=(--env-file "$STACK_DIR/.env")
fi
exec docker compose "${args[@]}" "$@"
