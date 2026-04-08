---
type: index
created: 2026-04-07
updated: 2026-04-08
aliases: [Knowledge Base Index]
---

# Knowledge Base Index

## Core navigation
- [[Atlas]]
- [[Local AI workflow]]
- [[Review Protocol]]

## Working areas
- Raw inbox: `kb/raw/inbox/`
- Web captures: `kb/raw/web/`
- Conversations and debugging captures: `kb/raw/conversation/`
- Durable wiki: `kb/wiki/`
- Project notes: `kb/wiki/projects/`
- Query notes: `kb/wiki/queries/`
- Long-form syntheses: `kb/wiki/syntheses/`
- Human notes: `kb/human/`
- Active-output drills: `kb/human/active-output/`
- Review prompts: `kb/meta/review.md`

## Operating rules
1. Raw first, synthesis second.
2. Durable answers go into `kb/wiki/**`.
3. Start from maps and indexes before falling back to full-text search.
4. Search before answering from old knowledge: `scripts/kb-search "query"`.
5. Important synthesis should leave an active-output prompt.
6. Each active repo should have one matching note under `kb/wiki/projects/`.
7. Use `scripts/kb-lint` for maintenance and `scripts/kb-smoke-test` after wiring changes.
8. Use Obsidian as the shared layer for learning, project work, and permanent agent context.

## First steps
- Create the matching project note with `scripts/init-project /path/to/project --vault <vault>`.
- Capture new material with `scripts/kb-capture`.
- Log meaningful ingests or reorganizations with `scripts/kb-log`.
