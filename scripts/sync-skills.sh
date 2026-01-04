#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="smaug-process-bookmarks"
SRC="${HOME}/.skills/${SKILL_NAME}"
DEST_GLOBAL="${HOME}/.codex/skills/${SKILL_NAME}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_REPO="${REPO_ROOT}/.codex/skills/${SKILL_NAME}"

if [[ ! -d "${SRC}" ]]; then
  echo "Skill source not found: ${SRC}" >&2
  exit 1
fi

mkdir -p "${HOME}/.codex/skills" "${REPO_ROOT}/.codex/skills"
rm -rf "${DEST_GLOBAL}" "${DEST_REPO}"
cp -R "${SRC}" "${DEST_GLOBAL}"
cp -R "${SRC}" "${DEST_REPO}"

echo "Synced ${SKILL_NAME} to:"
echo "  ${DEST_GLOBAL}"
echo "  ${DEST_REPO}"
