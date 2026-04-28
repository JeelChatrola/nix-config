#!/usr/bin/env bash
# Render ai-stack/config/*.template.json → ai-stack/generated/*.json
# Substitutes __SEARXNG_URL__ from SEARXNG_PORT in ai-stack/.env (default 8080).
# Merges stack-models.json ollama.pull[] into OpenCode provider.ollama.models.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
GEN_DIR="$STACK_DIR/generated"
CONFIG_JSON="${STACK_MODELS_JSON:-$STACK_DIR/stack-models.json}"

searxng_port_from_env() {
  local line val
  searxng_port=8080
  [[ -f "$STACK_DIR/.env" ]] || return 0
  line=$(grep -E '^[[:space:]]*SEARXNG_PORT=' "$STACK_DIR/.env" 2>/dev/null | tail -1 || true)
  [[ -z "${line:-}" ]] && return 0
  val="${line#*=}"
  val="${val%%#*}"
  val="${val//\"/}"
  val="${val//\'/}"
  val="${val#"${val%%[![:space:]]*}"}"
  val="${val%"${val##*[![:space:]]}"}"
  [[ -n "$val" ]] && searxng_port="$val"
}

if ! command -v jq >/dev/null 2>&1; then
  echo "render-mcp-templates: jq required" >&2
  exit 1
fi

searxng_port_from_env
SEARXNG_URL="http://127.0.0.1:${searxng_port}"
mkdir -p "$GEN_DIR"

subst_url() {
  jq --arg url "$SEARXNG_URL" 'walk(if . == "__SEARXNG_URL__" then $url else . end)' "$1"
}

subst_url "$STACK_DIR/config/claude-settings.template.json" >"$GEN_DIR/claude-settings.json"
echo "render-mcp-templates: wrote generated/claude-settings.json (SEARXNG_URL=$SEARXNG_URL)"

subst_url "$STACK_DIR/config/mcpo.template.json" >"$GEN_DIR/mcpo-config.json"
echo "render-mcp-templates: wrote generated/mcpo-config.json"

TMP1="$GEN_DIR/opencode.step1.json"
subst_url "$STACK_DIR/config/opencode.template.json" >"$TMP1"

SM_TMP="$(mktemp)"
trap 'rm -f "$SM_TMP"' EXIT
if [[ -f "$CONFIG_JSON" ]] && jq empty "$CONFIG_JSON" 2>/dev/null; then
  jq -c '{ollama: {pull: (.ollama.pull // [])}}' "$CONFIG_JSON" >"$SM_TMP"
else
  echo '{"ollama":{"pull":[]}}' >"$SM_TMP"
fi

jq --slurpfile sm "$SM_TMP" '
  .provider.ollama.models as $m |
  .provider.ollama.models = (
    reduce ($sm[0].ollama.pull // [])[] as $t ($m // {};
      if ($t | type) == "string" and ($t | length) > 0 then
        .[$t] = (.[$t] // {name: $t})
      else . end
    )
  )
' "$TMP1" >"$GEN_DIR/opencode.json"
rm -f "$TMP1"
echo "render-mcp-templates: wrote generated/opencode.json"
