#!/usr/bin/env bash

# ========================================
# BASH Configuration
# ========================================

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ========================================
# BASH OPTIONS & BEHAVIOR
# ========================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$XDG_CONFIG_HOME/bash"

HISTSIZE=10000
HISTFILESIZE=20000
HISTFILE="${XDG_CONFIG_HOME}/bash/bash_history"

HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help:clear:history"
HISTTIMEFORMAT='%F %T '

shopt -s histappend    
shopt -s checkwinsize
shopt -s expand_aliases
shopt -s cmdhist
shopt -s dotglob
shopt -s extglob
shopt -s globstar
shopt -s nocaseglob
shopt -s cdspell
shopt -s dirspell
shopt -s autocd

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ========================================
# ENVIRONMENT VARIABLES
# ========================================

export EDITOR="$(command -v micro || echo nano)"
export VISUAL="$EDITOR"

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

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always --level=2 {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' --height 60% --border --layout=reverse"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {} | head -200' --height 60% --border --layout=reverse"
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --inline-info --color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,gutter:#191724 --color=spinner:#f6c177,info:#9ccfd8,separator:#403d52 --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

export COLORTERM=truecolor
export TERM=xterm-256color

# ========================================
# PROMPT & THEME
# ========================================

# Track background jobs so the prompt can display the count
_update_bg_jobs() { export BG_JOBS="$(jobs -r | wc -l | tr -d ' ')"; }
PROMPT_COMMAND="_update_bg_jobs${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config $HOME/.config/ohmyposh/rosepine.omp.toml)"
fi

# ========================================
# COMPLETION SYSTEM
# ========================================

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Custom completions
if [ -d "$HOME/.local/share/bash-completion/completions" ]; then
    for completion in "$HOME/.local/share/bash-completion/completions"/*; do
        [ -r "$completion" ] && . "$completion"
    done
fi

# ========================================
# ALIASES
# ========================================

alias ls='eza --color=always --git --icons=always --group-directories-first'
alias ll='eza -la --color=always --git --icons=always --group-directories-first'
alias la='eza -la --color=always --git --icons=always --group-directories-first'
alias lt='eza --tree --color=always --icons=always --group-directories-first'
alias nano='micro'
alias c='clear'
alias upgrade='topgrade'
alias ofetch='onefetch'
alias lzg='lazygit'
alias zj='zellij'
alias bench='hyperfine'
alias sr='sd'
alias denv='direnv edit .'

alias grep='batgrep'
alias find='fd'
alias cat='bat --paging=never'
alias less='bat'
alias rm='rip'
alias del='rip'
alias cp='fcp'
alias tree='tre'
alias man='batman'
alias top='btop'
alias df='duf'
alias du='dust'

alias s="kitten ssh"
alias icat="kitten icat"
alias clipboard="kitten clipboard"

alias fzf='fzf --preview="bat --color=always --style=numbers --line-range=:500 {}" --height 60% --border --layout=reverse'

alias gst='git status --short --branch'
alias glog='git log --oneline --graph --decorate --all'
alias gdiff='git diff --color-words'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

alias h='history'
alias j='jobs -l'
alias ports='netstat -tulanp'

alias mv='mv -i'

# Help formatting
alias help='help 2>&1 | bat --language=help --style=plain 2>/dev/null || help'

# ========================================
# FUNCTIONS
# ========================================

_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

mkcd() {
    mkdir -p "$1" && cd "$1"
}

which() {
    (alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot "$@"
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
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
}

# ========================================
# EXTERNAL INTEGRATIONS
# ========================================

if command -v fzf >/dev/null 2>&1; then
    if [ -f ~/.fzf.bash ]; then
        source ~/.fzf.bash
    elif [ -f /usr/share/fzf/key-bindings.bash ]; then
        source /usr/share/fzf/key-bindings.bash
        source /usr/share/fzf/completion.bash
    fi
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

if command -v yazi >/dev/null 2>&1; then
    function y() {
        local tmp
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

if command -v thefuck >/dev/null 2>&1 && thefuck --version >/dev/null 2>&1; then
    eval $(thefuck --alias)
    eval $(thefuck --alias fk)
fi

if [ -f "$HOME/.config/fzf-git/fzf-git.sh" ]; then
    source "$HOME/.config/fzf-git/fzf-git.sh"
fi

# ========================================
# KEY BINDINGS
# ========================================


# Ctrl+R for history search
if command -v fzf >/dev/null 2>&1; then
    bind '"\C-r": "\C-a fzf-history-widget\C-j"'
fi

# Better completion
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set show-all-if-ambiguous on'
bind 'set mark-symlinked-directories on'


# ========================================
# PERFORMANCE OPTIMIZATION
# ========================================

# Lazy load nvm
if [ -d "$HOME/.nvm" ]; then
    nvm() {
        unset -f nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
    }
fi

# Lazy load rbenv
if [ -d "$HOME/.rbenv" ]; then
    rbenv() {
        unset -f rbenv
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
        rbenv "$@"
    }
fi

# ========================================
# LOCAL CUSTOMIZATIONS
# ========================================

[ -f "$HOME/.config/bash/.bashrc.local" ] && source "$HOME/.config/bash.bashrc.local"
