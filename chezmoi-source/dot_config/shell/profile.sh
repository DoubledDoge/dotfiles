[ -r "$HOME/.config/shell/login.sh" ] && . "$HOME/.config/shell/login.sh"

if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

export PATH

if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
fi

if [ -n "${BASH_VERSION-}" ]; then
    case $- in
        *i*)
            BASHRC_PATH="$HOME/.config/bash/bashrc"
            [ -r "$BASHRC_PATH" ] && . "$BASHRC_PATH"
            ;;
    esac
fi

# shellcheck shell=sh