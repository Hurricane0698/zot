Maintain the current zot vault as a compiled wiki.

Arguments: `$ARGUMENTS`

Workflow:
1. Resolve the vault path from `ZOT_VAULT`, then legacy `OMEGA_VAULT`.
2. Read `AGENTS.md`, `kb/meta/index.md`, `kb/meta/log.md`, and `kb/meta/review.md`.
3. Choose the matching operation: `compile`, `ingest`, `query`, `lint`, or `feedback`.
4. Keep `kb/raw/**` immutable and write durable synthesis to `kb/wiki/**`.
5. Update `kb/meta/index.md` after meaningful navigation changes and append to `kb/meta/log.md`.
6. Leave an active-output drill after meaningful ingest or synthesis unless the user explicitly declines.
7. If open feedback exists under `kb/human/feedback/open/**`, resolve it before large restructures when practical.

If `$ARGUMENTS` names an operation or target area, use it to scope the pass.

Use this command when the job crosses skill boundaries, such as:
- ingest plus restructure
- query plus promotion
- review plus feedback resolution
- lint plus broad wiki cleanup
