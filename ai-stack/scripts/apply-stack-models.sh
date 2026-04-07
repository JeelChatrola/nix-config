#!/usr/bin/env bash
# Read ai-stack/stack-models.json → write models.compose.env for Docker vLLM,
# patch provider.vllm.models in mcp/opencode.json, and optionally ollama pull.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STACK_DIR="${REPO_ROOT}/ai-stack"
CONFIG_JSON="${STACK_MODELS_JSON:-${STACK_DIR}/stack-models.json}"
OUT_ENV="${STACK_DIR}/models.compose.env"
OPENCODE_JSON="${STACK_DIR}/mcp/opencode.json"

usage() {
  echo "Usage: apply-stack-models.sh [--help] [--no-pull]"
  echo "  Reads ${CONFIG_JSON#$REPO_ROOT/}"
  echo "  Writes ${OUT_ENV#$REPO_ROOT/} (VLLM_*, for docker compose)"
  echo "  Updates provider.vllm.models in mcp/opencode.json"
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

vmodel="$(jq -r '.vllm.model // empty' "$CONFIG_JSON")"
if [[ -z "$vmodel" ]]; then
  echo "apply-stack-models: .vllm.model is required in $CONFIG_JSON" >&2
  exit 1
fi

jit="$(jq -r '.vllm.image_tag // "v0.19.0"' "$CONFIG_JSON")"
vport="$(jq '.vllm.port // 8000' "$CONFIG_JSON")"
vmax="$(jq '.vllm.max_model_len // 8192' "$CONFIG_JSON")"
vgpu="$(jq -r '.vllm.gpu_memory_utilization // 0.9' "$CONFIG_JSON")"

umask 077
{
  echo "VLLM_MODEL=${vmodel}"
  echo "VLLM_IMAGE_TAG=${jit}"
  echo "VLLM_PORT=${vport}"
  echo "VLLM_MAX_MODEL_LEN=${vmax}"
  echo "VLLM_GPU_MEMORY_UTILIZATION=${vgpu}"
} >"$OUT_ENV"
echo "apply-stack-models: wrote ${OUT_ENV#$REPO_ROOT/}"

if [[ ! -f "$OPENCODE_JSON" ]]; then
  echo "apply-stack-models: missing $OPENCODE_JSON (skip OpenCode vLLM sync)" >&2
else
  display="$(jq -r '.opencode.vllm_display_name // empty' "$CONFIG_JSON")"
  if [[ -z "$display" || "$display" == "null" ]]; then
    display="${vmodel} (vLLM)"
  fi
  vbase="http://localhost:${vport}/v1"
  tmp="${OPENCODE_JSON}.tmp.$$"
  jq --arg m "$vmodel" --arg d "$display" --arg b "$vbase" \
    '.provider.vllm.models = { ($m): { name: $d } } |
     .provider.vllm.options.baseURL = $b' "$OPENCODE_JSON" >"$tmp"
  mv "$tmp" "$OPENCODE_JSON"
  echo "apply-stack-models: set provider.vllm (baseURL $vbase, model \"$vmodel\") in mcp/opencode.json"
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
