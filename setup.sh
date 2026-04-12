#!/usr/bin/env bash
#
# zot — one-command local dev stack bootstrap
#
# Platforms:
#   - macOS
#   - Debian / Ubuntu
#   - Windows via WSL (CLI in WSL, GUI apps on Windows side)
#   - Native Windows shell (bootstrap only: installs WSL and hands off)
#
# What it installs/configures:
#   - Ghostty / Windows Terminal best-effort terminal setup
#   - Obsidian as the unified knowledge/work/context UI
#   - zsh + Starship + modern CLI tools
#   - optional zellij / tmux multiplexer (choose one)
#   - optional AI CLIs: Claude Code, Codex CLI, Gemini CLI
#   - zoxide as a smarter `cd`
#   - fnm + Node.js LTS + QMD (optional)
#   - AGENTS + vault/project-note templates for an Obsidian-first workflow
#
# Usage:
#   ./setup.sh
#   ./setup.sh --yes
#   ./setup.sh --dry-run
#   ./setup.sh --no-obsidian
#   ./setup.sh --no-node
#   ./setup.sh --no-qmd

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

DRY_RUN=false
YES=false
INTERACTIVE=true
SKIP_WINDOWS_SIDE_ACTIONS=false
INSTALL_OBSIDIAN=true
INSTALL_NODE=true
INSTALL_QMD=true
NODE_EXPLICITLY_DISABLED=false
QMD_EXPLICITLY_DISABLED=false
INSTALL_TMUX=false
INSTALL_ZELLIJ=false
PREFERRED_MULTIPLEXER="auto"
INSTALL_CLAUDE_CODE=false
INSTALL_CODEX_CLI=false
INSTALL_GEMINI_CLI=false
MESLO_FONTS=(
  "MesloLGS NF Regular.ttf"
  "MesloLGS NF Bold.ttf"
  "MesloLGS NF Italic.ttf"
  "MesloLGS NF Bold Italic.ttf"
)

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
  exit 1
}

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
}

run_cmd() {
  if $DRY_RUN; then
    printf '%b%s\n' "${YELLOW}[DRY-RUN]${NC} " "$*"
  else
    "$@"
  fi
}

run_shell() {
  if $DRY_RUN; then
    printf '%b%s\n' "${YELLOW}[DRY-RUN]${NC} " "$*"
  else
    bash -lc "$*"
  fi
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_account_shell() {
  local user_name="${USER:-}"
  local shell_path=""

  case "$OS" in
    macos)
      if [[ -n "$user_name" ]] && has_cmd dscl; then
        shell_path="$(dscl . -read "/Users/$user_name" UserShell 2>/dev/null | awk '{print $2}' || true)"
      fi
      ;;
    debian | wsl)
      if [[ -n "$user_name" ]] && has_cmd getent; then
        shell_path="$(getent passwd "$user_name" | cut -d: -f7 || true)"
      elif [[ -n "$user_name" && -r /etc/passwd ]]; then
        shell_path="$(awk -F: -v u="$user_name" '$1 == u { print $7; exit }' /etc/passwd || true)"
      fi
      ;;
  esac

  printf '%s\n' "$shell_path"
}

command_version() {
  local cmd="$1"
  local timeout_cmd=()
  local output=""

  # Some CLIs accidentally read from the interactive TTY during version probes.
  # Keep stdin closed and time-box the check so setup never appears hung.
  if has_cmd timeout; then
    timeout_cmd=(timeout 5s)
  elif has_cmd gtimeout; then
    timeout_cmd=(gtimeout 5s)
  fi

  if [[ ${#timeout_cmd[@]} -gt 0 ]]; then
    output="$("${timeout_cmd[@]}" "$cmd" --version </dev/null 2>/dev/null | head -n1 || true)"
  else
    output="$("$cmd" --version </dev/null 2>/dev/null | head -n1 || true)"
  fi

  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  else
    printf 'installed (version unavailable)\n'
  fi
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-N}"
  local reply=""
  if ! $INTERACTIVE; then
    [[ "$default" =~ ^[Yy]$ ]]
    return
  fi
  if [[ "$default" =~ ^[Yy]$ ]]; then
    read -r -p "$prompt [Y/n] " reply
    [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]
  else
    read -r -p "$prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
  fi
}

section() {
  echo ""
  echo -e "${BOLD}══════════════════════════════════════════${NC}"
  echo -e "${BOLD}  $1${NC}"
  echo -e "${BOLD}══════════════════════════════════════════${NC}"
}

backup_file() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local backup=""
    backup="$path.bak.$(date +%Y%m%d-%H%M%S)"
    run_cmd cp -R "$path" "$backup"
    warn "Backed up $path -> $backup"
  fi
}

detect_os() {
  if [[ -n "${ZOT_SETUP_OS:-}" ]]; then
    printf '%s\n' "$ZOT_SETUP_OS"
    return
  fi

  local uname_out
  uname_out="$(uname -s)"
  case "$uname_out" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
        echo "wsl"
      elif [[ -f /etc/debian_version ]] || grep -qiE 'debian|ubuntu' /etc/os-release 2>/dev/null; then
        echo "debian"
      else
        echo "unsupported"
      fi
      ;;
    MINGW* | MSYS* | CYGWIN*) echo "windows-native" ;;
    *) echo "unsupported" ;;
  esac
}

detect_interactive() {
  if [[ -n "${ZOT_NONINTERACTIVE:-}" || -n "${CI:-}" ]]; then
    return 1
  fi
  [[ -t 0 && -t 1 ]]
}

