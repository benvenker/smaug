# Podcast Template

Use for podcast episodes filed to `./knowledge/podcasts/{slug}.md`

```yaml
---
title: "{episode_title}"
type: podcast
date_added: {YYYY-MM-DD}
source: "{podcast_url}"
show: "{show_name}"
tags: [{relevant_tags}]
via: "Twitter bookmark from @{author}"
status: needs_transcript
---

{Brief description from tweet context}

## Episode Info

- **Show:** {show_name}
- **Episode:** {episode_title}
- **Why bookmarked:** {context from tweet}

## Transcript

*Pending transcription*

## Links

- [Episode]({podcast_url})
- [Original Tweet]({tweet_url})
```

## Field Notes

- `status: needs_transcript`: Always include for podcasts
- `show`: Podcast show name (e.g., "Lex Fridman Podcast")
- Description: Use tweet context to explain why this episode was bookmarked
- Transcript section: Placeholder for future transcription
