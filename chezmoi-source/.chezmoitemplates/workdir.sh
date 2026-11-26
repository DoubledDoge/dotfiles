WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
