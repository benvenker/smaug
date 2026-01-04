# Smaug Process Bookmarks (Agent-Agnostic)

Process prepared Twitter/X bookmarks into `bookmarks.md` with optional filing to `knowledge/`.

## Inputs

- Pending data: `./.state/pending-bookmarks.json`
- Config: `./smaug.config.json` (categories, output paths)
- Outputs: `./bookmarks.md`, `./knowledge/`, `./.state/`

## Fetching Bookmarks (Bird CLI)

Bird supports bookmark folders via `--folder-id`. You can pass a folder ID from the X bookmarks URL:
`https://x.com/i/bookmarks/<folder-id>`. citeturn0view0

Examples: citeturn0view0

```bash
# All bookmarks (JSON)
bird bookmarks --all --json

# Specific bookmark folder
bird bookmarks --folder-id <folder-id> -n 100 --json
```

**Sourcing folder IDs:** You can get IDs from a file (e.g., `.sources/folder-ids.txt`), DOM extraction (browser/extension), or pasted list. Pass them explicitly as repeatable `--folder-id` flags rather than parsing inside Smaug.

## Setup

- Get friendly date format (for headers):
  ```bash
  date +"%A, %B %-d, %Y"
  ```
- Load custom categories (if any):
  ```bash
  jq '.categories // empty' ./smaug.config.json
  ```

## Read Data (Summary Only)

**Do not dump full JSON into chat.** Summarize with `jq`:

```bash
jq '{count, sample: (.bookmarks[:3] | map({id, author, tweetUrl, links: (.links|map(.expanded))}))}' ./.state/pending-bookmarks.json
```

If you need full data, write batch files to disk and reference paths:

```bash
mkdir -p ./.state/batches
jq -c '.bookmarks' ./.state/pending-bookmarks.json \
  | jq -c '[_nwise(5)] | to_entries[] | {batch: (.key+1), bookmarks: .value}' \
  | while read -r batch; do
      idx=$(jq -r '.batch' <<<"$batch");
      jq -c '.bookmarks' <<<"$batch" > ./.state/batches/batch-$(printf "%02d" "$idx").json;
    done
```

## Parallel Processing Guidance

- For 3+ bookmarks, use parallel workers/subagents in a single dispatch.
- **Output size rule:** return only the final markdown entry + any filed path(s). No reasoning, no logs.
- Keep orchestration terse (e.g., "spawned N workers", "merged N results").

## Categorization

Use category `match` rules from config. Default categories:

- `github` -> file -> `./knowledge/tools`
- `article` -> file -> `./knowledge/articles`
- `podcast`/`youtube`/`video` -> transcribe -> `./knowledge/podcasts` or `./knowledge/videos`
- `tweet` -> capture only

First match wins; otherwise fallback to `tweet`.

## Entry Format (bookmarks.md)

**Ordering rules:**
1. Use bookmark `date` from JSON for the date header
2. If date header exists near top: insert entry immediately below the header
3. Else create a new `# Weekday, Month Day, Year` section at the top
4. Never create duplicate date headers

**Header hierarchy:**
- `# Thursday, January 2, 2026` (H1 date)
- `## @author - title` (H2 entry)

**Standard entry:**
```markdown
## @{author} - {descriptive_title}
> {tweet_text}

- **Tweet:** {tweet_url}
- **Link:** {expanded_url}
- **Filed:** [{filename}](./knowledge/tools/{slug}.md)  # if filed
- **What:** {1-2 sentence description}
```

**Quote tweet:**
```markdown
## @{author} - {descriptive_title}
> {tweet_text}
>
> *Quoting @{quoted_author}:* {quoted_text}

- **Tweet:** {tweet_url}
- **Quoted:** {quoted_tweet_url}
- **What:** {description}
```

**Reply:**
```markdown
## @{author} - {descriptive_title}
> *Replying to @{parent_author}:* {parent_text}
>
> {tweet_text}

- **Tweet:** {tweet_url}
- **Parent:** {parent_tweet_url}
- **What:** {description}
```

**Separators:** Use `---` only between different dates, not between entries on the same date.

## File Outputs (knowledge/)

Use the appropriate frontmatter template (tool/article/podcast/video). Include:
- `title`, `type`, `date_added`, `source`, `tags`, `via`
- Add `author` for articles
- For podcasts/videos add `status: needs_transcript`

## Cleanup Pending File

After processing IDs:

```javascript
const fs = require('fs');
const pending = JSON.parse(fs.readFileSync('./.state/pending-bookmarks.json', 'utf8'));
const processedIds = new Set([/* IDs */]);
const remaining = pending.bookmarks.filter(b => !processedIds.has(b.id));
pending.bookmarks = remaining;
pending.count = remaining.length;
fs.writeFileSync('./.state/pending-bookmarks.json', JSON.stringify(pending, null, 2));
```

## Commit & Push (if requested)

```bash
DATE=$(date +"%b %-d")

git add bookmarks.md
if [ -d knowledge ]; then git add knowledge/; fi

git commit -m "Process N Twitter bookmarks from $DATE

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

git push
```

Adjust commit message if no Claude involvement or if a different agent ran the job.
