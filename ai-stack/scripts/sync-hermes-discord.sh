#!/usr/bin/env bash
# Merge ai-stack Hermes profile templates into ~/.hermes/config.yaml.
# Copy versioned SOUL.md into ~/.hermes/SOUL.md.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
DEST="${HERMES_CONFIG:-$HOME/.hermes/config.yaml}"
SOUL_SRC="${HERMES_SOUL_SRC:-$STACK_DIR/config/hermes-SOUL.md}"
SOUL_DEST="${HERMES_SOUL_DEST:-$HOME/.hermes/SOUL.md}"

TEMPLATES=(
  "$STACK_DIR/config/hermes-skills.template.yaml"
  "$STACK_DIR/config/hermes-tools.template.yaml"
  "$STACK_DIR/config/hermes-discord.template.yaml"
)

if ! command -v yq >/dev/null 2>&1; then
  echo "sync-hermes-discord: yq not found; templates not merged into $DEST" >&2
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
cp "$DEST" "$TMP"

for src in "${TEMPLATES[@]}"; do
  if [[ ! -f "$src" ]]; then
    echo "sync-hermes-discord: missing $src" >&2
    exit 1
  fi
  yq eval-all '. as $item ireduce ({}; . * $item)' "$TMP" "$src" >"${TMP}.next"
  mv "${TMP}.next" "$TMP"
done

# Drop legacy per-platform skill filter so global skills.disabled applies everywhere.
yq eval -i 'del(.skills.platform_disabled)' "$TMP"

if cmp -s "$TMP" "$DEST"; then
  echo "sync-hermes-discord: $DEST already up to date"
else
  mv "$TMP" "$DEST"
  echo "sync-hermes-discord: merged Hermes profile templates into $DEST"
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
