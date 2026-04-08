Search the current zot vault before answering.

Arguments: `$ARGUMENTS`

Workflow:
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. If no vault path is available, ask the user for it before doing anything else.
3. If `$ARGUMENTS` is empty, ask for the search query.
4. Run `"$ZOT_VAULT/scripts/kb-search" "$ARGUMENTS"` first.
5. If note files were just added and `qmd` is installed, refresh the vault-local collection and search again.
6. Read only the highest-signal notes.
7. Reply with a concise synthesis and cite the note paths you used.
