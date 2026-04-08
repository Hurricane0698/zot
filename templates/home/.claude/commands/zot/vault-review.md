Review and clean up the current zot vault.

Arguments: `$ARGUMENTS`

Workflow:
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. Start with `kb/meta/index.md`, `kb/meta/log.md`, and `kb/meta/review.md` when present.
3. If files changed since the last review and `qmd` is installed, refresh the vault-local collection.
4. Run `"$ZOT_VAULT/scripts/kb-lint"` for a mechanical pass.
5. Identify orphan notes, duplicated concepts, stale syntheses, and missing active-output drills.
6. If the review produces durable insight, file it under `kb/wiki/**`.
7. Use `"$ZOT_VAULT/scripts/kb-smoke-test"` when search or CLI wiring looks suspicious.

If `$ARGUMENTS` narrows the scope, use it as the review focus.
