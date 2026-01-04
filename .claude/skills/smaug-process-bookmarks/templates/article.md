# Article Template

Use for blog posts and articles filed to `./knowledge/articles/{slug}.md`

```yaml
---
title: "{article_title}"
type: article
date_added: {YYYY-MM-DD}
source: "{article_url}"
author: "{article_author}"
tags: [{relevant_tags}]
via: "Twitter bookmark from @{author}"
---

{Summary of the article's key points and why it was bookmarked}

## Key Takeaways

- Point 1
- Point 2

## Links

- [Article]({article_url})
- [Original Tweet]({tweet_url})
```

## Field Notes

- `title`: Article headline or key insight
- `author`: Article author (if available from extracted content)
- `source`: Full article URL (expanded, not t.co)
- `tags`: Infer from content topics
- Summary: Focus on why this was worth bookmarking
