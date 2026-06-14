#!/usr/bin/env bash
# Point Hermes OpenRouter /model picker at a minimal local catalog in ai-stack/config/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CATALOG="$STACK_DIR/config/hermes-openrouter-catalog.json"
DEST="${HERMES_CONFIG:-$HOME/.hermes/config.yaml}"

if [[ ! -f "$CATALOG" ]]; then
  echo "sync-hermes-model-catalog: missing $CATALOG" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "sync-hermes-model-catalog: yq not found; catalog at $CATALOG not merged" >&2
  exit 0
fi

if [[ ! -f "$DEST" ]]; then
  echo "sync-hermes-model-catalog: missing $DEST (run hermes setup first)" >&2
  exit 1
fi

if ! yq eval '.' "$DEST" >/dev/null; then
  echo "sync-hermes-model-catalog: $DEST is not valid YAML" >&2
  exit 1
fi

FILE_URL="file://${CATALOG}"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

yq eval -o=yaml "
  .model_catalog.enabled = true |
  .model_catalog.providers.openrouter.url = \"${FILE_URL}\"
" "$DEST" >"$TMP"

if cmp -s "$TMP" "$DEST"; then
  echo "sync-hermes-model-catalog: $DEST already up to date"
else
  mv "$TMP" "$DEST"
  echo "sync-hermes-model-catalog: OpenRouter picker limited via $CATALOG"
fi

# Drop stale picker caches so the new list shows immediately.
rm -f "${HOME}/.hermes/provider_models_cache.json"
rm -f "${HOME}/.hermes/cache/model_catalog.json"

if command -v jq >/dev/null 2>&1; then
  count="$(jq '.providers.openrouter.models | length' "$CATALOG")"
  echo "sync-hermes-model-catalog: ${count} OpenRouter models (tagged). Filter: bash ${SCRIPT_DIR}/list-hermes-openrouter-catalog.sh --tag qwen"
fi