OS="$(detect_os)"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --yes | -y) YES=true ;;
    --no-obsidian) INSTALL_OBSIDIAN=false ;;
    --no-node)
      INSTALL_NODE=false
      NODE_EXPLICITLY_DISABLED=true
      ;;
    --no-qmd)
      INSTALL_QMD=false
      QMD_EXPLICITLY_DISABLED=true
      ;;
    --help | -h)
      usage
      exit 0
      ;;
    *) error "Unknown option: $arg" ;;
  esac
done

if ! $INSTALL_NODE; then
  INSTALL_QMD=false
fi

case "$OS" in
  macos) info "Detected ${BOLD}macOS${NC}" ;;
  debian) info "Detected ${BOLD}Debian / Ubuntu${NC}" ;;
  wsl) info "Detected ${BOLD}Windows WSL${NC}" ;;
  windows-native) info "Detected ${BOLD}native Windows shell${NC}" ;;
  *)
    error "Unsupported OS: $(uname -s). Supported: macOS, Debian/Ubuntu, Windows WSL, or native Windows as a WSL bootstrap path."
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"
FONT_SRC_DIR="$SCRIPT_DIR/fonts"
[[ -d "$CONFIGS_DIR" ]] || error "Run ./setup.sh from the zot repository root."

if ! detect_interactive; then
  INTERACTIVE=false
  info "Non-interactive shell detected; setup will continue with safe defaults."
fi

if [[ "$OS" == "wsl" ]] && ! $INTERACTIVE; then
  SKIP_WINDOWS_SIDE_ACTIONS=true
  info "Skipping Windows-side installs from this non-interactive WSL session to avoid hanging on GUI or winget prompts."
fi

