#!/usr/bin/env zsh

__DOTFILES_SHELL_NAME="zsh"

# ========================================
# ZINIT INITIALIZATION
# ========================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ========================================
# ZSH PLUGINS
# ========================================

zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

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

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
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
# SHARED ENVIRONMENT, ALIASES & FUNCTIONS
# ========================================

[[ -f "$HOME/.config/shell/env.sh" ]] && source "$HOME/.config/shell/env.sh"
[[ -f "$HOME/.config/shell/aliases.sh" ]] && source "$HOME/.config/shell/aliases.sh"
[[ -f "$HOME/.config/shell/functions.sh" ]] && source "$HOME/.config/shell/functions.sh"

# ========================================
# ZSH-ONLY ALIASES
# ========================================

alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# ========================================
# ZSH-ONLY FZF COMPLETION HELPERS
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

# ========================================
# EXTERNAL INTEGRATIONS
# ========================================

if command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    else
        for _fzf_legacy in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/doc/fzf/examples/completion.zsh; do
            [[ -f "$_fzf_legacy" ]] && source "$_fzf_legacy"
        done
        unset _fzf_legacy
    fi
fi

[[ -f "$HOME/.config/shell/integrations.sh" ]] && source "$HOME/.config/shell/integrations.sh"

# ========================================
# PROMPT INITIALIZATION
# ========================================

autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_bg_jobs

# ========================================
# LOCAL CUSTOMIZATIONS
# ========================================

[[ -f "$HOME/.config/zsh/.zshrc.local" ]] && source "$HOME/.config/zsh/.zshrc.local"

# ========================================
# PERFORMANCE OPTIMIZATION
# ========================================

ZSHRC_PATH="${ZDOTDIR:-$HOME}/.zshrc"
if [[ "$ZSHRC_PATH" -nt "$ZSHRC_PATH.zwc" ]] || [[ ! -s "$ZSHRC_PATH.zwc" ]]; then
    zcompile "$ZSHRC_PATH"
fi
