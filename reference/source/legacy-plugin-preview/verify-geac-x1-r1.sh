#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PLUGIN_NAME='geac-x1-r1-engineering-controls'
INSTALL_PATH=""
for candidate in "$HOME/.gemini/config/plugins/$PLUGIN_NAME" "$HOME/.gemini/antigravity-cli/plugins/$PLUGIN_NAME"; do
  if [ -d "$candidate" ]; then INSTALL_PATH="$candidate"; break; fi
done
if ! command -v agy >/dev/null 2>&1; then
  printf '%s\n' 'AGY CLI was not found.' >&2
  exit 1
fi
[ -n "$INSTALL_PATH" ] || { printf '%s\n' 'Installed plugin directory was not found in the supported AGY locations.' >&2; exit 1; }
agy plugin list | grep -F "$PLUGIN_NAME" >/dev/null
agy plugin validate "$INSTALL_PATH"
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$INSTALL_PATH" && sha256sum -c "$ROOT/PLUGIN-SHA256.txt")
  expected=$(sha256sum "$ROOT/install/hooks.unix.json" | awk '{print $1}')
  actual=$(sha256sum "$INSTALL_PATH/hooks.json" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  (cd "$INSTALL_PATH" && shasum -a 256 -c "$ROOT/PLUGIN-SHA256.txt")
  expected=$(shasum -a 256 "$ROOT/install/hooks.unix.json" | awk '{print $1}')
  actual=$(shasum -a 256 "$INSTALL_PATH/hooks.json" | awk '{print $1}')
else
  printf '%s\n' 'Need sha256sum or shasum to verify this plugin.' >&2
  exit 1
fi
[ "$expected" = "$actual" ] || { printf '%s\n' 'Installed Unix hooks.json differs from the packaged template.' >&2; exit 1; }
printf 'PASS: %s is installed, AGY-valid, and matches the packaged Unix component hashes.\n' "$PLUGIN_NAME"
