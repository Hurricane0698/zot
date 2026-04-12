# AGENTS.md

## Mission
Help with `__PROJECT_NAME__` by treating the repository as the source of truth for code,
the matching Obsidian note `__PROJECT_NOTE__` as the durable memory layer,
and `__PROJECT_STANDARDS_NOTE__` as the structured standards pack.

## Session start
1. Read this file first.
2. Read the most relevant local docs: `README.md`, task-specific docs, specs, tests, and nearby code.
3. If `ZOT_VAULT` is available, read or update the matching project note: `__PROJECT_NOTE__`.
4. Read the matching standards pack before making non-trivial product, architecture, or testing decisions: `__PROJECT_STANDARDS_NOTE__`.
5. If home-level Obsidian skills are available, use them opportunistically to search, ingest, or review context.

## Defaults
- Prefer the smallest correct change.
- Inspect existing code before adding new abstractions.
- Keep secrets, private notes, and machine-specific paths out of commits.
- When changing dependencies or architecture, explain what changed, why, and how to verify it.

## Standards pack
- Treat `__PROJECT_STANDARDS_NOTE__` as the durable source for stack, architecture, testing, security, and delivery expectations.
- If the standards pack is stale or missing critical detail, update it before starting large changes.
- Keep repo-local constraints here in `AGENTS.md`; keep reusable, durable standards in the Obsidian standards note.

## Durable knowledge
- Stable project decisions belong in the Obsidian project note.
- Stable project standards belong in the Obsidian standards note.
- Repo-local operational rules belong here in `AGENTS.md`.
- Reusable learning/workflow behaviors should live in home-level Obsidian skills rather than per-project copies.

## Session end
- Record important decisions, debugging lessons, and follow-up tasks in `__PROJECT_NOTE__`.
- Record durable standard changes in `__PROJECT_STANDARDS_NOTE__`.
- Promote repeated patterns into home-level Obsidian skills or vault methods when they become durable.
