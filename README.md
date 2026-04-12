# zot

A terminal setup for people who want sharper tools and smarter AI context — without spending a week on configuration.

`zot` pairs a modern terminal environment with an Obsidian-based memory layer, so your shell feels fast and your agents pick up where they left off.

**中文文档：[`README_CN.md`](README_CN.md)**

[![CI](https://github.com/Hurricane0698/zot/actions/workflows/ci.yml/badge.svg)](https://github.com/Hurricane0698/zot/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-22c55e.svg)](LICENSE)
![Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20Debian%20%7C%20WSL-2563eb.svg)

<p align="center">
  <img src="assets/ghostty.png" width="80" alt="Ghostty">
  &nbsp;&nbsp;
  <img src="assets/zsh.png" width="80" alt="Zsh">
  &nbsp;&nbsp;
  <img src="assets/starship.png" width="80" alt="Starship">
</p>

## What It Does

Most terminal setups stop at themes and aliases.

`zot` ships a working stack:

- a clean daily-driver terminal from scratch
- a lightweight `AGENTS.md` for each project
- durable project memory in Obsidian instead of scattered chat logs
- local context that AI tools can actually read and reuse

Take the whole setup, or just the Obsidian parts.

## Why It Helps

- **Less re-explaining** — project notes and standards live outside the model.
- **Cleaner local setup** — terminal, shell, navigation, and multiplexer come pre-wired.
- **Better long-term workflow** — learning notes, project memory, and execution rules in one place.

## Quick Start

```bash
git clone https://github.com/Hurricane0698/zot.git
cd zot
./setup.sh
```

Open a new shell when it finishes.

## What You Get

| Area | Included |
|---|---|
| Terminal | Ghostty or Windows Terminal, zsh, Starship |
| CLI tools | ripgrep, fzf, zoxide, jq, lazygit, delta, uv and more |
| AI workflow | optional Claude Code, Codex CLI, Gemini CLI |
| Memory layer | Obsidian vault scaffolding, project notes, search/capture/lint scripts |

## In Practice

1. Install once on a new machine.
2. Create a vault for durable notes and project memory.
3. Initialize any repo so local rules and long-term context stay attached.

## Learn More

- [Getting Started](docs/getting-started.md)
- [Obsidian Workflow](docs/obsidian-workflow.md)
- [Changelog](CHANGELOG.md)
- [Background Story](linux_do.md)

## Supported Platforms

| Platform | Status |
|---|---|
| macOS | ✅ |
| Debian / Ubuntu | ✅ |
| Windows via WSL | ✅ |
| Native Windows shell | bootstrap only |

## License

[MIT](LICENSE)
