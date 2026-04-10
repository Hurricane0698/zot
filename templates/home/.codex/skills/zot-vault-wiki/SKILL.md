---
name: zot-vault-wiki
description: Orchestrate multi-step zot vault maintenance as a compiled wiki. Use when a task spans two or more operations across `kb/raw`, `kb/wiki`, and `kb/meta`: promoting sources into durable notes, restructuring maps and concept notes, answering grounded questions from the vault, running lint passes, or resolving feedback notes.
---

# zot Vault Wiki

Use this skill for multi-step vault maintenance and routing. For a narrow retrieval-only task, prefer `zot-vault-search`. For a simple one-source capture, prefer `zot-vault-ingest`. For periodic cleanup without new material, `zot-vault-review` may be enough.

## Quick Routing
- `zot-vault-search`: find the right notes, then stop.
- `zot-vault-ingest`: absorb one source or one small coherent batch.
- `zot-vault-review`: periodic hygiene, retrospective, and backlog cleanup.
- `zot-vault-wiki`: anything that combines two or more of search, ingest, query promotion, compile, lint, or feedback resolution.

## Start
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. Read the vault's `AGENTS.md`, then `kb/meta/index.md`, `kb/meta/log.md`, and `kb/meta/review.md`.
3. Read `skill-config.json` when you need exact paths, operation names, or feedback conventions.
4. Write in the user's working language unless they ask otherwise.
5. Keep `kb/raw/**` immutable. Durable synthesis belongs in `kb/wiki/**`.

## Operation Routing
- `compile`: restructure durable notes, split oversized pages, repair maps, strengthen links. Read `references/compile.md`.
- `ingest`: turn new raw material into durable wiki notes and drills. Read `references/ingest.md`.
- `query`: answer from the vault, then promote durable answers back into `kb/wiki/**` when warranted. Read `references/query.md`.
- `lint`: run the mechanical pass, fix structure, then verify the workflow if needed. Read `references/lint.md`.
- `feedback`: resolve correction notes under `kb/human/feedback/open/**`. Read `references/feedback.md`.

Read only the specific reference for the operation you are executing, plus `references/schema.md` when you need the vault layout or naming rules.

## Shared Guardrails
- Update `kb/meta/index.md` when a new durable note appears or navigation changes materially.
- Append a log entry to `kb/meta/log.md`, preferably with `"$ZOT_VAULT/scripts/kb-log"`.
- After meaningful ingest or synthesis, leave an artifact under `kb/human/active-output/**` unless the user explicitly declines.
- If new note files were created and `qmd` is available, refresh the vault-local collection with `qmd update -c "$ZOT_QMD_COLLECTION"` or the value from `kb/meta/tooling.env`.
- If open feedback notes exist, prefer resolving them before large restructures so you do not preserve known errors.
- This skill is for compiled knowledge work, not general journaling or scratch-note cleanup.

## Notes
- The feedback flow is intentionally Obsidian-friendly and plugin-friendly, but this skill does not assume a web viewer.
- Prefer a few connected notes over one giant page.
- Preserve the user's prose in `kb/human/**` unless they explicitly ask you to rewrite it.
- If you can complete the request cleanly with `search`, `ingest`, or `review` alone, do that instead of using this skill by default.
