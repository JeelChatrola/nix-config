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
      echo "          custom commands/agents, optional stacks installer"
      echo "          (GSD, code-review-graph, arxiv), and start Docker"
      echo "          services (Ollama, LobeChat, SearXNG)"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (try --help)"
      exit 1
      ;;
  esac
done

echo "Building home-manager configuration ($FLAKE_TARGET)..."
nix run nixpkgs#home-manager -- switch --flake ".#${FLAKE_TARGET}" --impure

if $WITH_AI; then
  echo ""
  echo "Installing optional agent stacks (GSD, code-review-graph, arxiv)..."
  bash ai-stack/scripts/install-optional-agents.sh --all
  echo ""
  echo "Starting AI stack (Ollama, LobeChat, SearXNG)..."
  docker compose -f ai-stack/docker-compose.yml up -d
  echo ""
  echo "AI stack is running:"
  echo "  Ollama:   http://localhost:11434"
  echo "  LobeChat: http://localhost:3210"
  echo ""
  echo "Pull a model:  ollama-pull llama3.2"
  echo "CLI agents:    claude, opencode"
fi

echo ""
echo "Done. Restart your terminal or run: exec zsh"