warn_wsl_checkout() {
  [[ "$OS" == "wsl" ]] || return 0
  case "$SCRIPT_DIR" in
    /mnt/*)
      warn "zot is running from a Windows-mounted path: $SCRIPT_DIR"
      warn "If you hit '/usr/bin/env: bash\\r' or other script execution issues, reclone or move this repo into the WSL filesystem, for example under \$HOME/src."
      ;;
  esac
}

warn_wsl_checkout

if ! $YES && ! $DRY_RUN; then
  echo ""
  echo -e "${BOLD}zot will install/configure:${NC}"
  echo "  - platform: $OS"
  if [[ "$OS" == "windows-native" ]]; then
    echo "  - action: attempt WSL + Ubuntu installation via PowerShell"
    echo "  - handoff: print the exact command to rerun ./setup.sh inside WSL"
  else
    echo "  - shell: zsh"
    echo "  - GUI: Ghostty / Obsidian best effort for this platform"
    echo "  - CLI: starship, eza, bat, fd, ripgrep, fzf, zoxide, jq, tldr, delta, lazygit, uv"
    echo "  - multiplexer: optional tmux or zellij (you will choose one during setup)"
    echo "  - AI CLIs: optional Claude Code, Codex CLI, Gemini CLI"
    echo "  - Node/QMD: Node=${INSTALL_NODE}, QMD=${INSTALL_QMD}"
    echo "  - templates: Obsidian vault + project AGENTS + project-note scaffold"
    echo "  - home skills: bundled Codex/Agents skill templates + Claude command templates"
  fi
  echo ""
  if $INTERACTIVE; then
    read -r -p "Continue? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || error "Aborted."
  else
    info "Proceeding without prompts. Pass --yes to auto-install optional components too."
  fi
fi

choose_multiplexer_plan() {
  local has_tmux_installed=false
  local has_zellij_installed=false
  has_cmd tmux && has_tmux_installed=true
  has_cmd zellij && has_zellij_installed=true

  if $YES || $DRY_RUN || ! $INTERACTIVE; then
    if $has_zellij_installed; then
      PREFERRED_MULTIPLEXER="zellij"
    elif $has_tmux_installed; then
      PREFERRED_MULTIPLEXER="tmux"
    else
      PREFERRED_MULTIPLEXER="auto"
    fi
    return 0
  fi

  echo ""
  info "Terminal multiplexer setup is optional."
  info "Pick one tool for multi-pane sessions so your workflow stays simple."

  if $has_tmux_installed && $has_zellij_installed; then
    warn "Both tmux and zellij are already installed."
    if prompt_yes_no "Use zellij as the default behind the \`mux\` command?" "Y"; then
      PREFERRED_MULTIPLEXER="zellij"
    else
      PREFERRED_MULTIPLEXER="tmux"
    fi
    return 0
  fi

  if $has_zellij_installed; then
    info "Detected zellij on this machine."
    if prompt_yes_no "Keep zellij as your only daily multiplexer and wire \`mux\` to it?" "Y"; then
      PREFERRED_MULTIPLEXER="zellij"
    elif prompt_yes_no "Install tmux instead and make \`mux\` use tmux?" "N"; then
      INSTALL_TMUX=true
      PREFERRED_MULTIPLEXER="tmux"
    else
      PREFERRED_MULTIPLEXER="zellij"
    fi
    return 0
  fi

  if $has_tmux_installed; then
    info "Detected tmux on this machine."
    if prompt_yes_no "Keep tmux as your only daily multiplexer and wire \`mux\` to it?" "Y"; then
      PREFERRED_MULTIPLEXER="tmux"
    elif prompt_yes_no "Install zellij instead and make \`mux\` use zellij?" "N"; then
      INSTALL_ZELLIJ=true
      PREFERRED_MULTIPLEXER="zellij"
    else
      PREFERRED_MULTIPLEXER="tmux"
    fi
    return 0
  fi

  if prompt_yes_no "Install zellij for multi-pane sessions and wire \`mux\` to it?" "N"; then
    INSTALL_ZELLIJ=true
    PREFERRED_MULTIPLEXER="zellij"
  elif prompt_yes_no "Install tmux instead and wire \`mux\` to it?" "N"; then
    INSTALL_TMUX=true
    PREFERRED_MULTIPLEXER="tmux"
  else
    PREFERRED_MULTIPLEXER="auto"
  fi
}

choose_ai_cli_plan() {
  local claude_present=false
  local codex_present=false
  local gemini_present=false

  has_cmd claude && claude_present=true
  has_cmd codex && codex_present=true
  has_cmd gemini && gemini_present=true

  if ! $YES && ! $DRY_RUN && ! $INTERACTIVE; then
    info "Skipping optional AI CLI prompts in non-interactive mode. Pass --yes if you want zot to install all missing AI CLIs."
  elif $YES || $DRY_RUN; then
    if ! $claude_present; then
      INSTALL_CLAUDE_CODE=true
    fi
    if ! $codex_present; then
      INSTALL_CODEX_CLI=true
    fi
    if ! $gemini_present; then
      INSTALL_GEMINI_CLI=true
    fi
  else
    echo ""
    info "Optional AI CLIs can be installed during setup so the machine is ready end-to-end."

    if $claude_present; then
      success "Claude Code already installed: $(command_version claude)"
    elif prompt_yes_no "Install Claude Code now?" "N"; then
      INSTALL_CLAUDE_CODE=true
    fi

    if $codex_present; then
      success "Codex CLI already installed: $(command_version codex)"
    elif prompt_yes_no "Install Codex CLI now?" "N"; then
      INSTALL_CODEX_CLI=true
    fi

    if $gemini_present; then
      success "Gemini CLI already installed: $(command_version gemini)"
    elif prompt_yes_no "Install Gemini CLI now?" "N"; then
      INSTALL_GEMINI_CLI=true
    fi
  fi

  if ! $INSTALL_CODEX_CLI && ! $INSTALL_GEMINI_CLI; then
    return 0
  fi

  if $INSTALL_NODE; then
    return 0
  fi

  if $NODE_EXPLICITLY_DISABLED; then
    if $YES || $DRY_RUN; then
      warn "Skipping Codex CLI and Gemini CLI because --no-node was passed."
      INSTALL_CODEX_CLI=false
      INSTALL_GEMINI_CLI=false
      return 0
    fi

    if prompt_yes_no "Codex CLI and Gemini CLI require Node.js and npm. Re-enable Node.js installation?" "Y"; then
      INSTALL_NODE=true
      if ! $QMD_EXPLICITLY_DISABLED; then
        INSTALL_QMD=true
      fi
    else
      warn "Skipping Codex CLI and Gemini CLI because Node.js remains disabled."
      INSTALL_CODEX_CLI=false
      INSTALL_GEMINI_CLI=false
    fi
  fi
}

ensure_homebrew() {
  if has_cmd brew; then
    success "Homebrew already installed"
  else
    local install_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    info "Installing Homebrew..."
    run_shell "NONINTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL $install_url)\""
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if ! $DRY_RUN; then
    has_cmd brew || error "Homebrew was not found after install. Open a new shell and rerun ./setup.sh."
  fi
}

brew_formula() {
  local pkg="$1"
  if $DRY_RUN; then
    run_cmd brew install "$pkg"
    return 0
  fi
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    success "$pkg already installed"
  else
    info "Installing $pkg..."
    run_cmd brew install "$pkg"
    success "$pkg installed"
  fi
}

brew_cask() {
  local pkg="$1"
  if $DRY_RUN; then
    run_cmd brew install --cask "$pkg"
    return 0
  fi
  if brew list --cask "$pkg" >/dev/null 2>&1; then
    success "$pkg already installed"
  else
    info "Installing $pkg..."
    run_cmd brew install --cask "$pkg"
    success "$pkg installed"
  fi
}

apt_install() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    success "$pkg already installed"
  else
    info "Installing $pkg..."
    run_cmd sudo apt-get install -y "$pkg"
    success "$pkg installed"
  fi
}

apt_try_install() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    success "$pkg already installed"
    return 0
  fi
  if $DRY_RUN; then
    run_cmd sudo apt-get install -y "$pkg"
    return 0
  fi
  sudo apt-get install -y "$pkg" >/dev/null 2>&1
}

install_bundled_linux_bin() {
  local name="$1"
  local src="$SCRIPT_DIR/bin/linux-x86_64/$name"
  local target="$HOME/.local/bin/$name"
  mkdir -p "$HOME/.local/bin"
  if [[ -x "$target" ]]; then
    success "$name already installed in ~/.local/bin"
    return 0
  fi
  [[ -f "$src" ]] || return 1
  info "Installing bundled $name..."
  run_cmd cp "$src" "$target"
  run_cmd chmod +x "$target"
  success "$name installed from bundled binary"
}

ensure_package_manager() {
  section "1/11 Package manager"
  case "$OS" in
    macos)
      ensure_homebrew
      ;;
    debian | wsl)
      info "Updating apt package index..."
      run_cmd sudo apt-get update
      local base_pkgs=(ca-certificates curl git wget unzip xz-utils build-essential python3 python3-venv fontconfig)
      for pkg in "${base_pkgs[@]}"; do
        apt_install "$pkg"
      done
      success "apt is ready"
      ;;
  esac
}

windows_powershell_cmd() {
  local candidate
  for candidate in powershell.exe powershell pwsh.exe pwsh; do
    if has_cmd "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

windows_host_path() {
  local path="$1"
  if has_cmd wslpath; then
    wslpath -w "$path"
    return 0
  fi
  if has_cmd cygpath; then
    cygpath -w "$path"
    return 0
  fi
  python3 - "$path" <<'PY'
import sys

path = sys.argv[1]
if len(path) >= 3 and path[0] == "/" and path[2] == "/":
    drive = path[1].upper()
    rest = path[3:].replace("/", "\\")
    print(f"{drive}:\\{rest}")
else:
    print(path)
PY
}

run_windows_powershell() {
  local script="$1"
  local ps_cmd
  ps_cmd="$(windows_powershell_cmd)" || {
    warn "PowerShell is not available from this shell."
    return 1
  }
  if $DRY_RUN; then
    printf '%b%s\n' "${YELLOW}[DRY-RUN]${NC} " "$ps_cmd -NoProfile -ExecutionPolicy Bypass -Command $script"
  else
    case "$ps_cmd" in
      powershell* | *.exe)
        "$ps_cmd" -NoProfile -ExecutionPolicy Bypass -Command "$script"
        ;;
      *)
        "$ps_cmd" -NoProfile -Command "$script"
        ;;
    esac
  fi
}

run_windows_powershell_file() {
  local script_file="$1"
  shift

  local ps_cmd host_script
  ps_cmd="$(windows_powershell_cmd)" || {
    warn "PowerShell is not available from this shell."
    return 1
  }
  host_script="$(windows_host_path "$script_file")"

  if $DRY_RUN; then
    printf '%b%s\n' "${YELLOW}[DRY-RUN]${NC} " "$ps_cmd -NoProfile -ExecutionPolicy Bypass -File $host_script $*"
    return 0
  fi

  case "$ps_cmd" in
    powershell* | *.exe)
      "$ps_cmd" -NoProfile -ExecutionPolicy Bypass -File "$host_script" "$@"
      ;;
    *)
      "$ps_cmd" -NoProfile -File "$host_script" "$@"
      ;;
  esac
}

bootstrap_native_windows_wsl() {
  section "1/1 Windows -> WSL handoff"

  local bootstrap_script repo_path
  bootstrap_script="$SCRIPT_DIR/scripts/windows/install-wsl.ps1"
  [[ -f "$bootstrap_script" ]] || error "Missing WSL bootstrap script: $bootstrap_script"

  if ! windows_powershell_cmd >/dev/null 2>&1; then
    error "PowerShell is required to bootstrap WSL from native Windows. Open PowerShell or Git Bash and rerun ./setup.sh."
  fi

  repo_path="$(windows_host_path "$SCRIPT_DIR")"

  info "Native Windows is only the bootstrap path."
  info "zot will try to install WSL + Ubuntu, then show you how to rerun setup inside WSL."

  if ! run_windows_powershell_file "$bootstrap_script" -RepoPath "$repo_path" -DryRun:"$DRY_RUN"; then
    error "WSL bootstrap failed. Re-run from an elevated PowerShell, or run: wsl --install -d Ubuntu"
  fi

  if $DRY_RUN; then
    success "WSL bootstrap dry-run complete"
  else
    success "WSL bootstrap finished. Follow the printed instructions, then rerun ./setup.sh inside WSL."
  fi
}

install_windows_app_wsl() {
  local winget_id="$1"
  local app_name="$2"
  if $SKIP_WINDOWS_SIDE_ACTIONS; then
    info "Skipping Windows-side install of $app_name in this non-interactive WSL session."
    return 0
  fi
  if ! windows_powershell_cmd >/dev/null 2>&1; then
    warn "powershell.exe is not available from WSL. Install $app_name manually on Windows."
    return 0
  fi
  info "Attempting Windows-side install of $app_name via winget..."
  if ! run_windows_powershell "if (Get-Command winget -ErrorAction SilentlyContinue) { winget install --id $winget_id --exact --accept-package-agreements --accept-source-agreements --silent } else { Write-Host 'winget not found'; exit 1 }"; then
    warn "Could not auto-install $app_name on Windows. Install it manually from the Windows side if needed."
  else
    success "$app_name install command sent to Windows"
  fi
}

install_windows_fonts_wsl() {
  [[ "$OS" == "wsl" ]] || return 0

  if $SKIP_WINDOWS_SIDE_ACTIONS; then
    info "Skipping Windows-side font installation in this non-interactive WSL session."
    return 0
  fi

  if ! windows_powershell_cmd >/dev/null 2>&1; then
    warn "powershell.exe is not available from WSL. Install MesloLGS NF manually on Windows if Starship icons look broken."
    return 0
  fi

  if ! has_cmd wslpath; then
    warn "wslpath is not available. Install MesloLGS NF manually on Windows if Starship icons look broken."
    return 0
  fi

  local ps_script
  ps_script=$(
    cat <<'PS'
$ErrorActionPreference = 'Stop'
$fontFiles = @(
PS
  )

  local font
  for font in "${MESLO_FONTS[@]}"; do
    local win_font_path escaped_path escaped_name
    win_font_path="$(wslpath -w "$FONT_SRC_DIR/$font")"
    escaped_path="${win_font_path//\'/\'\'}"
    escaped_name="${font//\'/\'\'}"
    ps_script+=$'\n'
    ps_script+="  @{ Path = '$escaped_path'; FileName = '$escaped_name' }"
    ps_script+=$'\n'
  done

  ps_script+=$(
    cat <<'PS'
)

$localFontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$systemFontDir = Join-Path $env:WINDIR 'Fonts'
New-Item -ItemType Directory -Force -Path $localFontDir | Out-Null

foreach ($font in $fontFiles) {
  $sourcePath = $font.Path
  if (-not (Test-Path $sourcePath)) {
    Write-Host "[WARN] Font source not found: $sourcePath"
    continue
  }

  $localTarget = Join-Path $localFontDir $font.FileName
  $systemTarget = Join-Path $systemFontDir $font.FileName
  if ((Test-Path $localTarget) -or (Test-Path $systemTarget)) {
    Write-Host "[OK] Windows font already installed: $($font.FileName)"
    continue
  }

  Start-Process -FilePath $sourcePath -Verb Install -WindowStyle Hidden -Wait

  if ((Test-Path $localTarget) -or (Test-Path $systemTarget)) {
    Write-Host "[OK] Installed Windows font: $($font.FileName)"
  } else {
    Write-Host "[WARN] Windows did not report $($font.FileName) as installed. You may need to set Windows Terminal to MesloLGS NF manually."
  }
}
PS
  )

  info "Attempting Windows-side install of MesloLGS NF so Windows Terminal can render Starship icons."
  if ! run_windows_powershell "$ps_script"; then
    warn "Could not auto-install MesloLGS NF on Windows. If Starship icons look broken, install the bundled fonts manually from ./fonts on the Windows side."
  fi
}

install_ghostty_linux() {
  if has_cmd ghostty; then
    success "Ghostty already installed"
    return 0
  fi
  if apt_try_install ghostty; then
    success "Ghostty installed"
  else
    warn "Ghostty is not available from apt on this machine. Install it manually if you want Ghostty specifically."
  fi
}

install_obsidian_appimage_linux() {
  if has_cmd obsidian; then
    success "Obsidian launcher already available"
    return 0
  fi

  local app_dir="$HOME/Applications"
  local bin_dir="$HOME/.local/bin"
  local tmp_json
  local download_url
  local asset_name
  tmp_json="$(mktemp)"

  info "Installing Obsidian AppImage..."
  run_cmd mkdir -p "$app_dir" "$bin_dir"

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest > $tmp_json"
    echo -e "${YELLOW}[DRY-RUN]${NC} create $bin_dir/obsidian wrapper"
    return 0
  fi

  curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest >"$tmp_json"
  download_url="$(
    python3 - "$tmp_json" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)
for asset in data.get('assets', []):
    name = asset.get('name', '')
    if name.endswith('.AppImage'):
        print(asset.get('browser_download_url', ''))
        break
PY
  )"
  [[ -n "$download_url" ]] || error "Could not determine latest Obsidian AppImage URL."
  asset_name="${download_url##*/}"

  curl -L "$download_url" -o "$app_dir/$asset_name"
  chmod u+x "$app_dir/$asset_name"

  cat >"$bin_dir/obsidian" <<WRAP
