---
name: zot-vault-ingest
description: Single-source or single-batch ingest skill for zot vaults. Use when the user asks to save, 整理, 归档, absorb, or integrate conversations, terminal findings, project brainstorming, blogs, podcasts, course material, or life observations into a zot Obsidian vault. Capture raw material under `kb/raw`, create the minimum durable notes under `kb/wiki`, update `kb/meta/log.md` and `kb/meta/index.md`, refresh QMD indexing when new files are added, and leave active-output prompts in `kb/human/active-output`. Not for review passes, broad restructures, or feedback triage.
---

# zot Vault Ingest

This skill is for turning one new source, or one coherent small batch of sources, into durable vault knowledge.

Use `zot-vault-wiki` instead when the request spans multiple operations, such as ingest plus restructure, ingest plus query promotion, or ingest plus feedback resolution.

## Required workflow
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. Read the vault's `AGENTS.md` first when it exists.
3. Unless the user explicitly requests another language, write new raw captures, wiki syntheses, active-output prompts, and log-facing summaries in the user's working language.
4. Keep raw material in `kb/raw/**`; do not overwrite it.
5. Write durable synthesis to `kb/wiki/**` using the templates in `kb/templates/` when useful.
6. Update `kb/meta/index.md` when a new durable page appears.
7. Append a standardized entry to `kb/meta/log.md`.
8. Refresh retrieval with `qmd update -c <vault-local-collection>` when new notes were created.
9. Leave an internalization artifact in `kb/human/active-output/` unless the user explicitly declines.
10. If the ingest reveals that large existing notes need splitting or cleanup, stop the ingest cleanly and continue with `zot-vault-wiki`.

## Helpful commands
- `"$ZOT_VAULT/scripts/kb-capture" --kind conversation --title "..." --stdin`
- `"$ZOT_VAULT/scripts/kb-log" ingest "title" --raw "[[...]]" --changed "[[...]]" --output "[[...]]" --note "..."`
- `"$ZOT_VAULT/scripts/kb-lint"`
- `"$ZOT_VAULT/scripts/kb-smoke-test"` when you want to verify the local workflow

## Quality bar
- Prefer updating a few connected notes over dumping one giant summary.
- Add `## Sources` sections to durable notes.
- Push the user toward active recall, application, and confusion-clearing.
- Do not touch legacy root notes unless the user asked for migration.
- Keep the scope tight. This skill should finish an ingest, not become a general maintenance pass.
