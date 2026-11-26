log()     { printf '==> %s\n' "$*"; }
install() { printf '==> Installing %s\n' "$1"; }
skip()    { printf '==> %s already installed, skipping\n' "$1"; }
warn()    { printf 'WARNING: %s\n' "$*" >&2; }
