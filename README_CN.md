# zot

一个面向 AI 时代的现代终端环境，让人和 agent 在同一套本地工作流里顺畅协作，而不是把 AI 额外挂在老旧 shell 上。

一条命令装好 Ghostty、zsh、Starship、一整套现代 CLI 工具、可选 AI CLI，以及基于 Obsidian 的知识工作流。该配的都配好，尽量不让你手动折腾。

**English: [`README.md`](README.md)**

<p align="center">
  <img src="assets/ghostty.png" width="80" alt="Ghostty">
  &nbsp;&nbsp;
  <img src="assets/zsh.png" width="80" alt="Zsh">
  &nbsp;&nbsp;
  <img src="assets/starship.png" width="80" alt="Starship">
</p>

## 快速开始

```bash
git clone https://github.com/Hurricane0698/zot.git
cd zot
./setup.sh
```

装完后重启 shell，就能直接开始用。

如果你的机器上 SSH 还没配好，先用上面的 HTTPS 地址就行；之后想改成 SSH，再切换 remote 即可。

常用参数：

```bash
./setup.sh --yes          # 跳过所有提示，全部安装
./setup.sh --dry-run      # 只预览，不实际改动
./setup.sh --no-obsidian  # 跳过 Obsidian 和 vault 脚手架
./setup.sh --no-node      # 跳过 fnm 和 Node.js
./setup.sh --no-qmd       # 跳过 QMD
```

## 你会得到什么

| 层 | 工具 |
|---|---|
| 终端 | Ghostty / Windows Terminal、zsh、Starship、MesloLGS NF |
| CLI 工具链 | bat、eza、fd、ripgrep、fzf、zoxide、btop、jq、tldr、git-delta、lazygit、uv |
| 可选多开器 | `zellij` 或 `tmux`，统一用 `mux` 启动 |
| 可选 AI CLI | Claude Code、Codex CLI、Gemini CLI |
| Node 运行时 | fnm + Node.js LTS |
| 知识工作流 | Obsidian、QMD、vault / project note 脚手架、capture / log / lint 脚本 |

## 支持平台

| 平台 | 状态 | 说明 |
|---|---|---|
| macOS | ✅ 主路径 | Homebrew + 原生 GUI |
| Debian / Ubuntu | ✅ 支持 | apt + 内置二进制 + AppImage 回退 |
| Windows（WSL） | ✅ 支持 | CLI 在 WSL，GUI 应用在 Windows 侧 |
| 原生 Windows shell | ⚠ 仅引导 | `./setup.sh` 会尝试安装 WSL + Ubuntu，然后引导你切到 WSL |

## 安装器会做什么

- `zoxide` 是 `cd` 的升级版，装完后可以用 `z repo-name` 快速跳目录。
- 安装器会检测现有 `tmux` / `zellij`，帮助你固定一个多开器，之后统一用 `mux`。
- 缺失的 AI CLI 会在交互模式下逐个询问，`--yes` 模式会自动安装所有缺失项。
- 如果系统里有 tmux 或 zellij，`setup.sh` 会顺手下发默认配置，并提供跨平台的 `zot-copy` 剪贴板辅助脚本。
- `mux code` 会打开默认 AI 编码布局：左边主 pane，右上 `project-context`，右下 tests / build。
- Claude Code 使用 Anthropic 官方安装器；Codex CLI 和 Gemini CLI 在 Node.js 就绪后通过 npm 安装。
- 在 WSL 下，CLI 工具装在 Linux 侧，脚本还会尽量帮你在 Windows 侧装 Obsidian、Windows Terminal 和 MesloLGS NF 字体。
- 在原生 Windows shell 下，`./setup.sh` 会先尝试执行 `wsl --install -d Ubuntu`，再打印出下一步该怎么进 WSL 继续安装。
- 安装过程中还会把仓库内置的 home-level skill 模板复制到 `~/.codex/skills` 和 `~/.agents/skills`，并把对应的 Claude Code 命令模板复制到 `~/.claude/commands`，默认不覆盖你已有的文件。
- 现有 shell / terminal 配置会先备份，再替换。

