#!/usr/bin/env bash
# Restart Hermes gateway after deploy/sync so MCP config and Nix plugin paths are live.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE="${XDG_CONFIG_HOME:-$HOME}/.config/systemd/user/hermes-gateway.service"

if [[ ! -f "$SERVICE" ]]; then
  echo "hermes-gateway: not installed (skip). First time: hermes setup && hermes gateway install"
  exit 0
fi

bash "$SCRIPT_DIR/fix-hermes-gateway-service.sh"
