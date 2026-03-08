#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <skill-name> <target-repo>"
  echo "Example: $0 ros-workspace-review ~/work/my-robot"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILL_NAME="$1"
TARGET_REPO="$2"

SOURCE_DIR="${STACK_DIR}/skills/${SKILL_NAME}"
DEST_DIR="${TARGET_REPO}/.cursor/skills/${SKILL_NAME}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Skill template not found: ${SOURCE_DIR}"
  exit 1
fi

mkdir -p "${TARGET_REPO}/.cursor/skills"
rm -rf "${DEST_DIR}"
cp -r "${SOURCE_DIR}" "${DEST_DIR}"

echo "Installed skill template:"
echo "  ${SKILL_NAME}"
echo "into:"
echo "  ${DEST_DIR}"
