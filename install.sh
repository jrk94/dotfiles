#!/bin/bash
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
# Set DEBUG=1 to enable bash -x tracing:  DEBUG=1 bash install.sh
DEBUG="${DEBUG:-0}"
LOG_FILE="${LOG_FILE:-$HOME/.dotfiles-install.log}"
CURL_TIMEOUT="${CURL_TIMEOUT:-30}"      # max seconds for any single download
STEP_TIMEOUT="${STEP_TIMEOUT:-120}"     # max seconds for any install step

# ── Logging helpers ───────────────────────────────────────────────────────────
log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG_FILE"; }
err() { printf '[%s] [ERR] %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG_FILE" >&2; }

# ── Redirect all output to log file too ──────────────────────────────────────
exec > >(tee -a "$LOG_FILE") 2>&1

# ── Enable bash -x tracing when DEBUG=1 ──────────────────────────────────────
[ "$DEBUG" = "1" ] && set -x

# ── Trap: print the failing line + log path on any error ─────────────────────
trap 'err "Failed at line $LINENO (exit $?). Full log: $LOG_FILE"' ERR

log "==> Starting dotfiles install  (log: $LOG_FILE)"
log "    Shell=$SHELL  User=$USER  HOME=$HOME  DEBUG=$DEBUG"

# ── Network check ─────────────────────────────────────────────────────────────
log "==> Checking network connectivity..."
if ! timeout 10 curl -fsSL --connect-timeout 5 --max-time 10 \
        https://github.com > /dev/null 2>&1; then
    err "Cannot reach github.com — check your network or proxy settings. Aborting."
    exit 1
fi
log "    Network OK"

# ── Check for passwordless sudo (non-blocking) ────────────────────────────────
HAVE_SUDO=0
if sudo -n true 2>/dev/null; then
    HAVE_SUDO=1
    log "    sudo OK (passwordless)"
else
    err "sudo requires a password or is unavailable — skipping apt steps."
    err "Run manually:  sudo apt-get install -y fzf zsh curl git"
    err "Then re-run this script."
fi

# ── Install dependencies via apt ───────────────────────────────────────────────
if [ "$HAVE_SUDO" = "1" ]; then
    log "==> apt-get update..."
    DEBIAN_FRONTEND=noninteractive timeout "$STEP_TIMEOUT" \
        sudo apt-get update -q

    log "==> apt-get install fzf zsh curl git..."
    DEBIAN_FRONTEND=noninteractive timeout "$STEP_TIMEOUT" \
        sudo apt-get install -y fzf zsh curl git
fi

# ── Helper: download a script to a temp file (with timeout + size sanity) ────
download_script() {
    local url="$1" tmp
    tmp=$(mktemp)
    log "    Downloading: $url"
    if ! timeout "$CURL_TIMEOUT" curl -fsSL \
            --connect-timeout 10 --max-time "$CURL_TIMEOUT" \
            --retry 2 --retry-delay 3 \
            -o "$tmp" "$url"; then
        err "Download failed or timed out: $url"
        rm -f "$tmp"
        return 1
    fi
    # Sanity: reject suspiciously small files (< 100 bytes → probably an error page)
    local size
    size=$(wc -c < "$tmp")
    if [ "$size" -lt 100 ]; then
        err "Downloaded file is too small ($size bytes) — likely an error response: $url"
        rm -f "$tmp"
        return 1
    fi
    echo "$tmp"
}

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "==> Installing oh-my-zsh..."
    _script=$(download_script \
        "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh")
    RUNZSH=no CHSH=no timeout "$STEP_TIMEOUT" sh "$_script"
    rm -f "$_script"
else
    log "==> oh-my-zsh already present — skipping"
fi

# ── oh-my-posh ───────────────────────────────────────────────────────────────
if ! command -v oh-my-posh &> /dev/null; then
    log "==> Installing oh-my-posh..."
    _script=$(download_script "https://ohmyposh.dev/install.sh")
    timeout "$STEP_TIMEOUT" bash "$_script" -d ~/.local/bin
    rm -f "$_script"
else
    log "==> oh-my-posh already present — skipping"
fi

# ── zoxide ───────────────────────────────────────────────────────────────────
if ! command -v zoxide &> /dev/null; then
    log "==> Installing zoxide..."
    _script=$(download_script \
        "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh")
    timeout "$STEP_TIMEOUT" sh "$_script"
    rm -f "$_script"
else
    log "==> zoxide already present — skipping"
fi

# ── Symlink .zshrc ────────────────────────────────────────────────────────────
log "==> Linking .zshrc..."
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    log "    Backed up existing .zshrc → .zshrc.bak"
fi
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

log "==> Done. Restart your shell or run:  source ~/.zshrc"
log "    Full log saved to: $LOG_FILE"
