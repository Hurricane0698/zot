---
name: zot-vault-review
description: Use when the user asks for weekly review, vault maintenance, linting, synthesis, retrospective, meta-learning analysis, or to turn accumulated notes in a zot vault into clearer understanding and output drills. Include QMD refresh and search checks, and use the smoke test when local workflow wiring needs verification.
---

# zot Vault Review

This skill is for periodic maintenance and synthesis of a zot vault.

## Required workflow
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. Read `kb/meta/index.md`, `kb/meta/log.md`, and `kb/meta/review.md` when present.
3. Run `qmd update -c <vault-local-collection>` if note files changed since the last review.
4. Run `"$ZOT_VAULT/scripts/kb-lint"` for a mechanical pass.
5. Identify orphan notes, stale syntheses, duplicated concepts, and missing active-output drills.
6. If the review produced durable insight, file it under `kb/wiki/syntheses/` or `kb/wiki/queries/`.
7. Use `"$ZOT_VAULT/scripts/kb-smoke-test"` when search or CLI wiring looks suspicious.
8. When the user asks for versioning, review the diff before any commit.

## Review outputs to prefer
- weekly synthesis note
- error-pattern note
- "teach it back" drill
- migration suggestions from legacy notes into `kb/wiki/**`
- retrieval sanity check based on `CLI + qmd smoke test`

## Guardrails
- Do not auto-commit without checking what changed.
- Keep reviews focused on compounding understanding, not vanity metrics.
- If a file may contain secrets, flag it and recommend rotation or removal.
