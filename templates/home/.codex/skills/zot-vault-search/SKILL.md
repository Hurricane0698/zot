---
name: zot-vault-search
description: Search-only skill for zot vaults. Use when you need to locate the right notes quickly before reading or answering. Prefer the vault-local `scripts/kb-search`; it uses the vault's QMD collection when available and falls back to ripgrep when QMD is not installed or fails. Not for ingest, review, large restructuring, or feedback resolution.
---

# zot Vault Search

## Purpose
Search the current zot vault efficiently before reading large note sets.

Use this when the job is "find the right notes fast". If the task becomes "turn findings into durable notes", hand off to `zot-vault-ingest` or `zot-vault-wiki`.

## Workflow
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`, then ask the user only if neither exists.
2. Start with `"$ZOT_VAULT/scripts/kb-search" "query"`.
3. If new files were just added, run `qmd update -c "$ZOT_QMD_COLLECTION"` first when QMD is installed.
4. If the result set is still noisy, narrow by domain folder under `kb/wiki/` or `kb/raw/`.
5. Read the highest-signal notes, not everything.
6. Stop once you have the right reading set or a concise cited answer.

## Notes
- `scripts/kb-search` reads the vault-local collection from `kb/meta/tooling.env`, so multiple vaults do not silently share one global index.
- If QMD is absent or fails, the script falls back to `rg` so the workflow never breaks.
- Use `scripts/kb-smoke-test` when you want to verify the vault search stack end-to-end.
- Do not use search as an excuse to skip synthesis; search is only the front-end to reading.
- If the task now involves creating or restructuring notes, switch to `zot-vault-ingest`, `zot-vault-review`, or `zot-vault-wiki` instead of stretching this skill.