#!/usr/bin/env bash
exec "$app_dir/$asset_name" --no-sandbox "\$@"
WRAP
  chmod +x "$bin_dir/obsidian"
  success "Obsidian installed as AppImage wrapper: $bin_dir/obsidian"
}

install_terminal_and_gui() {
  section "2/11 Terminal and GUI"
  case "$OS" in
    macos)
      brew_cask ghostty
      if $INSTALL_OBSIDIAN; then
        brew_cask obsidian
      else
        info "Skipping Obsidian.app"
      fi
      ;;
    debian)
      install_ghostty_linux
      if $INSTALL_OBSIDIAN; then
        install_obsidian_appimage_linux
      else
        info "Skipping Obsidian"
      fi
      ;;
    wsl)
      info "WSL keeps CLI tools inside Linux and GUI apps on the Windows side."
      install_windows_app_wsl "Microsoft.WindowsTerminal" "Windows Terminal"
      if $INSTALL_OBSIDIAN; then
        install_windows_app_wsl "Obsidian.Obsidian" "Obsidian"
      else
        info "Skipping Obsidian"
      fi
      ;;
  esac
}

install_fonts() {
  section "3/11 Fonts"
  local font_dir
  case "$OS" in
    macos) font_dir="$HOME/Library/Fonts" ;;
    debian | wsl) font_dir="$HOME/.local/share/fonts" ;;
  esac

  run_cmd mkdir -p "$font_dir"
  local font
  for font in "${MESLO_FONTS[@]}"; do
    if [[ -f "$font_dir/$font" ]]; then
      success "$font already installed"
    else
      info "Installing $font..."
      run_cmd cp "$FONT_SRC_DIR/$font" "$font_dir/$font"
    fi
  done

  if [[ "$OS" == "debian" || "$OS" == "wsl" ]]; then
    if has_cmd fc-cache; then
      run_cmd fc-cache -fv "$font_dir"
    fi
  fi

  install_windows_fonts_wsl
}

