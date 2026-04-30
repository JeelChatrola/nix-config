#!/bin/bash
# AI deploy orchestration: optional pre-HM stack-models apply, home-manager, Docker, Ollama sync, optional second HM switch.
# Called from repo-root ./deploy.sh after parsing --user / --ai / --no-docker.

set -euo pipefail
cd "$(dirname "$0")/../.."

FLAKE_TARGET="${1:?usage: deploy-stack.sh FLAKE_TARGET}"
export DEPLOY_AI_NO_DOCKER="${DEPLOY_AI_NO_DOCKER:-0}"

hm_switch() {
  # Prefer installed home-manager so repeated switches are fast; bootstrap via nix run if missing.
  if command -v home-manager >/dev/null 2>&1; then
    home-manager switch --flake ".#${FLAKE_TARGET}" --impure
  else
    nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure
  fi
}

if bash ai-stack/scripts/ai-stack-docker-wanted.sh; then
  echo "Applying stack-models.json → models.compose.env + OpenCode vLLM picker (before home-manager)..."
  unset SKIP_OLLAMA_PULL 2>/dev/null || true
  bash ai-stack/scripts/apply-stack-models.sh
  echo ""
else
  echo "Skipping apply-stack-models.sh: only needed for Docker (models.compose.env + provider.vllm). Use ai-up after editing stack-models.json."
  echo ""
fi

echo "Building home-manager configuration ($FLAKE_TARGET)..."
hm_switch

echo ""
echo "Installing MCP helper CLIs (code-review-graph, arxiv, searxng-mcp via uv)..."
bash ai-stack/scripts/install-optional-agents.sh --code-review-graph --arxiv --searxng-mcp
echo ""

if bash ai-stack/scripts/ai-stack-docker-wanted.sh; then
  echo "Starting Docker stack (Ollama, LobeChat, SearXNG)..."
  docker compose --env-file ai-stack/models.compose.env -f ai-stack/docker-compose.yml up -d
  echo ""
  echo "Pulling Ollama models from stack-models.json (if any)..."
  unset SKIP_OLLAMA_PULL 2>/dev/null || true
  bash ai-stack/scripts/apply-stack-models.sh
  echo ""
  echo "Syncing OpenCode Ollama model list from ${OLLAMA_HOST:-http://127.0.0.1:11434}..."
  # sync-opencode-ollama-models.sh rewrites provider.ollama.models from live Ollama /api/tags; HM must redeploy if JSON changes.
  _opencode_json_hash_before=$(sha256sum ai-stack/mcp/opencode.json | awk '{print $1}')
  bash ai-stack/scripts/sync-opencode-ollama-models.sh
  _opencode_json_hash_after=$(sha256sum ai-stack/mcp/opencode.json | awk '{print $1}')
  if [[ "$_opencode_json_hash_before" != "$_opencode_json_hash_after" ]]; then
    echo "opencode.json changed; applying home-manager again..."
    hm_switch
  fi
  echo ""
  echo "Docker stack is up:"
  echo "  Ollama:   http://localhost:11434"
  echo "  LobeChat: http://localhost:3210"
  echo "  SearXNG:  http://localhost:${SEARXNG_PORT:-8080}  (MCP web search)"
  echo ""
  echo "Models:        edit ai-stack/stack-models.json; ollama.pull[] and vllm.model"
  echo "Pull ad-hoc:   ollama-pull <tag>"
else
  echo "Skipping Docker stack (set AI_STACK_DOCKER=0 in ai-stack/.env, or use --no-docker)."
  echo "OpenCode / Claude use configs from home-manager; start containers when you want with: ai-up"
  echo ""
  echo "Note: SearXNG MCP and Ollama-backed providers need the stack running (ai-up) or cloud keys."
fi

echo ""
echo "CLI agents:    claude, opencode"

echo ""
echo "Done. Restart your terminal or run: exec zsh"
