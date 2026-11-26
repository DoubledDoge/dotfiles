#!/usr/bin/env bash

set -euo pipefail

REPO="doubleddoge/dotfiles"

LIB_BASE="https://raw.githubusercontent.com/$REPO/main/chezmoi-source/.chezmoitemplates"

fetch_lib() {
    local src
    src="$(curl -fsSL "$LIB_BASE/$1.sh")" || {
        echo "error: could not fetch $1.sh" >&2
        exit 1
    }
    eval "$src"
}

fetch_lib common


if ! command -v git >/dev/null 2>&1; then
    install "git"
    if [ -f /etc/debian_version ]; then
        as_root apt update && as_root apt install -y git
    elif [ -f /etc/arch-release ]; then
        as_root pacman -Syu --noconfirm git
    elif [ -f /etc/fedora-release ]; then
        as_root dnf install -y git
    fi
fi

if ! command -v chezmoi >/dev/null 2>&1; then
    install "chezmoi"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

log "Running chezmoi init --apply"
chezmoi init --apply "$REPO"

echo "=== Setup complete! Restart your shell to see changes. ==="
