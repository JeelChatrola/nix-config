#!/usr/bin/env bash
set -euo pipefail

command_name="${0##*/}"
printf '%q ' "$command_name" "$@" >> "$COMMAND_LOG"
printf '\n' >> "$COMMAND_LOG"

if [[ "$command_name" == nix && "${1:-}" == flake ]]; then
  [[ $# == 4 && "$2" == update && "$3" == --flake ]] || exit 99
  printf 'updated\n' > "$4/flake.lock"
  exit "${UPDATE_STATUS:-0}"
fi
exit "${SWITCH_STATUS:-0}"
