#!/usr/bin/env bash
# Hermes gateway install/run rewrites the user systemd unit to call the inner
# Python venv without bundled plugin paths. A drop-in injects HERMES_BUNDLED_*
# env vars so Discord (and other platform plugins) load on every restart.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HERMES="$(nix build "path:${ROOT}#hermes" --no-link --print-out-paths)"
DROPIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/hermes-gateway.service.d"
DROPIN="${DROPIN_DIR}/50-nix-bundled.conf"

mkdir -p "$DROPIN_DIR"
cat >"$DROPIN" <<EOF
[Service]
Environment="HERMES_BUNDLED_PLUGINS=${HERMES}/share/hermes-agent/plugins"
Environment="HERMES_BUNDLED_SKILLS=${HERMES}/share/hermes-agent/skills"
Environment="HERMES_WEB_DIST=${HERMES}/share/hermes-agent/web_dist"
Environment="HERMES_TUI_DIR=${HERMES}/ui-tui"
EOF

systemctl --user daemon-reload
systemctl --user enable hermes-gateway.service >/dev/null 2>&1 || true
systemctl --user restart hermes-gateway.service

echo "Fixed ${DROPIN}"
echo "  HERMES_BUNDLED_PLUGINS=${HERMES}/share/hermes-agent/plugins"
echo "Re-run after 'nix flake update' changes the hermes store path."
