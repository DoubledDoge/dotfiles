#!/usr/bin/env bash

# ========================================
# SHARED ENVIRONMENT
# ========================================

DOTFILES_EDITOR_BIN="$(command -v micro || echo nano)"
export EDITOR="$DOTFILES_EDITOR_BIN"
export VISUAL="$EDITOR"

if command -v gpg >/dev/null 2>&1; then
    DOTFILES_GPG_TTY="$(tty)"
    export GPG_TTY="$DOTFILES_GPG_TTY"
fi

export COLORTERM=truecolor
export TERM=xterm-256color

# ========================================
# PATH
# ========================================

add_to_path() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}

add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.dotnet/tools"
add_to_path "$HOME/.dotnet/bin"
add_to_path "$HOME/go/bin"
add_to_path "$HOME/.spicetify"
add_to_path "$HOME/.cargo/bin"

# ========================================
# FZF
# ========================================

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always --level=2 {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' --height 60% --border --layout=reverse"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {} | head -200' --height 60% --border --layout=reverse"
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --inline-info --color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,gutter:#191724 --color=spinner:#f6c177,info:#9ccfd8,separator:#403d52 --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# ========================================
# Flatpak
# ========================================

export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"   