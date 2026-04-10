# Compile

Use `compile` when the vault already contains the material, but the durable layer needs structure.

## When to use it
- A concept note is turning into a dump and should be split.
- Multiple notes overlap and want a merge or clearer division of labor.
- `kb/meta/index.md` or `kb/wiki/maps/**` no longer match reality.
- A recent ingest wave created weakly linked notes.

## Workflow
1. Read `AGENTS.md`, `kb/meta/index.md`, and the relevant map pages.
2. Read the target subtree in `kb/wiki/**` before changing its structure.
3. If `kb/human/feedback/open/**` contains notes targeting this area, resolve those first or explicitly defer them in `kb/meta/review.md`.
4. Split oversized notes into several linked notes instead of stretching a single page.
5. Prefer updating existing maps over creating new top-level categories.
6. Repair backlinks and wikilinks immediately after any rename or split.
7. Update `kb/meta/index.md` when navigation changed materially.
8. Append a log entry such as:

```bash
"$ZOT_VAULT/scripts/kb-log" compile "topic restructure" \
  --changed "[[Atlas]], [[Note A]], [[Note B]]" \
  --note "split one oversized note into three linked notes"
```

## Output quality bar
- Each note should have one job.
- Navigation should get easier after the compile pass.
- Readers should be able to start at a map page and find the new notes without search.
