#!/bin/bash
set -e
cd "$(dirname "$0")"

FLAKE_TARGET="jeel"
WITH_AI=false

for arg in "$@"; do
  case $arg in
    --ai) FLAKE_TARGET="jeel-ai"; WITH_AI=true ;;
    -h|--help)
      echo "Usage: ./deploy.sh [--ai]"
      echo ""
      echo "  --ai    Include AI tools (claude, opencode), MCP configs,"
      echo "          commands/agents, uv MCP CLIs (code-review-graph, arxiv, searxng-mcp),"
      echo "          Docker (Ollama, LobeChat, SearXNG). GSD: opt-in — see README."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (try --help)"
      exit 1
      ;;
  esac
done

if $WITH_AI; then
  echo "Applying stack-models.json → models.compose.env + OpenCode vLLM picker (before home-manager)..."
  bash ai-stack/scripts/apply-stack-models.sh
  echo ""
fi

echo "Building home-manager configuration ($FLAKE_TARGET)..."
nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure

if $WITH_AI; then
  echo ""
  echo "Installing MCP helper CLIs (code-review-graph, arxiv, searxng-mcp via uv)..."
  bash ai-stack/scripts/install-optional-agents.sh --code-review-graph --arxiv --searxng-mcp
  echo ""
  echo "Starting AI stack (Ollama, LobeChat, SearXNG)..."
  docker compose --env-file ai-stack/models.compose.env -f ai-stack/docker-compose.yml up -d
  echo ""
  echo "Pulling Ollama models from stack-models.json (if any)..."
  bash ai-stack/scripts/apply-stack-models.sh
  echo ""
  echo "Syncing OpenCode Ollama model list from ${OLLAMA_HOST:-http://127.0.0.1:11434}..."
  _opencode_json_hash_before=$(sha256sum ai-stack/mcp/opencode.json | awk '{print $1}')
  bash ai-stack/scripts/sync-opencode-ollama-models.sh
  _opencode_json_hash_after=$(sha256sum ai-stack/mcp/opencode.json | awk '{print $1}')
  if [[ "$_opencode_json_hash_before" != "$_opencode_json_hash_after" ]]; then
    echo "opencode.json changed; applying home-manager again..."
    nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure
  fi
  echo ""
  echo "AI stack is running:"
  echo "  Ollama:   http://localhost:11434"
  echo "  LobeChat: http://localhost:3210"
  echo "  SearXNG:  http://localhost:${SEARXNG_PORT:-8080}  (MCP web search)"
  echo ""
  echo "Models:        edit ai-stack/stack-models.json; ollama.pull[] and vllm.model"
  echo "Pull ad-hoc:   ollama-pull <tag>"
  echo "CLI agents:    claude, opencode"
fi

echo ""
echo "Done. Restart your terminal or run: exec zsh"