install_zsh_stack() {
  section "4/11 Zsh stack"
  case "$OS" in
    macos)
      local pkgs=(zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
      for pkg in "${pkgs[@]}"; do brew_formula "$pkg"; done
      ;;
    debian | wsl)
      apt_install zsh
      if ! apt_try_install zsh-autosuggestions; then
        if [[ ! -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
          info "Cloning zsh-autosuggestions..."
          run_cmd sudo git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions
        fi
      fi
      if ! apt_try_install zsh-syntax-highlighting; then
        if [[ ! -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
          info "Cloning zsh-syntax-highlighting..."
          run_cmd sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting /usr/share/zsh-syntax-highlighting
        fi
      fi
      apt_try_install zsh-completions || true
      ;;
  esac

  local zsh_path
  local account_shell
  zsh_path="$(command -v zsh)"
  account_shell="$(detect_account_shell)"
  if [[ "$account_shell" != "$zsh_path" ]]; then
    info "Setting zsh as default login shell..."
    run_cmd chsh -s "$zsh_path"
    if ! $DRY_RUN; then
      account_shell="$(detect_account_shell)"
      if [[ "$account_shell" == "$zsh_path" ]]; then
        success "zsh is now your default login shell"
      else
        warn "zsh was installed, but your login shell still looks like: ${account_shell:-unknown}"
        warn "On Ubuntu / GNOME, closing one terminal tab is often not enough after \`chsh\`."
        warn "Fully log out of the desktop session, or run \`exec zsh\` once to verify the new shell immediately."
      fi
    fi
  else
    success "zsh is already the default login shell"
  fi
}

install_cli_tools() {
  section "5/11 CLI runtime"
  case "$OS" in
    macos)
      local mac_tools=(starship bat eza fd ripgrep fzf btop zoxide jq tealdeer git-delta lazygit uv fnm)
      for tool in "${mac_tools[@]}"; do brew_formula "$tool"; done
      ;;
    debian | wsl)
      local apt_tools=(bat fd-find ripgrep fzf jq btop)
      for tool in "${apt_tools[@]}"; do apt_install "$tool"; done

      mkdir -p "$HOME/.local/bin"
      if has_cmd batcat && ! has_cmd bat; then
        run_cmd ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
      fi
      if has_cmd fdfind && ! has_cmd fd; then
        run_cmd ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
      fi

      if has_cmd zoxide; then
        success "zoxide already installed"
      else
        if apt_try_install zoxide; then
          success "zoxide installed"
        else
          info "Installing zoxide via bundled helper..."
          run_cmd bash "$SCRIPT_DIR/scripts/install-zoxide.sh"
          success "zoxide installed"
        fi
      fi

      for tool in starship eza tldr delta lazygit; do
        if has_cmd "$tool"; then
          success "$tool already installed"
        elif install_bundled_linux_bin "$tool"; then
          :
        else
          warn "$tool is not available right now; install it manually if needed."
        fi
      done

      if has_cmd uv; then
        success "uv already installed"
      else
        info "Installing uv..."
        run_shell 'curl -LsSf https://astral.sh/uv/install.sh | sh'
        success "uv installed"
      fi
      ;;
  esac
}

install_tmux_tool() {
  case "$OS" in
    macos)
      brew_formula tmux
      ;;
    debian | wsl)
      apt_install tmux
      ;;
  esac
}