## Obsidian vault

```bash
./scripts/init-vault "$HOME/zot-vault"
```

会生成：

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

重启 zsh 后，你会得到这些快捷命令：

```bash
kb          # 跳到 vault
kbs "..."   # 搜索 vault
mux         # 打开你选定的多开器
mux code    # 打开默认 AI 编码布局
```

搜索：

```bash
"$HOME/zot-vault/scripts/kb-search" "上下文工程"
```

抓取、记录、检查：

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

每个 vault 都会把自己的 QMD collection 绑定写到 `kb/meta/tooling.env`，避免多个 vault 不小心共用同一个索引。

## 初始化项目

```bash
./scripts/init-project /path/to/project --vault "$HOME/zot-vault"
```

会生成：

- 项目仓库里的 `AGENTS.md`
- 对应的 Obsidian 项目笔记：`kb/wiki/projects/<project>.md`

理想工作流是：仓库规则放在 `AGENTS.md`，长期项目记忆放在 Obsidian，agent 开工时自动把两者拼成上下文。

## 开始一个工作会话

进入任意项目 repo 后：

```bash
project-context
```

如果要给 agent / 脚本提供机器可读的上下文包：

```bash
project-context --json
# 或：
$ZOT_WORKFLOW_HOME/scripts/start-session --json --vault "$HOME/zot-vault"
```

它会汇总：本地 `AGENTS.md`、本地 `README.md`、匹配的 Obsidian 项目笔记、最近 git 活动，以及检测到的 home-level skills。

## Home-level skills

最可复用的 Obsidian 工作流，不应该散落在每个仓库里复制，而应该放在用户 home 层统一维护。

仓库内置的模板包括：

- `zot-vault-search`
- `zot-vault-ingest`
- `zot-vault-review`
- `.agents/skills/qmd`

这些模板会在 `./setup.sh` 时非破坏性安装；如果你之后想重新同步，也可以手动运行：

```bash
./scripts/install-home-skills
```

如果你用 Claude Code，对应的工作流也会作为 slash command 模板安装到 `~/.claude/commands/zot/`。

## Vault 工作流

把 vault 当成一个持续编译的小型 wiki，而不是资料堆放处：

1. 先把原始材料放进 `kb/raw/**`。
2. 再把有价值的部分整理为 `kb/wiki/**` 下的长期笔记。
3. 更新 `kb/meta/index.md`，并在 `kb/meta/log.md` 追加一条记录。
4. 在 `kb/human/active-output/**` 留下主动回忆或应用练习。
5. 用 `scripts/kb-lint` 做结构检查，工具链改动后再跑 `scripts/kb-smoke-test`。

## 分层规则

| 层 | 作用 |
|---|---|
| `kb/raw/**` | 原始捕获 |
| `kb/wiki/**` | 长期知识与项目记忆 |
| `kb/human/**` | 你的计划、草稿、主动回忆 |
| `AGENTS.md` | 仓库内的 agent 契约 |
| home-level skills | 跨项目复用的 Obsidian 工作流 |

## 设计原则

1. 长期记忆放在 Obsidian。
2. 执行规则贴着代码放在 `AGENTS.md`。
3. 可复用工作流沉淀成 home-level skills。
4. 目录跳转交给 `zoxide`。
5. 多开统一走 `mux`，不要在 tmux / zellij 之间切换心智模型。
6. 尽量减少黑盒，但让上下文重建尽可能自动。

## 发布前检查

```bash
rg -n "api|key|token|secret|password|gmail|@|/Users|/home|/mnt|OPENAI|ANTHROPIC" .
git status --short
git log --stat --oneline -20
```

## 许可证

[MIT](LICENSE)

## 友情链接
[linux_do](https://linux.do)
