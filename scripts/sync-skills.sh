#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="smaug-process-bookmarks"
SRC="${HOME}/.skills/${SKILL_NAME}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# All sync destinations (Codex + Claude Code)
DESTINATIONS=(
  "${HOME}/.codex/skills/${SKILL_NAME}"
  "${HOME}/.claude/skills/${SKILL_NAME}"
  "${REPO_ROOT}/.codex/skills/${SKILL_NAME}"
  "${REPO_ROOT}/.claude/skills/${SKILL_NAME}"
)

if [[ ! -d "${SRC}" ]]; then
  echo "Skill source not found: ${SRC}" >&2
  exit 1
fi

# Create parent directories
mkdir -p "${HOME}/.codex/skills" "${HOME}/.claude/skills" \
         "${REPO_ROOT}/.codex/skills" "${REPO_ROOT}/.claude/skills"

echo "Syncing ${SKILL_NAME} from ${SRC}..."

for dest in "${DESTINATIONS[@]}"; do
  rm -rf "$dest"
  cp -R "${SRC}" "$dest"
  echo "  → $dest"
done

echo "Done. Synced to ${#DESTINATIONS[@]} locations."
