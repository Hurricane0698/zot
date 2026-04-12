# zot

A terminal setup for people who want sharper tools and smarter AI context — without spending a week on configuration.

`zot` pairs a modern terminal environment with an Obsidian-based memory layer, so your shell feels fast and your agents pick up where they left off.

<p align="center">
  <strong>English</strong>
  &nbsp;·&nbsp;
  <a href="README_CN.md"><strong>中文</strong></a>
</p>

<p align="center">
  <a href="https://github.com/Hurricane0698/zot/actions/workflows/ci.yml">
    <img src="https://github.com/Hurricane0698/zot/actions/workflows/ci.yml/badge.svg" alt="CI">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-22c55e.svg" alt="License: MIT">
  </a>
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Debian%20%7C%20WSL-2563eb.svg" alt="Platforms">
</p>

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

## Install Steps

1. Clone the repo and run the installer.
2. If you want to preview changes first, run `./setup.sh --dry-run`.
3. Choose the optional components you want.
4. Open a new shell after setup finishes.
5. If the shell did not switch cleanly, run `$HOME/.local/bin/zot-doctor shell`.
6. Then initialize your vault, initialize project context, and run `project-context` inside the project.

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

## Common Questions

**Q: I already have a setup I have used for two years. Why would I switch?**

zot is not trying to replace an existing setup. It is a zero-friction starting point for people who want a clean modern stack from scratch, or who want to cherry-pick current best practices.

**Q: How is zot different from chezmoi / oh-my-zsh / dotfiles?**

chezmoi is for syncing config. oh-my-zsh is for zsh plugins, and it is quite heavy for many people. zot is an opinionated full stack for the terminal: terminal emulator, shell, prompt, multiplexer, AI CLIs, and a set of modern CLI tools installed in one run.

**Q: I do not want Obsidian / Ghostty / zsh / Starship / Zellij. Can I skip them?**

Yes. The installer is interactive and lets you choose at each step. If you already use tmux, zot will not install zellij, and `mux` gives you one launch command either way. Flags such as `--no-obsidian` and `--no-node` are also available.

**Q: Will this overwrite my existing setup?**

No. The installer confirms each step interactively, and `--dry-run` lets you inspect what would happen before making changes.

**Q: Which systems are supported?**

macOS, Debian/Ubuntu, and Windows via WSL. On native Windows, zot tries to install WSL first and then guides you into the WSL-based CLI workflow, which is the better path for compatibility and performance with most CLI tools.

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

## Related Links

- [linux.do discussion thread](https://linux.do/t/topic/1926161)
