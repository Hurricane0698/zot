# Obsidian 工作流

`zot` 里的 Obsidian 部分，目标是尽量简单：

- 仓库规则贴着代码放
- 长期项目记忆放进 vault
- agent 开工时能拿到更干净的上下文

## 创建 Vault

```bash
./scripts/init-vault "$HOME/zot-vault"
```

创建后你会得到这些层：

- `kb/raw/`：原始材料
- `kb/wiki/`：长期笔记和项目记忆
- `kb/human/`：草稿和主动回忆
- `kb/meta/`：索引、日志、review 辅助

## 初始化项目

```bash
./scripts/init-project /path/to/project --vault "$HOME/zot-vault"
```

它会生成：

- 仓库里的 `AGENTS.md`
- `kb/wiki/projects/<project>.md` 作为项目记忆
- `kb/wiki/projects/<project>.standards.md` 作为长期标准包

## 开始一个工作会话

进入项目后：

```bash
project-context
```

如果工具需要机器可读上下文：

```bash
project-context --json
```

这个 JSON 会带上本地文档、项目 note、标准包、最近 git 活动，以及检测到的 home-level skills。

## Home-Level Skills

仓库附带的模板包括：

- `zot-vault-search`
- `zot-vault-ingest`
- `zot-vault-review`
- `zot-vault-wiki`

需要时可以重新安装：

```bash
./scripts/install-home-skills
```

## 一个典型用法

1. 捕获值得留下的内容。
2. 把它整理成长期笔记。
3. 持续维护项目记忆和项目标准。
4. 让 agent 读这些上下文，而不是每次重新教一遍。

## 相关页面

- [快速上手](getting-started.zh-CN.md)
- [README](../README_CN.md)
