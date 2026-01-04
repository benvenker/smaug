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

See [references/process-bookmarks.md](./references/process-bookmarks.md) for complete step-by-step instructions.

## Templates

See [templates/](./templates/) for frontmatter formats:
- `tool.md` - GitHub repositories
- `article.md` - Blog posts and articles
- `podcast.md` - Podcast episodes
- `video.md` - YouTube and video content
