#!/usr/bin/env bash
# ========================================
# XDG BASE DIRECTORY SPECIFICATION
# ========================================

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# ========================================
# APPLICATION-SPECIFIC CONFIGURATION
# ========================================

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$PATH:$HOME/.dotnet/tools"

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"

export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"
export PYTHONHISTFILE="$XDG_STATE_HOME/python/history"

export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

export LESSHISTFILE="$XDG_STATE_HOME/less/history"

export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# ========================================
# DISPLAY & LOCALE
# ========================================

if [ -z "$LANG" ]; then
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
fi

if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    export QT_QPA_PLATFORMTHEME="qt5ct"
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
fi

# ========================================
# PERFORMANCE / BEHAVIOR
# ========================================

export SYSTEMD_PAGER=""

# ========================================
# GPG
# ========================================

if command -v gpg >/dev/null 2>&1; then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi

# ========================================
# SSH AGENT
# ========================================

if command -v ssh-agent >/dev/null 2>&1; then
    if [ ! -S "$SSH_AUTH_SOCK" ] 2>/dev/null; then
        SSH_ENV="$XDG_STATE_HOME/ssh/agent-environment"
        mkdir -p "$(dirname "$SSH_ENV")"

        if [ -f "$SSH_ENV" ]; then
            # shellcheck disable=SC1090
            . "$SSH_ENV" >/dev/null
        fi

        if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
            (umask 077; ssh-agent -s > "$SSH_ENV")
            # shellcheck disable=SC1090
            . "$SSH_ENV" >/dev/null
        fi
    fi
fi
