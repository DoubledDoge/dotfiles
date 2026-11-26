as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif [ -n "${PRIV_CMD:-}" ]; then
        "$PRIV_CMD" "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    elif command -v doas >/dev/null 2>&1; then
        doas "$@"
    else
        echo "error: root required to install packages, but neither sudo nor doas was found" >&2
        return 1
    fi
}
