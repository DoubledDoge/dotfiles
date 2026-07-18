#!/usr/bin/env bash
# ========================================
# SHARED FUNCTIONS
# ========================================

mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

tre() {
    command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null
}

weather() {
    local city="${1:-Cape Town}"
    curl -s "wttr.in/${city}?format=3"
}

sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p)"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d ':' -f2 | xargs)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(/usr/bin/df  / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
}

if command -v yazi >/dev/null 2>&1; then
    y() {
        local tmp
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd" || return
        fi
        rm -f -- "$tmp"
    }
fi

# ========================================
# LAZY-LOADED VERSION MANAGERS
# ========================================

if [ -d "$HOME/.nvm" ]; then
    nvm() {
        unset -f nvm
        export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=SC1091
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && [ -n "$BASH_VERSION" ] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
    }
fi

if [ -d "$HOME/.rbenv" ]; then
    rbenv() {
        unset -f rbenv
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(command rbenv init - "$__DOTFILES_SHELL_NAME")"
        rbenv "$@"
    }
fi
