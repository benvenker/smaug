# Agent Skills Improvement Plan

**Created:** 2026-01-04
**Branch:** `context-reduction`
**Status:** Ready for implementation

## Overview

This plan improves Smaug's agent skill architecture for cross-IDE compatibility (Claude Code + OpenAI Codex) and better context efficiency following the open skills standard.

## Current State

### Directory Structure
```
~/.skills/smaug-process-bookmarks/     # Canonical source (user's home)
.codex/skills/smaug-process-bookmarks/ # Repo-local copy for Codex
.claude/commands/process-bookmarks.md  # Claude Code slash command (430+ lines)
scripts/sync-skills.sh                 # Copies from ~/.skills/ to .codex/
```

### Problems Identified
1. **No Claude Code skill directory** - Only `.codex/skills/` exists, not `.claude/skills/`
2. **Slash command too long** - 430+ lines loaded into context on every `/process-bookmarks` invocation
3. **SKILL.md too minimal** - Only 11 lines, weak semantic description for auto-invocation
4. **Sync script incomplete** - Only syncs to Codex destinations, not Claude Code

## Implementation Tasks

### Task 1: Update sync-skills.sh for Claude Code

**File:** `scripts/sync-skills.sh`

**Current content:**
```bash
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
```

**New content:**
```bash
#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="smaug-process-bookmarks"
SRC="${HOME}/.skills/${SKILL_NAME}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# All sync destinations
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
```

**Verification:**
```bash
./scripts/sync-skills.sh
ls -la .claude/skills/
ls -la .codex/skills/
```

---

### Task 2: Enhance SKILL.md with Rich Description

**File:** `~/.skills/smaug-process-bookmarks/SKILL.md` (canonical source)

**Current content (11 lines):**
```yaml
---
name: smaug-process-bookmarks
description: Process Smaug pending Twitter/X bookmarks into bookmarks.md and knowledge/ with minimal context output; use when running or adjusting Smaug bookmark processing workflows.
---

# Smaug Bookmark Processing

Follow `references/process-bookmarks.md` for the full workflow.

Keep outputs terse, avoid dumping full JSON into the chat, and prefer file-based batches.
```

**New content (~40 lines):**
```yaml
---
name: smaug-process-bookmarks
description: "Process pending Twitter/X bookmarks from .state/pending-bookmarks.json into bookmarks.md and knowledge/ directories. Handles GitHub repos, articles, podcasts, videos, and plain tweets with category-based filing. Uses parallel Haiku subagents for 3+ bookmarks (~50% cost savings). Emphasizes context efficiency: jq summaries instead of full JSON, terse subagent returns."
---

# Smaug Bookmark Processing Skill

## When This Skill Activates

- User asks to "process bookmarks" or "run smaug"
- User mentions pending bookmarks or `.state/pending-bookmarks.json`
- User wants to file tweets to knowledge base

## Key Behaviors

1. **Context Efficiency First**
   - Never paste full JSON into chat
   - Use `jq` to summarize: `jq '{count, ids: [.bookmarks[].id]}' .state/pending-bookmarks.json`
   - Subagents return only: final markdown entry + filed paths

2. **Parallel Processing** (3+ bookmarks)
   - Spawn all Task subagents in ONE message
   - Use `model="haiku"` for ~50% cost savings
   - Batch size: ~5 bookmarks per subagent

3. **Category-Based Filing**
   - `github.com` → `./knowledge/tools/{slug}.md`
   - Articles (medium, substack, blog) → `./knowledge/articles/{slug}.md`
   - Videos/podcasts → flag for transcript, capture only
   - Plain tweets → `bookmarks.md` only

## Workflow Reference

See [workflow.md](./workflow.md) for complete step-by-step instructions.

## Templates

See [templates/](./templates/) for frontmatter formats:
- `tool.md` - GitHub repositories
- `article.md` - Blog posts and articles
- `podcast.md` - Podcast episodes
- `video.md` - YouTube and video content
```

**After editing, run:**
```bash
./scripts/sync-skills.sh
```

---

### Task 3: Apply Progressive Disclosure to Slash Command

**Goal:** Reduce `.claude/commands/process-bookmarks.md` from 430+ lines to ~60 lines by moving details to skill workflow.

**File:** `.claude/commands/process-bookmarks.md`

**New content (~60 lines):**
```markdown
# /process-bookmarks

Process pending Twitter bookmarks into `bookmarks.md` with category-based filing to `knowledge/`.

## Quick Reference

```bash
# Check pending count
jq '.count' .state/pending-bookmarks.json

