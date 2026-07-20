#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PATH="${NIX_CONFIG_DIR:-$ROOT}"
DEPLOY_USER="${USER:?USER must be set}"
HOST=""

usage() {
  echo "Usage: ./deploy.sh --host HOST"
  echo ""
  echo "Applies Home Manager configuration USER@HOST (USER defaults to \$USER)."
  echo "Set NIX_CONFIG_DIR when the checkout is not at the script location."
  echo "AI services are deployed separately with: ai-stack deploy"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --host)
      if [[ -z "${2:-}" ]]; then
        echo "--host requires a host name" >&2
        exit 1
      fi
      HOST="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (try --help)" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$HOST" ]]; then
  echo "--host is required (for example: ./deploy.sh --host main-workstation)" >&2
  exit 1
fi

FLAKE_TARGET="$DEPLOY_USER@$HOST"
printf '==> Applying Home Manager (%s)\n' "$FLAKE_TARGET"

if command -v nh >/dev/null 2>&1; then
  nh home switch "$FLAKE_PATH" --configuration "$FLAKE_TARGET"
else
  nix run "$FLAKE_PATH#nh" -- home switch "$FLAKE_PATH" --configuration "$FLAKE_TARGET"
fi

printf '\n==> Deploy complete\n'
echo "    Restart your terminal or run: exec zsh"