install_zellij_tool() {
  case "$OS" in
    macos)
      brew_formula zellij
      ;;
    debian | wsl)
      if apt_try_install zellij; then
        success "zellij installed"
      else
        warn "zellij is not available from apt on this machine."
        return 1
      fi
      ;;
  esac
}

install_optional_multiplexer() {
  section "6/11 Optional multiplexer"

  if $INSTALL_ZELLIJ; then
    info "Installing zellij and setting it as the preferred \`mux\` target..."
    if install_zellij_tool; then
      PREFERRED_MULTIPLEXER="zellij"
      success "zellij is ready"
      return 0
    fi

    if ! $YES && ! $DRY_RUN && prompt_yes_no "zellij was unavailable. Install tmux instead and make \`mux\` use tmux?" "Y"; then
      INSTALL_ZELLIJ=false
      INSTALL_TMUX=true
      PREFERRED_MULTIPLEXER="tmux"
    else
      warn "Skipping multiplexer install for now. You can still use \`mux\` later once zellij or tmux exists."
      PREFERRED_MULTIPLEXER="auto"
      return 0
    fi
  fi

  if $INSTALL_TMUX; then
    info "Installing tmux and setting it as the preferred \`mux\` target..."
    install_tmux_tool
    PREFERRED_MULTIPLEXER="tmux"
    success "tmux is ready"
    return 0
  fi

  case "$PREFERRED_MULTIPLEXER" in
    zellij)
      success "Using existing zellij as the preferred \`mux\` target"
      ;;
    tmux)
      success "Using existing tmux as the preferred \`mux\` target"
      ;;
    *)
      info "No dedicated multiplexer selected. The \`mux\` helper will auto-detect zellij or tmux later."
      ;;
  esac
}

