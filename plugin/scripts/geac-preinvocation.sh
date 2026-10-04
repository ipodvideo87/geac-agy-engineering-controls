#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PAYLOAD="$SCRIPT_DIR/geac-auto-state-output.json"

if [ ! -f "$PAYLOAD" ]; then
  printf 'GEAC all-skills payload is missing: %s\n' "$PAYLOAD" >&2
  exit 1
fi

# The build step validates and emits the JSON containing all eight full skills.
# Keep this hook dependency-free on user machines.
cat "$PAYLOAD"
