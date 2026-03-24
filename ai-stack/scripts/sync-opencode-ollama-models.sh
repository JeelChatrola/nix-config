#!/usr/bin/env bash
# Set provider.ollama.models to match Ollama /api/tags exactly (same keys, same order).
# Reuses existing "name" for tags still present; new tags get { "name": "<tag>" }.
# Safe to run when Ollama is down: exits 0 without modifying the file.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG="${REPO_ROOT}/ai-stack/mcp/opencode.json"
OLLAMA="${OLLAMA_HOST:-http://127.0.0.1:11434}"

if [[ ! -f "$CONFIG" ]]; then
  echo "sync-opencode-ollama-models: missing $CONFIG" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "sync-opencode-ollama-models: jq not found; install jq or run from a shell that has it" >&2
  exit 1
fi

if ! tags_json="$(curl -sfS --max-time 5 "${OLLAMA}/api/tags" | jq -c '[.models[].name]')"; then
  echo "sync-opencode-ollama-models: Ollama not reachable at ${OLLAMA} (skip model sync)" >&2
  exit 0
fi

tmp="${CONFIG}.tmp.$$"
jq --argjson tags "$tags_json" '
  .provider.ollama.models as $old |
  .provider.ollama.models = (
    reduce $tags[] as $t ({}; .[$t] = ($old[$t] // { name: $t }))
  )
' "$CONFIG" >"$tmp"
mv "$tmp" "$CONFIG"
echo "sync-opencode-ollama-models: updated provider.ollama.models from Ollama ($(jq length <<<"$tags_json") tags)"
