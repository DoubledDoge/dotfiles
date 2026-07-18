#!/usr/bin/env bash
# ========================================
# SHARED EXTERNAL INTEGRATIONS
# ========================================

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init "$__DOTFILES_SHELL_NAME")"
    alias cd='z'
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook "$__DOTFILES_SHELL_NAME")"
fi

if command -v thefuck >/dev/null 2>&1 && thefuck --version >/dev/null 2>&1; then
    eval "$(thefuck --alias)"
    eval "$(thefuck --alias fk)"
fi

if [ -f "$HOME/.config/fzf-git/fzf-git.sh" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.config/fzf-git/fzf-git.sh"
fi

# ========================================
# PROMPT INITIALIZATION
# ========================================

_update_bg_jobs() {
    local jobs_count
    jobs_count="$(jobs -r | wc -l | tr -d ' ')"
    export BG_JOBS="$jobs_count"
}

if command -v oh-my-posh >/dev/null 2>&1 && [ -f "$HOME/.config/ohmyposh/rosepine.omp.toml" ]; then
    eval "$(oh-my-posh init "$__DOTFILES_SHELL_NAME" --config "$HOME/.config/ohmyposh/rosepine.omp.toml")"
fi