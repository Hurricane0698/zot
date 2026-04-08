---
type: log
created: 2026-04-07
updated: 2026-04-08
---

# Knowledge Base Log

Append one entry per meaningful ingest, review, migration, or workflow change.
Prefer `scripts/kb-log` so the format stays consistent.

Use this format:

```md
## [YYYY-MM-DD HH:MM] kind | title
- raw: [[path-or-note]]
- changed: [[note-a]], [[note-b]]
- output: [[drill-note]]
- note: one-line summary
```
