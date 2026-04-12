# Getting Started

## Install

```bash
git clone https://github.com/Hurricane0698/zot.git
cd zot
./setup.sh
```

Then open a new shell.

If the shell looks unchanged, run:

```bash
"$HOME/.local/bin/zot-doctor" shell
```

## Common Options

- `./setup.sh --yes`: install with minimal prompts
- `./setup.sh --dry-run`: preview changes
- `./setup.sh --no-obsidian`: skip Obsidian and vault setup
- `./setup.sh --no-node`: skip Node.js and Node-based tools
- `./setup.sh --no-qmd`: skip QMD

## First Steps

1. Create a vault.
2. Initialize a repo.
3. Start a session with project context.

```bash
./scripts/init-vault "$HOME/zot-vault"
./scripts/init-project /path/to/project --vault "$HOME/zot-vault"
cd /path/to/project
project-context
```

## What Gets Installed

- terminal setup: Ghostty or Windows Terminal, zsh, Starship
- CLI tools: ripgrep, fzf, zoxide, jq, lazygit, delta, uv and others
- optional multiplexer: `tmux` or `zellij` through a unified `mux` command
- optional AI CLIs: Claude Code, Codex CLI, Gemini CLI
- Obsidian workflow helpers: vault scaffolding, search, capture, log, lint, smoke test

## Where To Go Next

- [Obsidian Workflow](obsidian-workflow.md)
- [README](../README.md)
