#!/usr/bin/env bash
set -euo pipefail

deploy_source="$1"
refresh="$2"
upgrade="$3"
mock_command="$4"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/nix-config" "$tmp/custom checkout" "$tmp/unrelated"
cp "$deploy_source" "$tmp/home/nix-config/deploy.sh"
cp "$deploy_source" "$tmp/custom checkout/deploy.sh"
ln -s "$(command -v dirname)" "$tmp/bin/dirname"
ln -s "$mock_command" "$tmp/bin/nix"
ln -s "$mock_command" "$tmp/bin/nh"
export HOME="$tmp/home" USER=tester COMMAND_LOG="$tmp/commands"
unset NIX_CONFIG_DIR UPDATE_STATUS SWITCH_STATUS
cd "$tmp/unrelated"

run() {
  local expected_status="$1"
  shift
  local status=0
  : > "$COMMAND_LOG"
  PATH="$tmp/bin" "$@" > "$tmp/output" 2>&1 || status=$?
  if [[ "$status" != "$expected_status" ]]; then
    cat "$tmp/output" >&2
    printf 'Expected status %s, got %s\n' "$expected_status" "$status" >&2
    exit 1
  fi
}

expect_commands() {
  local actual
  actual="$(<"$COMMAND_LOG")"
  if [[ "$actual" != "$1" ]]; then
    printf 'Expected commands:\n%s\nActual commands:\n%s\n' "$1" "$actual" >&2
    exit 1
  fi
}

for args in missing missing-value empty option unknown trailing; do
  case "$args" in
    missing) set -- --update ;;
    missing-value) set -- --update --host ;;
    empty) set -- --update --host "" ;;
    option) set -- --host --update ;;
    unknown) set -- --update --unknown ;;
    trailing) set -- --update --host main-workstation --unknown ;;
  esac
  run 1 "$BASH" "$tmp/home/nix-config/deploy.sh" "$@"
  expect_commands ""
  [[ ! -e "$HOME/nix-config/flake.lock" ]]
done
run 0 "$upgrade" --help
expect_commands ""
run 1 "$upgrade"
expect_commands ""

printf -v switch '%q ' nh home switch "$HOME/nix-config" --configuration tester@main-workstation
run 0 "$BASH" "$HOME/nix-config/deploy.sh" --host main-workstation
expect_commands "$switch"
run 0 "$refresh" --host main-workstation
expect_commands "$switch"
[[ ! -e "$HOME/nix-config/flake.lock" ]]

printf -v update '%q ' nix flake update --flake "$HOME/nix-config"
run 0 "$upgrade" --host main-workstation
expect_commands "$update"$'\n'"$switch"

export NIX_CONFIG_DIR="$tmp/custom checkout"
printf -v update '%q ' nix flake update --flake "$NIX_CONFIG_DIR"
printf -v switch '%q ' nh home switch "$NIX_CONFIG_DIR" --configuration tester@main-workstation
run 0 "$refresh" --host main-workstation
expect_commands "$switch"
run 0 "$upgrade" --host main-workstation
expect_commands "$update"$'\n'"$switch"
run 0 "$BASH" "$HOME/nix-config/deploy.sh" --host main-workstation --update
expect_commands "$update"$'\n'"$switch"

export UPDATE_STATUS=42
rm "$NIX_CONFIG_DIR/flake.lock"
run 42 "$upgrade" --host main-workstation
expect_commands "$update"
[[ "$(<"$NIX_CONFIG_DIR/flake.lock")" == updated ]]
unset UPDATE_STATUS
export SWITCH_STATUS=43
rm "$NIX_CONFIG_DIR/flake.lock"
run 43 "$upgrade" --host main-workstation
expect_commands "$update"$'\n'"$switch"
[[ "$(<"$NIX_CONFIG_DIR/flake.lock")" == updated ]]
unset SWITCH_STATUS

rm "$tmp/bin/nh"
printf -v fallback '%q ' nix run "$NIX_CONFIG_DIR#nh" -- home switch "$NIX_CONFIG_DIR" --configuration tester@main-workstation
run 0 "$refresh" --host main-workstation
expect_commands "$fallback"
run 0 "$upgrade" --host main-workstation
expect_commands "$update"$'\n'"$fallback"
export UPDATE_STATUS=42
run 42 "$upgrade" --host main-workstation
expect_commands "$update"

printf 'deploy-workflow: all mocked command tests passed\n'
