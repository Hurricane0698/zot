# zot

A modern terminal environment where humans and AI agents work side by side — not AI bolted onto a 1990s shell.

One command sets up Ghostty, zsh, Starship, a curated Rust CLI toolchain, optional AI CLIs, and an Obsidian-based knowledge workflow. 

**中文文档：[`README_CN.md`](README_CN.md)**

<p align="center">
  <img src="assets/ghostty.png" width="80" alt="Ghostty">
  &nbsp;&nbsp;
  <img src="assets/zsh.png" width="80" alt="Zsh">
  &nbsp;&nbsp;
  <img src="assets/starship.png" width="80" alt="Starship">
</p>

## Quick start

```bash
git clone https://github.com/Hurricane0698/zot.git
cd zot
./setup.sh
```

That's it. Open a brand-new shell and everything is ready.

If the shell still looks unchanged, run:

```bash
"$HOME/.local/bin/zot-doctor" shell
```


Useful flags:

```bash
./setup.sh --yes          # skip all prompts, install everything
./setup.sh --dry-run      # preview what would change
./setup.sh --no-obsidian  # skip Obsidian + vault setup
./setup.sh --no-node      # skip fnm + Node.js
./setup.sh --no-qmd       # skip QMD
```

## What you get

| Layer | Tools |
|---|---|
| Terminal | Ghostty / Windows Terminal, zsh, Starship, MesloLGS NF |
| CLI toolchain | bat, eza, fd, ripgrep, fzf, **zoxide**, btop, jq, tldr, git-delta, lazygit, uv |
| Optional multiplexer | one of `zellij` or `tmux`, launched via a unified `mux` command |
| Optional AI CLIs | Claude Code, Codex CLI, Gemini CLI |
| Node runtime | fnm + Node.js LTS |
| Knowledge workflow | Obsidian, QMD, vault/project-note scaffolds, capture/log/lint scripts |

## Supported platforms

| Platform | Status | Notes |
|---|---|---|
| macOS | ✅ primary | Homebrew + native apps |
| Debian / Ubuntu | ✅ supported | apt + bundled binaries + AppImage fallback |
| Windows (WSL) | ✅ supported | CLI in WSL, GUI apps on Windows side |
| Native Windows shell | ⚠ bootstrap only | `./setup.sh` will try to install WSL + Ubuntu, then hand off to WSL |

## How the installer works

- **zoxide** replaces `cd`. After setup, `z repo-name` jumps to directories you visit often.
- The installer detects existing `tmux` / `zellij` and helps you settle on one. After restart, just use `mux`.
- Missing AI CLIs (Claude Code, Codex, Gemini) are offered one by one in interactive mode. `--yes` installs all of them.
- If tmux or zellij is present, `setup.sh` deploys a default config. The tmux profile is based on my own daily setup and includes a cross-platform `zot-copy` clipboard helper.
- `mux code` opens a default AI coding layout: large main pane on the left, `project-context` on upper right, tests/build on lower right.
- Claude Code uses Anthropic's native installer. Codex CLI and Gemini CLI install through npm after Node.js is ready. Auth happens on first launch.
- On WSL, CLI tools go inside Linux. The script also tries to install Obsidian, Windows Terminal, and the bundled `MesloLGS NF` fonts on the Windows side so Starship glyphs render correctly.
- In non-interactive WSL runs, zot skips Windows-side installers to avoid hanging on PowerShell, winget, or font prompts.
- On a native Windows shell, `./setup.sh` acts as a bootstrapper: it will try `wsl --install -d Ubuntu`, then print the exact WSL command to rerun `./setup.sh`.
- The setup also installs bundled home-level skill templates into `~/.codex/skills` and `~/.agents/skills`, plus matching Claude command templates into `~/.claude/commands`, without overwriting your existing files.
- Existing shell and terminal configs are backed up before replacement.

## Obsidian vault setup

```bash
./scripts/init-vault "$HOME/zot-vault"
```

Creates:

