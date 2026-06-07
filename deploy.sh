#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

DEPLOY_USER="${USER}"
WITH_AI=false
DEPLOY_AI_NO_DOCKER=0

usage() {
  echo "Usage: ./deploy.sh [--user LOGIN] [--ai] [--no-docker]"
  echo ""
  echo "  --user LOGIN  Home Manager flake output base name (default: \$USER). Targets .#\$LOGIN or .#\$LOGIN-ai."
  echo "  --ai          AI modules (opencode, hermes, MCP configs, Docker). Restarts Hermes gateway"
  echo "                when installed. Runs ai-stack/scripts/deploy-stack.sh after parsing."
  echo "  --no-docker   With --ai: skip docker compose (Ollama, SearXNG). Same as"
  echo "                AI_STACK_DOCKER=0 in ai-stack/.env — see .env.example."
  echo ""
  echo "  Without --ai: home-manager only for .#\$LOGIN."
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --ai) WITH_AI=true; shift ;;
    --no-docker) DEPLOY_AI_NO_DOCKER=1; shift ;;
    --user)
      if [[ -z "${2:-}" ]]; then echo "--user requires a login name" >&2; exit 1; fi
      DEPLOY_USER="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1 (try --help)" >&2
      exit 1
      ;;
  esac
done

FLAKE_TARGET="$DEPLOY_USER"
if $WITH_AI; then
  FLAKE_TARGET="${DEPLOY_USER}-ai"
fi

hm_switch() {
  # --impure: HM evaluation may reference paths outside the flake (e.g. aiConfigRoot). Inputs stay locked via flake.lock.
  if command -v home-manager >/dev/null 2>&1; then
    home-manager switch --flake ".#${FLAKE_TARGET}" --impure
  else
    nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure
  fi
}

if $WITH_AI; then
  export DEPLOY_AI_NO_DOCKER
  exec bash ai-stack/scripts/deploy-stack.sh "$FLAKE_TARGET"
fi

echo "Building home-manager configuration ($FLAKE_TARGET)..."
hm_switch

echo ""
echo "Done. Restart your terminal or run: exec zsh"
