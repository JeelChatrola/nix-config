#!/usr/bin/env bash
# Read ai-stack/stack-models.json → optional ollama pull when the container is running.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CONFIG_JSON="${STACK_MODELS_JSON:-${STACK_DIR}/stack-models.json}"

usage() {
  echo "Usage: apply-stack-models.sh [--help] [--no-pull]"
  echo "  Reads ${CONFIG_JSON}"
  echo "  Ollama pull: runs when the ollama container is running, unless --no-pull or SKIP_OLLAMA_PULL=1"
}

NO_PULL=0
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if [[ "${1:-}" == "--no-pull" ]]; then
  NO_PULL=1
  shift
fi

if [[ ! -f "$CONFIG_JSON" ]]; then
  echo "apply-stack-models: missing $CONFIG_JSON" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "apply-stack-models: jq not found" >&2
  exit 1
fi

if ! jq empty "$CONFIG_JSON" 2>/dev/null; then
  echo "apply-stack-models: invalid JSON: $CONFIG_JSON" >&2
  exit 1
fi

if [[ "$NO_PULL" == 1 || "${SKIP_OLLAMA_PULL:-0}" == "1" ]]; then
  echo "apply-stack-models: skipping ollama pull (--no-pull or SKIP_OLLAMA_PULL=1)"
elif docker ps --format '{{.Names}}' 2>/dev/null | grep -qx 'ollama'; then
  while IFS= read -r tag; do
    [[ -z "$tag" ]] && continue
    echo "apply-stack-models: ollama pull $tag"
    docker exec ollama ollama pull "$tag" || echo "apply-stack-models: warning: pull failed for $tag" >&2
  done < <(jq -r '.ollama.pull[]? | select(length > 0)' "$CONFIG_JSON")
else
  echo "apply-stack-models: ollama container not running (skip ollama pull); start stack then re-run or use deploy.sh --ai"
fi