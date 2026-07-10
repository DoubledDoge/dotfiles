#!/usr/bin/env zsh

# ========================================
# ZINIT INITIALIZATION
# ========================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# ========================================
# ZSH PLUGINS
# ========================================

# Core functionality plugins
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

# Advanced plugins
zinit wait lucid for \
        Aloxaf/fzf-tab

# ========================================
# OH-MY-ZSH SNIPPETS
# ========================================

zinit wait lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::archlinux \
    OMZP::command-not-found \
    OMZP::common-aliases \
    OMZP::dotnet \
    OMZP::cp \
    OMZP::gh \
    OMZP::git-commit \
    OMZP::github \
    OMZP::npm \
    OMZP::vscode

# ========================================
# HISTORY CONFIGURATION
# ========================================

HISTSIZE=10000
SAVEHIST=10000
mkdir -p "${HOME}/.config/zsh"
HISTFILE="${HOME}/.config/zsh/zsh_history"

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ========================================
# ZSH OPTIONS & BEHAVIOR
# ========================================

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CORRECT
setopt CDABLE_VARS
setopt EXTENDED_GLOB

# ========================================
# KEY BINDINGS
# ========================================

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^r' history-incremental-search-backward

# ========================================
# COMPLETION SYSTEM
# ========================================

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${HOME}/.zcompcache"

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always --level=2 $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always --level=2 $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# ========================================
# ENVIRONMENT VARIABLES
# ========================================

export EDITOR="$(command -v micro || echo nano)"
export VISUAL="$EDITOR"

# FZF Configuration
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

# FZF Options
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always --level=2 {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' --height 60% --border --layout=reverse"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {} | head -200' --height 60% --border --layout=reverse"
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --inline-info --color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,gutter:#191724 --color=spinner:#f6c177,info:#9ccfd8,separator:#403d52 --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

typeset -U path
path=(
    "$HOME/.cargo/bin"
    "$HOME/.spicetify"
    "$HOME/go/bin"
    "$HOME/.dotnet/bin"
    "$HOME/.local/bin"
    $path
)

# ========================================
# ALIASES
# ========================================

# Core utilities
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

# Enhanced tools
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

# Help formatting
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ========================================
# FUNCTIONS
# ========================================

_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always --level=2 {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \${}'" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}

tre() {
    command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null
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
    source <(fzf --zsh)
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
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

[[ -f "$HOME/.config/fzf-git/fzf-git.sh" ]] && source "$HOME/.config/fzf-git/fzf-git.sh"

# ========================================
# PROMPT INITIALIZATION
# ========================================

# Track background jobs so the prompt can display the count
autoload -Uz add-zsh-hook
_update_bg_jobs() { export BG_JOBS="$(jobs -r | wc -l | tr -d ' ')"; }
add-zsh-hook precmd _update_bg_jobs

if [[ -f "$HOME/.config/ohmyposh/rosepine.omp.toml" ]]; then
    eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/rosepine.omp.toml)"
fi

# ========================================
# PERFORMANCE OPTIMIZATION
# ========================================

ZSHRC_PATH="$HOME/.zshrc"
if [[ "$ZSHRC_PATH" -nt "$ZSHRC_PATH.zwc" ]] || [[ ! -s "$ZSHRC_PATH.zwc" ]]; then
    zcompile "$ZSHRC_PATH"
fi


# ========================================
# LOCAL CUSTOMIZATIONS
# ========================================

[ -f "$HOME/.config/zsh/.zshrc.local" ] && source "$HOME/.config/zsh/.zshrc.local"