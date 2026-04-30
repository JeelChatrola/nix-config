#!/usr/bin/env bash
# Used by deploy.sh --ai: exit 0 = start docker compose stack; exit 1 = skip (agents / Nix only).
# Skip: ./deploy.sh --ai --no-docker  OR  AI_STACK_DOCKER=0 in environment  OR  ai-stack/.env
set -euo pipefail

STACK_DIR="${AI_STACK_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ENV_FILE="$STACK_DIR/.env"

[[ "${DEPLOY_AI_NO_DOCKER:-}" == "1" ]] && exit 1

if [[ -n "${AI_STACK_DOCKER+x}" ]]; then
  case "${AI_STACK_DOCKER}" in
    0 | false | no | off) exit 1 ;;
    *) exit 0 ;;
  esac
fi

if [[ -f "$ENV_FILE" ]]; then
  line=$(grep -E '^[[:space:]]*AI_STACK_DOCKER=' "$ENV_FILE" 2>/dev/null | tail -1 || true)
  if [[ -n "$line" ]]; then
    val="${line#*=}"
    val="${val%%#*}"
    val="${val//\"/}"
    val="${val//\'/}"
    val="${val#"${val%%[![:space:]]*}"}"
    val="${val%"${val##*[![:space:]]}"}"
    case "$val" in
      0 | false | no | off) exit 1 ;;
    esac
  fi
fi

exit 0
