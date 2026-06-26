#!/usr/bin/env bash
# Merge ai-stack Discord channel prompts + skill filters into ~/.hermes/config.yaml.
# Copy versioned SOUL.md into ~/.hermes/SOUL.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC="${HERMES_DISCORD_TEMPLATE:-$STACK_DIR/config/hermes-discord.template.yaml}"
SOUL_SRC="${HERMES_SOUL_SRC:-$STACK_DIR/config/hermes-SOUL.md}"
DEST="${HERMES_CONFIG:-$HOME/.hermes/config.yaml}"
SOUL_DEST="${HERMES_SOUL_DEST:-$HOME/.hermes/SOUL.md}"

if [[ ! -f "$SRC" ]]; then
  echo "sync-hermes-discord: missing $SRC" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "sync-hermes-discord: yq not found; template at $SRC but did not merge into $DEST" >&2
  exit 0
fi

mkdir -p "$(dirname "$DEST")"
if [[ ! -f "$DEST" ]]; then
  printf '{}\n' >"$DEST"
fi

if ! yq eval '.' "$DEST" >/dev/null; then
  echo "sync-hermes-discord: $DEST is not valid YAML; leaving it unchanged" >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

yq eval-all '. as $item ireduce ({}; . * $item)' "$DEST" "$SRC" >"$TMP"

if cmp -s "$TMP" "$DEST"; then
  echo "sync-hermes-discord: $DEST already up to date"
else
  mv "$TMP" "$DEST"
  echo "sync-hermes-discord: merged hermes-discord.template.yaml into $DEST"
fi

if [[ -f "$SOUL_SRC" ]]; then
  mkdir -p "$(dirname "$SOUL_DEST")"
  if [[ ! -f "$SOUL_DEST" ]] || ! cmp -s "$SOUL_SRC" "$SOUL_DEST"; then
    cp "$SOUL_SRC" "$SOUL_DEST"
    echo "sync-hermes-discord: updated $SOUL_DEST"
  else
    echo "sync-hermes-discord: $SOUL_DEST already up to date"
  fi
fi
