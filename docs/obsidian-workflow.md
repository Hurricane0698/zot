# Obsidian Workflow

The Obsidian side of `zot` is meant to stay simple:

- repo rules stay close to the code
- durable project memory lives in the vault
- agents get a cleaner session start

## Create A Vault

```bash
./scripts/init-vault "$HOME/zot-vault"
```

This gives you a vault with:

- `kb/raw/` for captured source material
- `kb/wiki/` for durable notes and project memory
- `kb/human/` for drafts and active recall
- `kb/meta/` for index, logs, and review helpers

## Initialize A Project

```bash
./scripts/init-project /path/to/project --vault "$HOME/zot-vault"
```

That creates:

- `AGENTS.md` in the repo
- `kb/wiki/projects/<project>.md` for project memory
- `kb/wiki/projects/<project>.standards.md` for durable standards

## Start A Session

Inside the repo:

```bash
project-context
```

If a tool needs machine-readable context:

```bash
project-context --json
```

The JSON bundle includes local docs, project notes, standards, recent git activity, and detected home-level skills.

## Home-Level Skills

Bundled templates include:

- `zot-vault-search`
- `zot-vault-ingest`
- `zot-vault-review`
- `zot-vault-wiki`

Reinstall them any time with:

```bash
./scripts/install-home-skills
```

## Typical Use

1. Capture something worth keeping.
2. Promote it into a durable note.
3. Keep project memory and standards current.
4. Let agents read that context instead of re-teaching it every session.

## Related

- [Getting Started](getting-started.md)
- [README](../README.md)
