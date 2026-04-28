#!/bin/bash
set -e
cd "$(dirname "$0")"

DEPLOY_USER="${USER}"
WITH_AI=false
DEPLOY_AI_NO_DOCKER=0

usage() {
  echo "Usage: ./deploy.sh [--user LOGIN] [--ai] [--no-docker]"
  echo ""
  echo "  --user LOGIN  Home Manager flake output base name (default: \$USER). Targets .#\$LOGIN or .#\$LOGIN-ai."
  echo "  --ai          Same login with AI modules ( claude, opencode, MCP configs, agents ). Target .#\${LOGIN}-ai."
  echo "  --no-docker   With --ai: skip docker compose (Ollama, Lobe, SearXNG). Same as"
  echo "                AI_STACK_DOCKER=0 in ai-stack/.env — see .env.example."
  echo ""
  echo "  Without --ai: home-manager only for .#\$LOGIN (no AI packages)."
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --ai) WITH_AI=true; shift ;;
    --no-docker) DEPLOY_AI_NO_DOCKER=1; shift ;;
    --user)
      if [[ -z "${2:-}" ]]; then echo "--user requires a login name" >&2; exit 1; fi
      DEPLOY_USER="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1 (try --help)" >&2
      exit 1
      ;;
  esac
done

FLAKE_TARGET="$DEPLOY_USER"
if $WITH_AI; then
  FLAKE_TARGET="${DEPLOY_USER}-ai"
fi

if $WITH_AI; then
  export DEPLOY_AI_NO_DOCKER
  if bash ai-stack/scripts/ai-stack-docker-wanted.sh; then
    echo "Applying stack-models.json → models.compose.env + OpenCode vLLM picker (before home-manager)..."
    unset SKIP_OLLAMA_PULL 2>/dev/null || true
    bash ai-stack/scripts/apply-stack-models.sh
    echo ""
  else
    echo "Skipping apply-stack-models.sh: only needed for Docker (models.compose.env + provider.vllm). Use ai-up after editing stack-models.json."
    echo ""
  fi
fi

echo "Building home-manager configuration ($FLAKE_TARGET)..."
nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure

if $WITH_AI; then
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
    _opencode_json_hash_before=$(sha256sum ai-stack/mcp/opencode.json | awk '{print $1}')
    bash ai-stack/scripts/sync-opencode-ollama-models.sh
    _opencode_json_hash_after=$(sha256sum ai-stack/mcp/opencode.json | awk '{print $1}')
    if [[ "$_opencode_json_hash_before" != "$_opencode_json_hash_after" ]]; then
      echo "opencode.json changed; applying home-manager again..."
      nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure
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
fi

echo ""
echo "Done. Restart your terminal or run: exec zsh"
