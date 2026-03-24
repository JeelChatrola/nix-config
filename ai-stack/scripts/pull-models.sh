#!/usr/bin/env bash
# Pull models declared in YAML (Ollama library / hf.co, or llmfit HF GGUF download).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${MODEL_CONFIG:-$ROOT/config/models.yaml}"
DRY_RUN=false

usage() {
  echo "Usage: $0 [--config PATH] [--dry-run]"
  echo ""
  echo "  MODEL_CONFIG   Override default config path (default: ai-stack/config/models.yaml)"
  echo "  OLLAMA_HOST    If Ollama runs in Docker: export OLLAMA_HOST=http://127.0.0.1:11434"
  echo "  HF_TOKEN       Optional; for gated or rate-limited Hugging Face downloads"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown: $1" >&2; usage >&2; exit 1 ;;
  esac
done

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing '$1'. Install via Nix / Home Manager (yq-go, jq, ollama client)." >&2
    exit 1
  }
}

need_cmd yq
need_cmd jq

if [[ ! -f "$CONFIG" ]]; then
  echo "Config not found: $CONFIG" >&2
  echo "Copy ai-stack/config/models.example.yaml to ai-stack/config/models.yaml" >&2
  exit 1
fi

if ! yq -e '.version' "$CONFIG" >/dev/null 2>&1; then
  echo "Invalid YAML or missing 'version' key: $CONFIG" >&2
  exit 1
fi

json=$(yq -o=json "$CONFIG")
if ! echo "$json" | jq -e '.models | type == "array"' >/dev/null 2>&1; then
  echo "Invalid config: 'models' must be a list in $CONFIG" >&2
  exit 1
fi
n=$(echo "$json" | jq '.models | length')
if [[ "$n" -eq 0 ]]; then
  echo "No models: add entries under 'models' in $CONFIG" >&2
  exit 1
fi

ollama_has_model() {
  local ref="$1"
  command -v ollama >/dev/null 2>&1 || return 1
  ollama list 2>/dev/null | awk 'NR>1 {print $1}' | grep -Fxq "$ref"
}

run_ollama_pull() {
  local ref="$1"
  if $DRY_RUN; then
    echo "[dry-run] ollama pull $ref"
    return 0
  fi
  need_cmd ollama
  echo "==> ollama pull $ref"
  ollama pull "$ref"
}

run_llmfit_download() {
  local repo="$1"
  local quant="${2:-}"
  if $DRY_RUN; then
    echo "[dry-run] llmfit download $repo ${quant:+-q $quant}"
    return 0
  fi
  need_cmd llmfit
  echo "==> llmfit download $repo ${quant:+(quant $quant)}"
  if [[ -n "$quant" ]]; then
    llmfit download -q "$quant" "$repo"
  else
    llmfit download "$repo"
  fi
  echo "    (GGUF via llmfit — use a Modelfile + 'ollama create' if you need this inside Ollama.)"
}

while IFS= read -r entry; do
  id=$(echo "$entry" | jq -r '.id // "unnamed"')
  source=$(echo "$entry" | jq -r '.source // empty')
  skip=$(echo "$entry" | jq -r '.skip_if_present // false')

  echo ""
  echo "--- [$id] source=$source ---"

  case "$source" in
    ollama)
      pull=$(echo "$entry" | jq -r '.pull // empty')
      if [[ -z "$pull" ]]; then
        echo "    skip: missing 'pull' for ollama" >&2
        continue
      fi
      if [[ "$skip" == "true" ]] && ollama_has_model "$pull"; then
        echo "    skip: already present ($pull)"
        continue
      fi
      run_ollama_pull "$pull"
      ;;
    huggingface)
      provider=$(echo "$entry" | jq -r '.provider // "llmfit"')
      repo=$(echo "$entry" | jq -r '.repo // empty')
      quant=$(echo "$entry" | jq -r '.quant // empty')
      if [[ -z "$repo" ]]; then
        echo "    skip: huggingface entry needs 'repo' (user/repo-GGUF)" >&2
        continue
      fi
      case "$provider" in
        llmfit)
          run_llmfit_download "$repo" "$quant"
          ;;
        ollama)
          ref="hf.co/${repo}"
          if [[ -n "$quant" ]]; then
            ref="${ref}:${quant}"
          fi
          if [[ "$skip" == "true" ]] && ollama_has_model "$ref"; then
            echo "    skip: already present ($ref)"
            continue
          fi
          run_ollama_pull "$ref"
          ;;
        *)
          echo "    skip: unknown provider '$provider' (use llmfit or ollama)" >&2
          ;;
      esac
      ;;
    *)
      echo "    skip: unknown source '$source' (use ollama or huggingface)" >&2
      ;;
  esac
done < <(echo "$json" | jq -c '.models[]')

echo ""
echo "Done."
