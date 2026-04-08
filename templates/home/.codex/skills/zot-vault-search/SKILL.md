---
name: zot-vault-search
description: Use when working inside a zot vault and you need to find relevant notes quickly before answering, ingesting, or reviewing. Prefer the vault-local `scripts/kb-search`; it uses the vault's QMD collection when available and falls back to ripgrep when QMD is not installed or fails.
---

# zot Vault Search

## Purpose
Search the current zot vault efficiently before reading large note sets.

## Workflow
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`, then ask the user only if neither exists.
2. Start with `"$ZOT_VAULT/scripts/kb-search" "query"`.
3. If new files were just added, run `qmd update -c "$ZOT_QMD_COLLECTION"` first when QMD is installed.
4. If the result set is still noisy, narrow by domain folder under `kb/wiki/` or `kb/raw/`.
5. Read the highest-signal notes, not everything.
6. File durable answers back into the vault when appropriate.

## Notes
- `scripts/kb-search` reads the vault-local collection from `kb/meta/tooling.env`, so multiple vaults do not silently share one global index.
- If QMD is absent or fails, the script falls back to `rg` so the workflow never breaks.
- Use `scripts/kb-smoke-test` when you want to verify the vault search stack end-to-end.
- Do not use search as an excuse to skip synthesis; search is only the front-end to reading and updating notes.
