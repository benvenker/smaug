# /process-bookmarks

Process pending Twitter bookmarks into `bookmarks.md` with category-based filing to `knowledge/`.

## Quick Start

```bash
# Check pending count
jq '.count' .state/pending-bookmarks.json

# Get today's date for headers
date +"%A, %B %-d, %Y"
```

## Critical Rules

1. **Never paste full JSON** - Use jq summaries:
   ```bash
   jq '{count, sample: (.bookmarks[:3] | map({id, author}))}' .state/pending-bookmarks.json
   ```

2. **3+ bookmarks = parallel subagents** - Spawn ALL in one message

3. **Use model="haiku"** - ~50% cost savings for subagent tasks

4. **Subagent output** - Return ONLY markdown entry + filed paths

## Detailed Workflow

For complete step-by-step instructions, see the skill reference:
- **Full workflow:** `.codex/skills/smaug-process-bookmarks/references/process-bookmarks.md`
- **Templates:** `.codex/skills/smaug-process-bookmarks/templates/`

## Todo Template

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

## Parallel Subagent Example

```javascript
// Spawn ALL in ONE message - they run in parallel
Task({
  subagent_type: "general-purpose",
  model: "haiku",
  description: "Process bookmarks 1-5",
  prompt: `Process these bookmarks following the workflow in .codex/skills/smaug-process-bookmarks/references/process-bookmarks.md

Bookmarks: [batch JSON here]

Return ONLY: markdown entries + filed paths. No reasoning, no logs.`
})
```

## Categories Quick Reference

| Category | Match | Action | Folder |
|----------|-------|--------|--------|
| github | github.com | file | ./knowledge/tools |
| article | medium, substack, blog | file | ./knowledge/articles |
| podcast | podcasts.apple.com, spotify | transcribe | ./knowledge/podcasts |
| video | youtube, vimeo | transcribe | ./knowledge/videos |
| tweet | (fallback) | capture | bookmarks.md only |

## Entry Format Quick Reference

**Standard:**
```markdown
## @{author} - {descriptive_title}
> {tweet_text}

- **Tweet:** {tweet_url}
- **Link:** {expanded_url}
- **Filed:** [filename](./knowledge/tools/{slug}.md)
- **What:** {1-2 sentence description}
```

**Quote tweet:** Add `> *Quoting @{author}:* {text}` after tweet text

**Reply:** Add `> *Replying to @{author}:* {text}` before tweet text
