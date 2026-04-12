# zot

一套给“想要更顺手的终端，也想让 AI 真正读懂本地上下文”的人准备的本地工作环境，而不是把电脑折腾成配置工程。

`zot` 把现代终端环境和基于 Obsidian 的长期记忆层放在一起，让你日常开发更顺手，也让 agent 每次开工不用从零开始。

<p align="center">
  <a href="README.md"><strong>English</strong></a>
  &nbsp;·&nbsp;
  <strong>中文</strong>
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

## 它是什么

很多终端配置仓库停留在主题、别名和工具列表。

`zot` 更进一步：

- 帮你搭好一套干净的日用终端环境
- 给每个项目补一个轻量的 `AGENTS.md`
- 把长期项目记忆放进 Obsidian，而不是散落在聊天记录里
- 让 AI 工具更容易拿到本地、持续、可复用的上下文

你可以整套使用，也可以只拿其中的 Obsidian 工作流部分。

## 有什么好处

- **少重复解释** — 项目记忆和标准不再只存在模型上下文里。
- **本地环境更顺手** — 终端、shell、跳转、多开器都预先接好。
- **长期工作流更完整** — 学习笔记、项目记忆、执行规则能放进一个系统里。

## 快速开始

```bash
git clone https://github.com/Hurricane0698/zot.git
cd zot
./setup.sh
```

安装完成后，开一个新 shell 就可以开始用。

## 安装步骤

1. 拉下仓库并运行安装脚本。
2. 如果想先确认会改什么，先运行 `./setup.sh --dry-run`。
3. 按需选择要安装的组件。
4. 安装完成后打开一个新 shell。
5. 如果 shell 看起来没切过来，运行 `$HOME/.local/bin/zot-doctor shell`。
6. 然后初始化 vault、初始化项目上下文，并在项目里运行 `project-context`。


## 你会得到什么

| 方向 | 内容 |
|---|---|
| 终端 | Ghostty 或 Windows Terminal、zsh、Starship |
| CLI 工具 | ripgrep、fzf、zoxide、jq、lazygit、delta、uv 等 |
| AI 工作流 | 可选安装 Claude Code、Codex CLI、Gemini CLI |
| 记忆层 | Obsidian vault 脚手架、项目笔记、search / capture / lint 脚本 |

## 上手流程

1. 在新机器上装一次。
2. 建一个 vault，存长期笔记和项目记忆。
3. 给任意仓库初始化，让本地规则和长期上下文保持关联。

## 常见疑问

**Q: 我自己的配置用了两年了，凭什么换成你的？**

zot的目标不是替换配置，而是给想从零开始或想看看现代化最佳实践的人一个零摩擦起点。已有配置的可以 cherry-pick 需要的部分。

**Q: zot和 chezmoi / oh-my-zsh / dotfiles 有什么区别？**

chezmoi管配置同步，oh-my-zsh管zsh 插件（而且很重，装了一堆用不到的东西），zot是一整套 opinionated 的现代终端环境：终端模拟器+shell+提示符+多开器+AI CLI+十几个现代 CLI 工具，一条命令装完。

**Q: 我不想装 obsidian / ghostty / zsh / starship / zellij，能跳过吗？**

都可以跳过。安装脚本是交互式的，每一步都让你选择。已有 tmux 就不会装 zellij，用 `mux` 统一启动。`--no-obsidian`、`--no-node` 等 flag 也都有。

**Q: 会不会覆盖我现有的配置？**

不会。交互式确认每一步，支持 `--dry-run` 先看看会做什么。

**Q: 支持什么系统？**

macOS、Debian/Ubuntu、Windows（WSL）。如果是原生 Windows，我们会尝试为你安装 WSL 并引导你使用 WSL 来运行 CLI 工具。这是比 Windows shell 更好的选择，因为大多数 CLI 工具在 WSL 里有更好的兼容性和性能。

## 继续了解

- [快速上手说明](docs/getting-started.zh-CN.md)
- [Obsidian 工作流](docs/obsidian-workflow.zh-CN.md)
- [更新记录](CHANGELOG.md)
- [项目背景](linux_do.md)

## 支持平台

| 平台 | 状态 |
|---|---|
| macOS | ✅ |
| Debian / Ubuntu | ✅ |
| Windows via WSL | ✅ |
| 原生 Windows shell | 仅引导 |

## 许可证

[MIT](LICENSE)

## 友情链接

- [linux.do 讨论帖](https://linux.do/t/topic/1926161)
