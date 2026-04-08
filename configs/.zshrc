#!/bin/zsh
# ─── zot: zsh config ────────────────────────────────────────────────
# Cross-platform: macOS / Debian / Ubuntu / WSL
# Stack: Starship + zsh plugins + fzf + zoxide + fnm + Obsidian/QMD helpers.

# ─── Package manager paths ──────────────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Local user bin paths
for path_entry in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.local/share/fnm"; do
  case ":$PATH:" in
    *":$path_entry:"*) ;;
    *) [[ -d "$path_entry" ]] && export PATH="$path_entry:$PATH" ;;
  esac
done

# ─── zot workflow paths ─────────────────────────────────────────────
export ZOT_WORKFLOW_HOME="${ZOT_WORKFLOW_HOME:-__ZOT_WORKFLOW_HOME__}"
export ZOT_VAULT="${ZOT_VAULT:-$HOME/zot-vault}"
export ZOT_MULTIPLEXER="${ZOT_MULTIPLEXER:-__ZOT_MULTIPLEXER__}"

# ─── Starship prompt ────────────────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ─── Zsh plugins ────────────────────────────────────────────────────
for syntax_file in \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -f "$syntax_file" ]]; then
    source "$syntax_file"
    break
  fi
done

for autosuggest_file in \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -f "$autosuggest_file" ]]; then
    source "$autosuggest_file"
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    break
  fi
done

for completions_dir in \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-completions" \
  "/usr/share/zsh-completions"; do
  if [[ -d "$completions_dir" ]]; then
    fpath=("$completions_dir" $fpath)
    break
  fi
done
autoload -Uz compinit && compinit

# ─── History ────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY INC_APPEND_HISTORY

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# ─── fzf ────────────────────────────────────────────────────────────
if [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
elif command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh 2>/dev/null)"
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ─── zoxide — smarter cd ────────────────────────────────────────────
# Use `z foo` as an upgrade to `cd /some/deep/path/foo`.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ─── fnm / Node.js ──────────────────────────────────────────────────
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# ─── Vault helpers ──────────────────────────────────────────────────
function kb() {
  cd "$ZOT_VAULT"
}

function kb-search() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: kb-search <query>" >&2
    return 1
  fi
  if [[ -x "$ZOT_VAULT/scripts/kb-search" ]]; then
    "$ZOT_VAULT/scripts/kb-search" "$@"
  elif command -v qmd >/dev/null 2>&1; then
    qmd search "$@"
  else
    rg --line-number --smart-case "$*" "$ZOT_VAULT/kb"
  fi
}

# ─── Project helpers ────────────────────────────────────────────────
function zot-init-project() {
  if [[ -x "$ZOT_WORKFLOW_HOME/scripts/init-project" ]]; then
    "$ZOT_WORKFLOW_HOME/scripts/init-project" "$@"
  else
    echo "init-project script not found under $ZOT_WORKFLOW_HOME" >&2
    return 1
  fi
}

# ─── Multiplexer helper ─────────────────────────────────────────────
function mux() {
  local choice="${ZOT_MULTIPLEXER:-auto}"
  local subcommand="${1:-}"
  local target=""

  if [[ "$subcommand" == "help" || "$subcommand" == "--help" || "$subcommand" == "-h" ]]; then
    cat <<'EOF'
Usage:
  mux            Open your preferred multiplexer
  mux code       Open the default AI coding layout in the current directory
  mux code PATH  Open the default AI coding layout for PATH
EOF
    return 0
  fi

  if [[ "$subcommand" == "code" ]]; then
    shift
    if [[ -x "$HOME/.local/bin/zot-mux-code" ]]; then
      "$HOME/.local/bin/zot-mux-code" "$choice" "${1:-$PWD}"
    else
      echo "zot-mux-code is not installed yet. Rerun ./setup.sh to deploy it." >&2
      return 1
    fi
    return $?
  fi

  case "$choice" in
    zellij)
      target="zellij"
      ;;
    tmux)
      target="tmux"
      ;;
    auto|"")
      if command -v zellij >/dev/null 2>&1; then
        target="zellij"
      elif command -v tmux >/dev/null 2>&1; then
        target="tmux"
      fi
      ;;
    *)
      echo "Unknown ZOT_MULTIPLEXER value: $choice" >&2
      return 1
      ;;
  esac

  if [[ -z "$target" ]]; then
    echo "No multiplexer is available yet. Install zellij or tmux, or rerun ./setup.sh." >&2
    return 1
  fi

  if [[ "$target" == "zellij" ]]; then
    command zellij "$@"
    return $?
  fi

  if [[ $# -eq 0 ]]; then
    command tmux new-session -A -s zot
  else
    command tmux "$@"
  fi
}

function project-context() {
  if [[ -x "$ZOT_WORKFLOW_HOME/scripts/start-session" ]]; then
    "$ZOT_WORKFLOW_HOME/scripts/start-session" "$@"
  else
    echo "start-session script not found under $ZOT_WORKFLOW_HOME" >&2
    return 1
  fi
}

# ─── SSH key switcher fallback ──────────────────────────────────────
function set-ssh-key() {
  local key="$HOME/.ssh/$1"
  if [[ ! -f "$key" ]]; then
    echo "Key not found: $key" >&2
    echo "Available keys:" >&2
    ls ~/.ssh/*.pub 2>/dev/null | sed 's/.*\///; s/\.pub$//' >&2
    return 1
  fi
  ssh-add -D 2>/dev/null
  ssh-add "$key"
  echo "Active SSH key: $1"
}

# ─── Aliases ────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias top='btop'
alias lg='lazygit'
alias kbs='kb-search'
alias pctx='project-context'
alias zinit='zot-init-project'
alias mx='mux'
alias mxc='mux code'

# ─── pnpm ───────────────────────────────────────────────────────────
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) [[ -d "$PNPM_HOME" ]] && export PATH="$PNPM_HOME:$PATH" ;;
esac
