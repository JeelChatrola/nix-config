#!/usr/bin/env bash
# List or filter OpenRouter catalog models by metadata tags/tier/price.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="${AI_STACK_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CATALOG="$STACK_DIR/config/hermes-openrouter-catalog.json"

usage() {
  cat <<'EOF'
Usage: list-hermes-openrouter-catalog.sh [--tag TAG] [--tier TIER] [--price PRICE]

Examples:
  list-hermes-openrouter-catalog.sh
  list-hermes-openrouter-catalog.sh --tag qwen
  list-hermes-openrouter-catalog.sh --tier S+
  list-hermes-openrouter-catalog.sh --price value

Direct Hermes switch:
  /model openrouter:<id>     e.g. /model qwen3.7-max
EOF
}

TAG=""
TIER=""
PRICE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag) TAG="${2:-}"; shift 2 ;;
    --tier) TIER="${2:-}"; shift 2 ;;
    --price) PRICE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ ! -f "$CATALOG" ]]; then
  echo "missing catalog: $CATALOG" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq required" >&2
  exit 1
fi

jq -r --arg tag "$TAG" --arg tier "$TIER" --arg price "$PRICE" '
  .providers.openrouter.models[]
  | select(
      ($tag == "" or (.metadata.tags // [] | index($tag)))
      and ($tier == "" or .metadata.tier == $tier)
      and ($price == "" or .metadata.price == $price)
    )
  | [
      .metadata.tier,
      .metadata.price,
      ("$" + ((.metadata.blended_usd_per_m // 0) | tostring) + "/M"),
      (.metadata.tags | join(",")),
      .id
    ] | @tsv
' "$CATALOG" | column -t -s $'\t'
