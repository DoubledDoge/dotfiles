#!/usr/bin/env bash

set -euo pipefail

REPO="doubleddoge/dotfiles"

if ! command -v git >/dev/null 2>&1; then
    echo "==> Installing git"
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y git
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Syu --noconfirm git
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install -y git
    fi
fi

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "==> Installing chezmoi"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "==> Running chezmoi init --apply"
chezmoi init --apply "$REPO"

echo "=== Setup complete! Restart your shell to see changes. ==="
