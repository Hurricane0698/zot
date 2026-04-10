# Lint

Use `lint` when you want a mechanical pass before or after larger edits.

## Workflow
1. Run:

```bash
"$ZOT_VAULT/scripts/kb-lint"
```

2. Fix the highest-signal issues first:
- broken wikilinks
- missing frontmatter
- missing `## Sources`
- orphan durable notes
- malformed feedback notes
- feedback notes pointing at missing targets

3. If search or tooling feels stale after the fixes, run:

```bash
"$ZOT_VAULT/scripts/kb-smoke-test"
```

4. If note files were added or renamed and `qmd` is installed, refresh the vault-local collection.
5. Record meaningful cleanup in `kb/meta/log.md`.

## Notes
- `kb-lint` is a first pass, not the whole review.
- If a lint issue reflects a naming or structure rule, fix the rule source too: a map page, `kb/meta/index.md`, a note template, or `AGENTS.md`.