install_node_and_qmd() {
  section "7/11 Node + search tooling"
  if ! $INSTALL_NODE; then
    info "Skipping Node and QMD"
    return 0
  fi

  case "$OS" in
    macos)
      brew_formula fnm
      ;;
    debian | wsl)
      if ! has_cmd fnm; then
        info "Installing fnm..."
        run_shell 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell'
      else
        success "fnm already installed"
      fi
      export PATH="$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"
      ;;
  esac

  if ! has_cmd fnm && ! $DRY_RUN; then
    error "fnm was not found after install. Open a new shell and rerun ./setup.sh."
  fi

  if has_cmd fnm || $DRY_RUN; then
    if $DRY_RUN; then
      run_cmd fnm install --lts
      run_cmd fnm default lts-latest
    else
      eval "$(fnm env --use-on-cd --shell bash)"
      if ! has_cmd node; then
        info "Installing Node.js LTS via fnm..."
        run_cmd fnm install --lts
        run_cmd fnm default lts-latest
        run_cmd fnm use lts-latest
      else
        success "Node available: $(node --version 2>/dev/null || true)"
      fi
    fi
  fi

  if ! $INSTALL_QMD; then
    info "Skipping QMD"
    return 0
  fi

  if $DRY_RUN; then
    run_cmd npm install -g @tobilu/qmd
    return 0
  fi

  has_cmd npm || error "npm not found after Node setup."
  info "Installing QMD..."
  run_cmd npm install -g @tobilu/qmd
  success "QMD installed"
}

install_claude_code_cli() {
  if has_cmd claude; then
    success "Claude Code already installed: $(command_version claude)"
    return 0
  fi

  info "Installing Claude Code with the native installer..."
  run_shell 'curl -fsSL https://claude.ai/install.sh | bash'
  if $DRY_RUN; then
    return 0
  fi

  if has_cmd claude; then
    success "Claude Code installed: $(command_version claude)"
  else
    warn "Claude Code install finished, but \`claude\` is not yet on PATH in this shell. Restart your shell if needed."
  fi
}

install_codex_cli() {
  if has_cmd codex; then
    success "Codex CLI already installed: $(command_version codex)"
    return 0
  fi

  if ! has_cmd npm && ! $DRY_RUN; then
    error "npm is required to install Codex CLI, but it is not available."
  fi

  info "Installing Codex CLI..."
  run_cmd npm i -g @openai/codex
  if $DRY_RUN; then
    return 0
  fi

  if has_cmd codex; then
    success "Codex CLI installed: $(command_version codex)"
  else
    warn "Codex CLI install finished, but \`codex\` is not yet on PATH in this shell. Restart your shell if needed."
  fi
}

install_gemini_cli() {
  if has_cmd gemini; then
    success "Gemini CLI already installed: $(command_version gemini)"
    return 0
  fi

  if ! has_cmd npm && ! $DRY_RUN; then
    error "npm is required to install Gemini CLI, but it is not available."
  fi

  info "Installing Gemini CLI..."
  run_cmd npm install -g @google/gemini-cli
  if $DRY_RUN; then
    return 0
  fi

  if has_cmd gemini; then
    success "Gemini CLI installed: $(command_version gemini)"
  else
    warn "Gemini CLI install finished, but \`gemini\` is not yet on PATH in this shell. Restart your shell if needed."
  fi
}

install_ai_clis() {
  section "8/11 Optional AI CLIs"

  if has_cmd claude && ! $INSTALL_CLAUDE_CODE; then
    success "Claude Code already installed: $(command_version claude)"
  fi
  if has_cmd codex && ! $INSTALL_CODEX_CLI; then
    success "Codex CLI already installed: $(command_version codex)"
  fi
  if has_cmd gemini && ! $INSTALL_GEMINI_CLI; then
    success "Gemini CLI already installed: $(command_version gemini)"
  fi

  if ! $INSTALL_CLAUDE_CODE && ! $INSTALL_CODEX_CLI && ! $INSTALL_GEMINI_CLI; then
    info "No new AI CLIs selected for installation."
    return 0
  fi

  if $INSTALL_CLAUDE_CODE; then
    install_claude_code_cli
  fi
  if $INSTALL_CODEX_CLI; then
    install_codex_cli
  fi
  if $INSTALL_GEMINI_CLI; then
    install_gemini_cli
  fi
}

render_template_placeholders() {
  local file="$1"
  local multiplexer="$2"
  python3 - "$file" "$SCRIPT_DIR" "$multiplexer" <<'PY'
from pathlib import Path
import sys
file_path = Path(sys.argv[1])
workflow_home = sys.argv[2]
preferred_multiplexer = sys.argv[3]
text = file_path.read_text()
text = text.replace('__ZOT_WORKFLOW_HOME__', workflow_home)
text = text.replace('__ZOT_MULTIPLEXER__', preferred_multiplexer)
file_path.write_text(text)
PY
}

