#!/bin/bash
set -e

# Configuration
REPO_URL="https://github.com/doubleddoge/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

echo "=== Linux Dotfiles Bootstrap ==="

# 1. Install Prerequisites
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y git
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm git
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install -y git
    fi
fi

if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    if [ -f /etc/debian_version ]; then
        sudo apt install -y ansible
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm ansible
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install -y ansible
    fi
fi

# 2. Clone Repository
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Updating repository..."
    cd "$DOTFILES_DIR" && git pull
fi

# 3. Execute Ansible Playbook
echo "Running Ansible setup..."
cd "$DOTFILES_DIR/ansible"
ansible-galaxy collection install -r requirements.yml
ansible-playbook setup.yml

echo "=== Setup Complete! ==="
echo "Please restart your shell to see changes."
