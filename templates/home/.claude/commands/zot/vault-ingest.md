Ingest new material into the current zot vault.

Arguments: `$ARGUMENTS`

Workflow:
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. Read the vault's `AGENTS.md` first when it exists.
3. Keep raw captures under `kb/raw/**`; do not overwrite them.
4. Write durable synthesis under `kb/wiki/**`.
5. Update `kb/meta/index.md` when a new durable page is created.
6. Append a log entry to `kb/meta/log.md`.
7. Leave an active-output prompt under `kb/human/active-output/**` unless the user explicitly declines.
8. Run `"$ZOT_VAULT/scripts/kb-lint"` after the changes.

If `$ARGUMENTS` names a source, use it as the title or ingest target. If it is empty, ask the user what should be captured.

Guardrail:
- Keep this command focused on one source or one small coherent batch. If the task expands into restructure, query promotion, or feedback triage, switch to `vault-wiki`.
