#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

DEPLOY_USER="${USER}"
WITH_AI=false
DEPLOY_AI_NO_DOCKER=0
: "${AI_STACK_DIR:=$HOME/ai-stack}"
# Ignore stale session var from when ai-stack lived inside nix-config/
if [[ ! -x "$AI_STACK_DIR/bin/ai-stack" ]]; then
  AI_STACK_DIR="$HOME/ai-stack"
fi

usage() {
  echo "Usage: ./deploy.sh [--user LOGIN] [--ai] [--no-docker]"
  echo ""
  echo "  --user LOGIN  Home Manager flake output base name (default: \$USER). Targets .#\$LOGIN or .#\$LOGIN-ai."
  echo "  --ai          Home Manager *-ai, then \$AI_STACK_DIR/bin/ai-stack sync + deploy."
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
  if command -v home-manager >/dev/null 2>&1; then
    home-manager switch --flake ".#${FLAKE_TARGET}" --impure
  else
    nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure
  fi
}

if $WITH_AI; then
  if [[ ! -x "$AI_STACK_DIR/bin/ai-stack" ]]; then
    echo "Missing ai-stack at $AI_STACK_DIR" >&2
    echo "Clone: git clone git@github.com:JeelChatrola/ai-stack.git \"$AI_STACK_DIR\"" >&2
    exit 1
  fi
  export AI_STACK_DIR DEPLOY_AI_NO_DOCKER
  echo "Syncing AI stack ($AI_STACK_DIR)..."
  "$AI_STACK_DIR/bin/ai-stack" sync
  echo ""
  echo "Building home-manager configuration ($FLAKE_TARGET)..."
  hm_switch
  echo ""
  echo "Running ai-stack deploy..."
  set +e
  "$AI_STACK_DIR/bin/ai-stack" deploy
  deploy_rc=$?
  set -e
  if [[ "$deploy_rc" -eq 10 ]]; then
    echo "Re-applying home-manager after generated opencode.json changed..."
    hm_switch
  elif [[ "$deploy_rc" -ne 0 ]]; then
    exit "$deploy_rc"
  fi
  echo ""
  echo "Done. Restart your terminal or run: exec zsh"
  exit 0
fi

echo "Building home-manager configuration ($FLAKE_TARGET)..."
hm_switch

echo ""
echo "Done. Restart your terminal or run: exec zsh"
