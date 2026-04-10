# zot Vault Wiki Schema

Read this file when you need the durable shape of a zot vault.

## Primary layout
- `AGENTS.md`: vault-level operating contract. Read first.
- `kb/raw/**`: immutable captures. Add to it; do not rewrite source text.
- `kb/wiki/**`: durable synthesis.
- `kb/meta/index.md`: top-level navigation and operating rules.
- `kb/meta/log.md`: append-only record of meaningful operations.
- `kb/meta/review.md`: recurring prompts, backlog, and unresolved tensions.
- `kb/human/active-output/**`: recall drills and application prompts.
- `kb/human/feedback/open/**`: unresolved correction notes.
- `kb/human/feedback/resolved/**`: archived correction notes with resolutions.

## Durable note families
- `kb/wiki/maps/**`: navigation pages and MOCs.
- `kb/wiki/concepts/**`: durable concept notes.
- `kb/wiki/projects/**`: repo- or project-specific memory.
- `kb/wiki/methods/**`: workflows and heuristics.
- `kb/wiki/queries/**`: durable answers to recurring questions.
- `kb/wiki/syntheses/**`: cross-source analyses.
- `kb/wiki/errors/**`: mistakes, anti-patterns, and misconception notes.

## Naming guidance
- Durable wiki notes: concise human-readable titles in Title Case unless the vault already uses another stable pattern.
- Raw captures: keep the date-prefixed filename produced by `scripts/kb-capture` unless there is a strong reason not to.
- Feedback notes: use the timestamped filename produced by `scripts/kb-feedback`, or follow the same `YYYYMMDD-HHMM-<slug>.md` pattern manually.

## Required note hygiene
- Durable wiki notes should have YAML frontmatter.
- Durable wiki notes outside `kb/wiki/maps/**` should include a `## Sources` section.
- New durable notes should be linked from an existing map page or `kb/meta/index.md`.
- Significant work should append a concise entry to `kb/meta/log.md`.

## Feedback note shape
Feedback notes live under `kb/human/feedback/` and use simple frontmatter:

```yaml
---
type: feedback
title: "Short summary"
target: "[[Target Note]]"
severity: warn
status: open
created: 2026-04-10 08:25
author: omega
---
```

Body shape:

```md
# Feedback

What looks wrong, stale, unclear, or missing.

# Resolution

<!-- Fill in when the note is resolved. -->
```

This format is intentionally lightweight so an Obsidian plugin can emit the same shape later without depending on a web viewer.
