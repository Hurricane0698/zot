# Ingest

Use `ingest` when new raw material should become durable knowledge.

## Workflow
1. Resolve the right raw bucket under `kb/raw/**`.
2. Capture the source with `"$ZOT_VAULT/scripts/kb-capture"` when possible.
3. Read the raw source fully before writing durable notes.
4. Create or update the minimum set of notes under `kb/wiki/**` that makes the new material reusable.
5. Add or strengthen wikilinks between the new notes and existing maps.
6. Update `kb/meta/index.md` if a new durable note was created.
7. Append a log entry with `"$ZOT_VAULT/scripts/kb-log"`.
8. Leave an active-output artifact unless the user explicitly declines.
9. If new files were created and `qmd` is available, refresh the vault-local collection.

## Preferred command helpers
```bash
"$ZOT_VAULT/scripts/kb-capture" --kind conversation --title "Terminal finding" --stdin
"$ZOT_VAULT/scripts/kb-log" ingest "Terminal finding" \
  --raw "[[2026-04-10-terminal-finding]]" \
  --changed "[[Some Durable Note]]" \
  --output "[[Some Drill]]" \
  --note "why it matters"
qmd update -c "$ZOT_QMD_COLLECTION"
```

## Quality bar
- Do not dump one giant summary if two or three focused notes would be clearer.
- Keep `## Sources` current on every durable note you touched.
- Prefer durable insight over paraphrase.
