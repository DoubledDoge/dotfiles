#!/usr/bin/env bash

# ========================================
# BASH Configuration
# ========================================

case $- in
  *i*) ;;
    *) return;;
esac

__DOTFILES_SHELL_NAME="bash"

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
# SHARED ENVIRONMENT, ALIASES & FUNCTIONS
# ========================================

[ -f "$HOME/.config/shell/env.sh" ] && source "$HOME/.config/shell/env.sh"
[ -f "$HOME/.config/shell/aliases.sh" ] && source "$HOME/.config/shell/aliases.sh"
[ -f "$HOME/.config/shell/functions.sh" ] && source "$HOME/.config/shell/functions.sh"

# ========================================
# COMPLETION SYSTEM
# ========================================

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -d "$HOME/.local/share/bash-completion/completions" ]; then
    for completion in "$HOME/.local/share/bash-completion/completions"/*; do
        [ -r "$completion" ] && . "$completion"
    done
fi

# ========================================
# BASH-ONLY FZF COMPLETION HELPERS
# ========================================

_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

# ========================================
# EXTERNAL INTEGRATIONS
# ========================================

if command -v fzf >/dev/null 2>&1; then
    if [ -f ~/.fzf.bash ]; then
        source ~/.fzf.bash
    elif fzf --bash >/dev/null 2>&1; then
        source <(fzf --bash)
    elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
    fi
fi

[ -f "$HOME/.config/shell/integrations.sh" ] && source "$HOME/.config/shell/integrations.sh"


PROMPT_COMMAND="_update_bg_jobs${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ========================================
# KEY BINDINGS
# ========================================

if command -v fzf >/dev/null 2>&1; then
    bind '"\C-r": "\C-a fzf-history-widget\C-j"'
fi

bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set show-all-if-ambiguous on'
bind 'set mark-symlinked-directories on'

# ========================================
# LOCAL CUSTOMIZATIONS
# ========================================

[ -f "$HOME/.config/bash/.bashrc.local" ] && source "$HOME/.config/bash/.bashrc.local"
