#!/usr/bin/env bash
# Merge generated Hermes MCP servers into ~/.hermes/config.yaml.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC="${HERMES_MCP_GENERATED:-$STACK_DIR/generated/hermes-mcp.yaml}"
DEST="${HERMES_CONFIG:-$HOME/.hermes/config.yaml}"

if [[ ! -f "$SRC" ]]; then
  echo "sync-hermes-mcp: missing $SRC (run ai-stack sync first)" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "sync-hermes-mcp: yq not found; generated Hermes MCP config at $SRC but did not merge into $DEST" >&2
  exit 0
fi

mkdir -p "$(dirname "$DEST")"
if [[ ! -f "$DEST" ]]; then
  printf '{}\n' >"$DEST"
fi

if ! yq eval '.' "$DEST" >/dev/null; then
  echo "sync-hermes-mcp: $DEST is not valid YAML; leaving it unchanged" >&2
  exit 1
fi

if ! yq eval '.mcp_servers' "$SRC" >/dev/null; then
  echo "sync-hermes-mcp: $SRC does not contain mcp_servers" >&2
  exit 1
fi

BACKUP="$DEST.ai-stack.bak"
if [[ ! -f "$BACKUP" ]]; then
  cp "$DEST" "$BACKUP"
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

yq eval-all '. as $item ireduce ({}; . * $item)' "$DEST" "$SRC" >"$TMP"

if cmp -s "$TMP" "$DEST"; then
  echo "sync-hermes-mcp: $DEST already up to date"
else
  mv "$TMP" "$DEST"
  echo "sync-hermes-mcp: merged generated/hermes-mcp.yaml into $DEST"
fi
