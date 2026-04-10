# Query

Use `query` when the user wants an answer grounded in the vault.

## Workflow
1. Start from `kb/meta/index.md` and the relevant `kb/wiki/maps/**` pages.
2. Use `"$ZOT_VAULT/scripts/kb-search" "query"` when navigation alone is not enough.
3. Read the highest-signal durable notes before touching raw captures.
4. If the vault is still thin, say so and point to the next source or gap instead of inventing certainty.
5. Answer with explicit note references.
6. If the answer is durable, promote it to `kb/wiki/queries/**` or `kb/wiki/syntheses/**`.
7. Update links, `kb/meta/index.md` if needed, and `kb/meta/log.md`.

## Promotion heuristic
Promote when the answer would still be useful next week:
- comparison
- synthesis across multiple notes
- repeat question
- clarified misconception

## Log example
```bash
"$ZOT_VAULT/scripts/kb-log" query "rag-vs-compiled-wiki" \
  --changed "[[Query Note]], [[Atlas]]" \
  --note "promoted a repeated answer into durable form"
```
