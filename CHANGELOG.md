# Changelog

All notable changes to this project will be documented in this file.

The format follows Keep a Changelog and the project is moving toward SemVer-style releases.

## [Unreleased]

### Added
- GitHub Actions CI for `shellcheck`, `shfmt`, `ruff`, and unit tests.
- Structured project standards packs via `kb/wiki/projects/<project>.standards.md`.
- `start-session --json` support for `project_standards`, `structured_context`, and evidence paths.
- Repo-level tests for `init-project` and `start-session`.

### Changed
- README and README_CN now lead with the Obsidian-first workflow and 30-second demo.
- `init-project` now scaffolds `AGENTS.md`, a durable project note, and a standards pack together.
- Project and vault templates now separate durable memory from durable implementation standards.
