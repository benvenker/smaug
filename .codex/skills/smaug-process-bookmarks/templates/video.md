# Video Template

Use for YouTube and other videos filed to `./knowledge/videos/{slug}.md`

```yaml
---
title: "{video_title}"
type: video
date_added: {YYYY-MM-DD}
source: "{video_url}"
channel: "{channel_name}"
tags: [{relevant_tags}]
via: "Twitter bookmark from @{author}"
status: needs_transcript
---

{Brief description from tweet context}

## Video Info

- **Channel:** {channel_name}
- **Title:** {video_title}
- **Why bookmarked:** {context from tweet}

## Transcript

*Pending transcription*

## Links

- [Video]({video_url})
- [Original Tweet]({tweet_url})
```

## Field Notes

- `status: needs_transcript`: Always include for videos
- `channel`: YouTube channel or video creator name
- `source`: Full video URL (youtube.com, youtu.be, vimeo, etc.)
- Description: Use tweet context to explain why this video was bookmarked
- Transcript section: Placeholder for future transcription
