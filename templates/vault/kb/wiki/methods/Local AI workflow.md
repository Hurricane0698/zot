---
type: method
created: 2026-04-07
updated: 2026-04-08
---

# Local AI workflow

## Core model
Obsidian is the shared layer for:
1. learning,
2. project work,
3. permanent agent context.

## Ingest loop
1. Capture source material into `kb/raw/**`, preferably with `scripts/kb-capture`.
2. Turn the useful parts into durable notes inside `kb/wiki/**`.
3. Update `kb/meta/index.md` when a new durable page appears.
4. Append a short summary to `kb/meta/log.md`, preferably with `scripts/kb-log`.
5. Leave a short drill in `kb/human/active-output/**` so collection becomes learning.
6. If `qmd` is installed, refresh the index after new notes are created.

## Query loop
1. Start from `kb/meta/index.md` and the relevant map pages.
2. Read the most relevant wiki notes before touching raw captures.
3. Use `scripts/kb-search "query"` when navigation alone is not enough.
4. File durable answers back into `kb/wiki/queries/` or `kb/wiki/syntheses/`.
5. Start each repo session from `AGENTS.md` + the matching Obsidian project note + recent git history.

## Maintenance loop
1. Run `scripts/kb-lint` to catch structural issues.
2. Run `scripts/kb-smoke-test` after wiring or toolchain changes.
3. Triage `kb/human/feedback/open/**` before large restructures.
4. Consolidate duplicate ideas and weakly linked notes during review.
5. If available, let home-level skills such as `zot-vault-search`, `zot-vault-ingest`, `zot-vault-review`, and `zot-vault-wiki` enrich the context automatically.
6. Use `zoxide` (`z <name>`) to move between active repos quickly.

## Trellis ideas worth keeping
- explicit context before work
- durable project memory
- repeatable session-start ritual
- small local rules near the code

## Sources
- [[Atlas]]
- [[Review Protocol]]