# Get today's date for headers
date +"%A, %B %-d, %Y"
```

## Critical Rules

1. **Never paste full JSON** - Use jq summaries only
2. **3+ bookmarks = parallel subagents** - Spawn ALL in one message
3. **Use model="haiku"** - ~50% cost savings for subagent tasks
4. **Subagent output** - Return ONLY markdown entry + filed paths

## Workflow

For complete instructions, follow the smaug-process-bookmarks skill:
- Workflow: `.claude/skills/smaug-process-bookmarks/workflow.md`
- Templates: `.claude/skills/smaug-process-bookmarks/templates/`

## Todo List Template

```javascript
// For 3+ bookmarks:
TodoWrite({ todos: [
  {content: "Read pending bookmarks (summary only)", status: "pending", activeForm: "Reading bookmark summary"},
  {content: "Spawn N haiku subagents", status: "pending", activeForm: "Spawning subagents"},
  {content: "Merge results to bookmarks.md", status: "pending", activeForm: "Merging results"},
  {content: "Clean up pending file", status: "pending", activeForm: "Cleaning up"},
  {content: "Commit and push", status: "pending", activeForm: "Committing"},
]})
```

## Parallel Subagent Template

```javascript
// Spawn ALL in ONE message - they run in parallel
Task({
  subagent_type: "general-purpose",
  model: "haiku",
  description: "Process bookmarks 1-5",
  prompt: `Process these bookmarks. Return ONLY the markdown entries and any filed paths.

Bookmarks: [paste batch JSON]

Rules:
- Create bookmarks.md entries following standard format
- File GitHub repos to knowledge/tools/
- File articles to knowledge/articles/
- Return terse output: markdown + paths only`
})
```
```

---

### Task 4: Create Skill Workflow File

**File:** `~/.skills/smaug-process-bookmarks/workflow.md`

This file should contain the detailed workflow currently in the slash command. Copy the following sections from the current `.claude/commands/process-bookmarks.md`:

1. Input format description (bookmark JSON structure)
2. Categories system table
3. Entry format templates (standard, quote tweet, reply)
4. Date header ordering rules
5. Cleanup pending file code
6. Commit and push commands
7. Parallel processing details

**Structure:**
```markdown
# Smaug Bookmark Processing Workflow

## Input: Pending Bookmarks

Location: `.state/pending-bookmarks.json`

Each bookmark contains:
- `id`, `author`, `authorName`, `text`, `tweetUrl`, `date`
- `links[]` with `original`, `expanded`, `type`, `content`
- `isReply`, `replyContext` - parent tweet info
- `isQuote`, `quoteContext` - quoted tweet info

## Reading Data (Summary Only)

[... rest of detailed workflow from current command ...]
```

---

### Task 5: Create Template Files

**Directory:** `~/.skills/smaug-process-bookmarks/templates/`

Create these files by extracting from current slash command:

**tool.md:**
```yaml
---
title: "{tool_name}"
type: tool
date_added: {YYYY-MM-DD}
source: "{github_url}"
tags: [{tags}]
via: "Twitter bookmark from @{author}"
---

{Description}

## Key Features

- Feature 1
- Feature 2

## Links

- [GitHub]({github_url})
- [Original Tweet]({tweet_url})
```

**article.md:**
```yaml
---
title: "{article_title}"
type: article
date_added: {YYYY-MM-DD}
source: "{article_url}"
author: "{article_author}"
tags: [{tags}]
via: "Twitter bookmark from @{author}"
---

{Summary}

## Key Takeaways

- Point 1
- Point 2

## Links

- [Article]({article_url})
- [Original Tweet]({tweet_url})
```

**podcast.md** and **video.md:** Similar structure with `status: needs_transcript`

---

### Task 6: Update .gitignore (if needed)

Ensure `.claude/skills/` is tracked in git (it's a copy, not the canonical source):

```bash
# Check current gitignore
grep -E "\.claude|\.codex" .gitignore

# Skills should NOT be ignored - they're synced copies for portability
```

---

## Verification Checklist

After implementation, verify:

- [ ] `./scripts/sync-skills.sh` runs without errors
- [ ] `.claude/skills/smaug-process-bookmarks/` exists with SKILL.md, workflow.md, templates/
- [ ] `.codex/skills/smaug-process-bookmarks/` mirrors `.claude/skills/`
- [ ] `/process-bookmarks` command loads quickly (under 100 lines)
- [ ] Running "process my bookmarks" triggers skill auto-invocation in Claude Code
- [ ] Parallel subagent processing still works for 3+ bookmarks

## Future Enhancements (Out of Scope)

These are noted for future consideration but not part of this plan:

1. **Model-based link classification** - Replace hardcoded pattern matching in `processor.js` with semantic classification for edge cases
2. **MCP server for bird CLI** - Expose bookmark fetching as MCP tools
3. **Extractable sub-skills** - Split into reusable `knowledge-base-filing` and `markdown-formatting` skills

## File Changes Summary

| File | Action |
|------|--------|
| `scripts/sync-skills.sh` | Modify - add Claude destinations |
| `~/.skills/smaug-process-bookmarks/SKILL.md` | Modify - enhance description |
| `~/.skills/smaug-process-bookmarks/workflow.md` | Create - move detailed workflow here |
| `~/.skills/smaug-process-bookmarks/templates/*.md` | Create - extract templates |
| `.claude/commands/process-bookmarks.md` | Modify - slim to ~60 lines |
| `.claude/skills/` | Create - via sync script |

## Estimated Token Savings

| Before | After | Savings |
|--------|-------|---------|
| 430 lines loaded on `/process-bookmarks` | 60 lines + lazy skill loading | ~80% reduction |
| Full workflow in system prompt | Progressive disclosure via references | Significant |