deploy_configs() {
  section "9/11 Config files"
  run_cmd mkdir -p "$HOME/.config"
  run_cmd mkdir -p "$HOME/.local/bin"

  backup_file "$HOME/.local/bin/zot-copy"
  run_cmd cp "$CONFIGS_DIR/zot-copy" "$HOME/.local/bin/zot-copy"
  run_cmd chmod +x "$HOME/.local/bin/zot-copy"
  success "Clipboard helper deployed"

  backup_file "$HOME/.local/bin/zot-doctor"
  run_cmd cp "$CONFIGS_DIR/zot-doctor" "$HOME/.local/bin/zot-doctor"
  run_cmd chmod +x "$HOME/.local/bin/zot-doctor"
  success "Diagnostics helper deployed"

  backup_file "$HOME/.local/bin/zot-mux-code"
  run_cmd cp "$CONFIGS_DIR/zot-mux-code" "$HOME/.local/bin/zot-mux-code"
  run_cmd chmod +x "$HOME/.local/bin/zot-mux-code"
  success "Multiplexer code-layout helper deployed"

  backup_file "$HOME/.config/starship.toml"
  run_cmd cp "$CONFIGS_DIR/starship.toml" "$HOME/.config/starship.toml"
  success "Starship config deployed"

  local ghostty_dir
  case "$OS" in
    macos) ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty" ;;
    debian | wsl) ghostty_dir="$HOME/.config/ghostty" ;;
  esac
  run_cmd mkdir -p "$ghostty_dir"
  backup_file "$ghostty_dir/config"
  run_cmd cp "$CONFIGS_DIR/ghostty.config" "$ghostty_dir/config"
  success "Ghostty config deployed"

  backup_file "$HOME/.zshrc"
  run_cmd cp "$CONFIGS_DIR/.zshrc" "$HOME/.zshrc"
  if ! $DRY_RUN; then
    render_template_placeholders "$HOME/.zshrc" "$PREFERRED_MULTIPLEXER"
  fi
  success "zsh config deployed"

  if [[ "$PREFERRED_MULTIPLEXER" == "tmux" ]] || { [[ "$PREFERRED_MULTIPLEXER" == "auto" ]] && has_cmd tmux; }; then
    backup_file "$HOME/.tmux.conf"
    run_cmd cp "$CONFIGS_DIR/.tmux.conf" "$HOME/.tmux.conf"
    success "tmux config deployed"
  fi

  if [[ "$PREFERRED_MULTIPLEXER" == "zellij" ]] || { [[ "$PREFERRED_MULTIPLEXER" == "auto" ]] && has_cmd zellij; }; then
    local zellij_config_dir
    case "$OS" in
      macos) zellij_config_dir="$HOME/Library/Application Support/org.Zellij-Contributors.Zellij" ;;
      debian | wsl) zellij_config_dir="$HOME/.config/zellij" ;;
    esac
    run_cmd mkdir -p "$zellij_config_dir"
    backup_file "$zellij_config_dir/config.kdl"
    run_cmd cp "$CONFIGS_DIR/zellij.kdl" "$zellij_config_dir/config.kdl"
    run_cmd mkdir -p "$zellij_config_dir/layouts"
    backup_file "$zellij_config_dir/layouts/zot-code.kdl"
    run_cmd cp "$CONFIGS_DIR/zellij/layouts/zot-code.kdl" "$zellij_config_dir/layouts/zot-code.kdl"
    success "zellij config deployed"
  fi

  if has_cmd delta || $DRY_RUN; then
    info "Configuring git-delta as git pager..."
    run_cmd git config --global core.pager delta
    run_cmd git config --global interactive.diffFilter "delta --color-only"
    run_cmd git config --global delta.navigate true
    run_cmd git config --global delta.dark true
    run_cmd git config --global delta.line-numbers true
    run_cmd git config --global delta.side-by-side true
    run_cmd git config --global merge.conflictstyle diff3
    run_cmd git config --global diff.colorMoved default
    success "git-delta configured"
  fi
}

install_home_skill_templates() {
  section "10/11 Home-level skills"
  info "Installing bundled Codex / Agents skill templates and Claude command templates..."
  run_cmd bash "$SCRIPT_DIR/scripts/install-home-skills"
  success "Home-level skill templates deployed"
}

print_next_steps() {
  section "11/11 Done"
  if $DRY_RUN; then
    echo -e "${YELLOW}${BOLD}Dry-run complete — no changes were made.${NC}"
  else
    echo -e "${GREEN}${BOLD}zot setup complete.${NC}"
  fi

  cat <<EOF2

Next steps:
  1. Open a brand-new shell.
     If Ubuntu / GNOME still looks unchanged, run ${BOLD}exec zsh${NC} once to test, or fully log out of the desktop session after ${BOLD}chsh${NC}.
  2. Verify shell activation:
       echo "\$SHELL"
       echo "\$0"
       "\$HOME/.local/bin/zot-doctor" shell
  3. If you installed AI CLIs, run ${BOLD}claude${NC}, ${BOLD}codex${NC}, or ${BOLD}gemini${NC} once to complete sign-in.
  4. Create your vault:
       ./scripts/init-vault "\$HOME/zot-vault"
  5. Initialize any repo with AGENTS + project note + standards pack:
       ./scripts/init-project /path/to/project --vault "\$HOME/zot-vault"
  6. In a project repo, print a working context bundle:
       project-context
  7. Reinstall bundled home-level skill templates if needed:
       ./scripts/install-home-skills

Mental model:
  - local environment = fast terminal + modern CLI + optional multiplexer
  - AI CLIs = Claude Code, Codex, and Gemini ready to sign in when you need them
  - Obsidian vault = learning + work + permanent context
  - AGENTS.md = local execution contract
  - home-level skills = reusable Obsidian workflows
  - zoxide = smarter cd; use ${BOLD}z repo-name${NC} instead of hunting paths manually
  - mux = one stable entrypoint for zellij or tmux, so you do not have to juggle both
  - curated tmux/zellij defaults are deployed for you and backed up if you already had config
EOF2
}

if [[ "$OS" == "windows-native" ]]; then
  bootstrap_native_windows_wsl
  exit 0
fi

choose_multiplexer_plan
choose_ai_cli_plan
ensure_package_manager
install_terminal_and_gui
install_fonts
install_zsh_stack
install_cli_tools
install_optional_multiplexer
install_node_and_qmd
install_ai_clis
deploy_configs
install_home_skill_templates
print_next_steps
