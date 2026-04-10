# Feedback

Use `feedback` when the user wants to correct or triage issues already noticed in the vault.

## Inbox
- Open notes live under `kb/human/feedback/open/**`.
- Resolved notes move to `kb/human/feedback/resolved/**`.
- The preferred scaffold is `kb/templates/feedback-note.md`.
- For terminal creation, use `"$ZOT_VAULT/scripts/kb-feedback"` when available.

## Resolution workflow
1. Read the open feedback notes, highest severity first: `error`, `warn`, `suggest`, `info`.
2. Open the targeted note and make the smallest edit that resolves the issue.
3. Append a short resolution under `# Resolution`.
4. Change `status: open` to `status: resolved`.
5. Move the note from `open/` to `resolved/`.
6. Append a log entry:

```bash
"$ZOT_VAULT/scripts/kb-log" feedback "resolved stale benchmark note" \
  --changed "[[Target Note]], [[feedback note]]" \
  --note "corrected the claim and archived the feedback"
```

7. If a feedback item cannot be resolved yet, keep it open and add the unresolved question to `kb/meta/review.md`.

## Guardrails
- Preserve rejected or deferred feedback; do not delete it.
- Prefer direct note targets such as `[[Atlas]]` or `[[Specific Note]]`.
- This flow is designed so an Obsidian plugin can emit the same markdown later; do not assume a web viewer exists.
