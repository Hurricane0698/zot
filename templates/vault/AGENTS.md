# AGENTS.md

## Mission
Treat this vault as a Karpathy-style LLM wiki for your local AI workflow.
Obsidian is the human-facing editor; terminal agents maintain the markdown carefully.

This vault is the shared substrate for:
- learning
- project work
- durable agent context

## Ground truth paths
- All durable system work should happen under `kb/`.
- `kb/raw/**` = immutable source material. Add new captures; do not rewrite source text.
- `kb/wiki/**` = durable synthesis. Agents may create, split, merge, and update notes here.
- `kb/human/**` = human thinking and active recall. Avoid rewriting the user's prose unless explicitly asked.
- `kb/human/feedback/**` = durable correction notes waiting to be resolved or archived.
- `kb/meta/**` = shared operating metadata: index, logs, review notes.
- `kb/templates/**` = note skeletons for repeatable structure.

## Directory map
- `kb/raw/`
  - `inbox/` quick captures waiting to be processed
  - `web/` clipped articles and blog posts
  - `podcast/` podcast / video / transcript captures
  - `course/` learning materials
  - `conversation/` AI conversations, debugging sessions, terminal discoveries
  - `life/` observations from daily life
  - `assets/` local attachments referenced by notes
- `kb/wiki/`
  - `maps/` navigation pages / MOCs
  - `concepts/` durable concept notes
  - `projects/` project knowledge and architecture notes
  - `methods/` workflows, heuristics, playbooks
  - `queries/` durable answers to repeated questions
  - `syntheses/` cross-source analyses and long-form theses
  - `errors/` mistakes, anti-patterns, misconceptions
- `kb/human/`
  - `daily/` daily notes and journals
  - `scratch/` temporary thought fragments
  - `prompts/` reusable prompt seeds
  - `active-output/` recall drills, self-tests, application prompts
  - `feedback/open/` unresolved correction notes
  - `feedback/resolved/` archived corrections with resolutions
- `kb/meta/`
  - `index.md` catalog and jump page
  - `log.md` append-only operations log
  - `review.md` recurring review checklist and prompts

## Required workflows

### 1) Ingest new material
When the user asks to save a conversation, article, podcast, terminal insight, or observation:
1. If the raw material is not yet stored, place it in `kb/raw/<kind>/...` with `scripts/kb-capture` when possible.
2. Create or update the relevant durable notes under `kb/wiki/**`.
3. Add or strengthen links between related wiki notes.
4. Update `kb/meta/index.md` if a new durable page was created.
5. Append a standardized entry to `kb/meta/log.md`, preferably with `scripts/kb-log`.
6. If new notes were created and `qmd` is available, refresh retrieval with `qmd update -c <collection>`.
7. Leave one note in `kb/human/active-output/` unless the user explicitly declines.

### 2) Query / synthesis
When answering non-trivial questions using the vault:
1. Start from `kb/meta/index.md` and the relevant `kb/wiki/maps/**` pages.
2. Read the directly relevant wiki notes before touching raw sources.
3. Use `scripts/kb-search "query"` when navigation alone is not enough.
4. If the answer is durable, file it into `kb/wiki/queries/` or `kb/wiki/syntheses/`.
5. Add backlinks and a `## Sources` section.
6. Treat context gathering as an automatic composition problem: repo docs + project note + recent history + relevant vault notes.

### 3) Lint / maintenance
Periodically check for:
- orphan wiki pages with no inbound links
- stale claims superseded by newer notes
- duplicated concepts that should be merged
- missing `## Sources` sections on durable notes
- broken wikilinks or missing frontmatter
- malformed feedback notes or feedback pointing at missing targets
Use `scripts/kb-lint` for a first-pass mechanical check and `scripts/kb-smoke-test` when the local workflow needs verification.

### 4) Feedback / correction loop
When the user flags a stale claim, ambiguous note, or factual error:
1. Create or update a note under `kb/human/feedback/open/`, preferably with `scripts/kb-feedback`.
2. Target the affected note directly with a wikilink such as `[[Atlas]]`.
3. Resolve open feedback during review or before large restructures.
4. Move resolved feedback to `kb/human/feedback/resolved/` and keep the resolution note intact.

## Active output enforcement
This vault is for learning, not decorative hoarding.
After meaningful ingest or synthesis, agents should try to leave behind:
- 3-7 active recall questions
- 1 application exercise
- 1 falsification / confusion check
If the user is overloaded, keep it short but do not skip it by default.

## Style
- Use exact dates: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM`.
- Prefer short sections and links over long dumps.
- Preserve originals; add synthesis next to them.
- If a note may contain secrets, flag it instead of copying it elsewhere.
- Keep notes legible without depending on a specific plugin.

## Project workflow
1. Use `scripts/init-project` to add a sanitized `AGENTS.md` to each repo.
2. Keep each project's durable memory in `kb/wiki/projects/<project>.md`.
3. Keep each project's standards pack in `kb/wiki/projects/<project>.standards.md`.
4. Start repo sessions from local docs plus the matching project note and standards note.
5. If available, use home-level skills such as `zot-vault-search`, `zot-vault-ingest`, `zot-vault-review`, and `zot-vault-wiki`.

## Editing rules
- Do not silently delete raw sources.
- When uncertainty is high, preserve the original material and add synthesis next to it instead of overwriting.
- Keep changes human-readable and easy to audit in git.
