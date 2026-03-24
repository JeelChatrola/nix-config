#!/usr/bin/env bash
# Optional third-party agent stacks (not vendored in this repo).
# ./deploy.sh --ai runs --code-review-graph, --arxiv, --searxng-mcp (MCP wired in ai-stack/mcp/).
# Run --gsd or --all yourself if you want Get Shit Done (third-party npx installer).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  echo "Usage: $0 [--gsd] [--code-review-graph] [--arxiv] [--searxng-mcp] [--all]"
  echo ""
  echo "  --gsd                  Get Shit Done — spec-driven workflow for Claude Code + OpenCode"
  echo "                         https://github.com/gsd-build/get-shit-done"
  echo "  --code-review-graph    Token-efficient code graph MCP (Python + uv)"
  echo "                         https://github.com/tirth8205/code-review-graph"
  echo "  --arxiv                arXiv search/read MCP (uv)"
  echo "                         https://github.com/blazickjp/arxiv-mcp-server"
  echo "  --searxng-mcp          Web search MCP via local SearXNG (PyPI: searxng-mcp-server)"
  echo "  --all                  All of the above"
  echo ""
  echo "GSD: installs into ~/.claude/ and ~/.config/opencode/ via upstream npx installer."
  echo "code-review-graph: uv tool install + registers MCP (merges with your Claude config)."
  echo ""
  echo "Everything Claude Code (huge plugin pack) is not scripted here — use Claude's plugin UI:"
  echo "  /plugin marketplace add affaan-m/everything-claude-code"
  echo "  https://github.com/affaan-m/everything-claude-code"
}

do_gsd() {
  echo "==> Installing GSD (Get Shit Done)..."
  if ! command -v npx >/dev/null 2>&1; then
    echo "npx not found. Install nodejs (Home Manager already provides it after deploy)." >&2
    exit 1
  fi
  npx --yes get-shit-done-cc@latest --claude --global
  npx --yes get-shit-done-cc@latest --opencode --global
  echo "    Claude Code: try /gsd:help"
  echo "    OpenCode:    try /gsd-help"
}

do_crg() {
  echo "==> Installing code-review-graph CLI (uv tool)..."
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv not found. Add uv to Home Manager packages." >&2
    exit 1
  fi
  uv tool install code-review-graph
  echo "    MCP is already declared in this repo (ai-stack/mcp/*) via: uv tool run ... code-review-graph serve"
  echo "    Run ./deploy.sh or home-manager switch, then restart the agent."
  echo "    Optional: for upstream plugin + extra hooks, see https://github.com/tirth8205/code-review-graph"
}

do_arxiv() {
  echo "==> Installing arxiv-mcp-server (uv tool)..."
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv not found." >&2
    exit 1
  fi
  uv tool install arxiv-mcp-server
  echo "    MCP wired in ai-stack/mcp/*. Papers cache: ~/.arxiv-mcp-server/papers (or ARXIV_STORAGE_PATH)"
}

do_searxng_mcp() {
  echo "==> Installing searxng-mcp-server (uv tool)..."
  if ! command -v uv >/dev/null 2>&1; then
    echo "uv not found." >&2
    exit 1
  fi
  uv tool install searxng-mcp-server
  echo "    MCP wired in ai-stack/mcp/* via: uv tool run searxng-mcp-server --searxng-url http://127.0.0.1:8080"
  echo "    Start SearXNG (./deploy.sh --ai or ai-up). Override port: SEARXNG_PORT in ai-stack/.env + same URL in mcp configs."
  echo "    One-shot without install: uvx --from searxng-mcp-server searxng-mcp-server --searxng-url http://127.0.0.1:8080"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

for arg in "$@"; do
  case $arg in
    --gsd) do_gsd ;;
    --code-review-graph) do_crg ;;
    --arxiv) do_arxiv ;;
    --searxng-mcp) do_searxng_mcp ;;
    --all)
      do_gsd
      do_crg
      do_arxiv
      do_searxng_mcp
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown: $arg"; usage; exit 1 ;;
  esac
done

echo "Done."
