#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

DEPLOY_USER="${USER}"
WITH_AI=false
DEPLOY_AI_NO_DOCKER=0
FLAKE_PATH="${NIX_CONFIG_DIR:-$ROOT}"
: "${AI_STACK_DIR:=$HOME/ai-stack}"
# Ignore stale session var from when ai-stack lived inside nix-config/
if [[ ! -x "$AI_STACK_DIR/bin/ai-stack" ]]; then
  AI_STACK_DIR="$HOME/ai-stack"
fi

usage() {
  echo "Usage: ./deploy.sh [--user LOGIN] [--ai] [--no-docker]"
  echo ""
  echo "  --user LOGIN  Home Manager flake output base name (default: \$USER). Targets .#\$LOGIN or .#\$LOGIN-ai."
  echo "  --ai          Home Manager *-ai, then \$AI_STACK_DIR/bin/ai-stack deploy."
  echo "  --no-docker   With --ai: skip Docker compose (Ollama, SearXNG)."
  echo ""
  echo "  AI_STACK_DIR  Default: \$HOME/ai-stack (private ai-stack clone)."
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
  if command -v nh >/dev/null 2>&1; then
    nh home switch "$FLAKE_PATH" --configuration "$FLAKE_TARGET" --impure
  else
    nix run nixpkgs#nh -- home switch "$FLAKE_PATH" --configuration "$FLAKE_TARGET" --impure
  fi
}

stage() {
  printf '\n==> [%s/%s] %s\n' "$1" "$2" "$3"
}

if $WITH_AI; then
  if [[ ! -x "$AI_STACK_DIR/bin/ai-stack" ]]; then
    echo "Missing ai-stack at $AI_STACK_DIR" >&2
    echo "Clone: git clone git@github.com:JeelChatrola/ai-stack.git \"$AI_STACK_DIR\"" >&2
    exit 1
  fi
  export AI_STACK_DIR DEPLOY_AI_NO_DOCKER
  stage 1 2 "Apply Home Manager ($FLAKE_TARGET)"
  hm_switch

  stage 2 2 "Deploy AI services"
  "$AI_STACK_DIR/bin/ai-stack" deploy
  printf '\n==> Deploy complete\n'
  echo "    Restart your terminal or run: exec zsh"
  exit 0
fi

stage 1 1 "Apply Home Manager ($FLAKE_TARGET)"
hm_switch

printf '\n==> Deploy complete\n'
echo "    Restart your terminal or run: exec zsh"
