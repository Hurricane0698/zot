# 快速上手

## 安装

```bash
git clone https://github.com/Hurricane0698/zot.git
cd zot
./setup.sh
```

然后打开一个新的 shell。

如果 shell 看起来没切过来，运行：

```bash
"$HOME/.local/bin/zot-doctor" shell
```

## 常用参数

- `./setup.sh --yes`：尽量少问问题，直接安装
- `./setup.sh --dry-run`：先预览变更
- `./setup.sh --no-obsidian`：跳过 Obsidian 和 vault 初始化
- `./setup.sh --no-node`：跳过 Node.js 和 Node 相关工具
- `./setup.sh --no-qmd`：跳过 QMD

## 第一步

1. 创建一个 vault。
2. 给项目初始化上下文。
3. 在项目里启动上下文会话。

```bash
./scripts/init-vault "$HOME/zot-vault"
./scripts/init-project /path/to/project --vault "$HOME/zot-vault"
cd /path/to/project
project-context
```

## 会装什么

- 终端环境：Ghostty 或 Windows Terminal、zsh、Starship
- CLI 工具：ripgrep、fzf、zoxide、jq、lazygit、delta、uv 等
- 可选多开器：`tmux` 或 `zellij`，统一通过 `mux` 使用
- 可选 AI CLI：Claude Code、Codex CLI、Gemini CLI
- Obsidian 工作流辅助：vault 脚手架、search、capture、log、lint、smoke test

## 下一步

- [Obsidian 工作流](obsidian-workflow.zh-CN.md)
- [README](../README_CN.md)