```text
zot-vault/
├── AGENTS.md
├── scripts/
│   ├── kb-search
│   ├── kb-capture
│   ├── kb-log
│   ├── kb-lint
│   └── kb-smoke-test
└── kb/
    ├── raw/
    ├── wiki/
    ├── human/
    ├── meta/
    └── templates/
```

After restarting zsh you get shell shortcuts:

```bash
kb          # jump to the vault
kbs "..."   # search the vault
mux         # open your preferred multiplexer
mux code    # open the default AI coding layout
```

Search from the terminal:

```bash
"$HOME/zot-vault/scripts/kb-search" "context engineering"
```

Capture a source, log the ingest, and lint the wiki:

```bash
printf '%s\n' "raw notes here" | "$HOME/zot-vault/scripts/kb-capture" \
  --kind conversation \
  --title "Terminal finding" \
  --stdin
"$HOME/zot-vault/scripts/kb-log" ingest "Terminal finding" \
  --raw "[[2026-04-08-terminal-finding]]" \
  --changed "[[some-durable-note]]" \
  --output "[[some-drill]]" \
  --note "short summary"
"$HOME/zot-vault/scripts/kb-lint"
"$HOME/zot-vault/scripts/kb-smoke-test"
```

Each vault keeps its own QMD collection binding in `kb/meta/tooling.env`,
so multiple vaults don't silently share the same index.

## Project initialization

```bash
./scripts/init-project /path/to/project --vault "$HOME/zot-vault"
```

Scaffolds:

- `AGENTS.md` in the project repo
- Matching Obsidian project note: `kb/wiki/projects/<project>.md`

The intended flow: repo rules live in `AGENTS.md`, durable project memory lives in Obsidian, agents pull both together automatically when starting work.

## Starting a session

Inside any project repo:

```bash
project-context
```

For agents or scripts that need machine-readable context:

```bash
project-context --json
# or:
$ZOT_WORKFLOW_HOME/scripts/start-session --json --vault "$HOME/zot-vault"
```

Prints a working context bundle from: local `AGENTS.md`, local `README.md`, matching Obsidian project note, recent git activity, and any detected home-level Obsidian skills.

## Home-level Obsidian skills

The most reusable Obsidian workflows live at the **user/home level**, not copied into every project.

Bundled templates now include:

- `zot-vault-search`
- `zot-vault-ingest`
- `zot-vault-review`
- `.agents/skills/qmd`

They install non-destructively during `./setup.sh`, and you can rerun `./scripts/install-home-skills` any time.

If you use Claude Code, the same workflows are also installed as slash-command templates under `~/.claude/commands/zot/`.

## Vault workflow

Treat the vault as a small compiled wiki, not a dumping ground:

1. Ingest raw material into `kb/raw/**`.
2. Promote the useful parts into durable notes under `kb/wiki/**`.
3. Update `kb/meta/index.md` and append an entry to `kb/meta/log.md`.
4. Leave active-output drills in `kb/human/active-output/**`.
5. Run `scripts/kb-lint` for structure checks and `scripts/kb-smoke-test` after tooling changes.

## Layer rules

| Layer | Role |
|---|---|
| `kb/raw/**` | immutable captures |
| `kb/wiki/**` | durable synthesis and project memory |
| `kb/human/**` | your plans, drafts, active recall |
| `AGENTS.md` | repo-local contract for agents |
| home-level skills | reusable Obsidian workflows across repos |

## Design principles

1. Durable memory goes in Obsidian.
2. Execution rules stay close to the code in `AGENTS.md`.
3. Reusable workflows become home-level Obsidian skills.
4. Directory jumping goes through `zoxide`.
5. One stable entrypoint (`mux`) for multi-pane sessions — no mental juggling between tmux and zellij.
6. No hidden magic, but context reload should feel automatic.

## Safety

Before publishing, check for secrets or private notes:

```bash
rg -n "api|key|token|secret|password|gmail|@|/Users|/home|/mnt|OPENAI|ANTHROPIC" .
git status --short
git log --stat --oneline -20
```

## License

[MIT](LICENSE)

## Links

[linux.do](https://linux.do)
