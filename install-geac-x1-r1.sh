#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PLUGIN_NAME='geac-x1-r1-engineering-controls'
PLUGIN_SOURCE="$ROOT/plugin"

if ! command -v agy >/dev/null 2>&1; then
  printf '%s\n' 'AGY CLI was not found. Install Antigravity CLI 1.2.7 or later and put agy on PATH.' >&2
  exit 1
fi
for INSTALL_PATH in "$HOME/.gemini/config/plugins/$PLUGIN_NAME" "$HOME/.gemini/antigravity-cli/plugins/$PLUGIN_NAME"; do
  if [ -e "$INSTALL_PATH" ]; then
    printf 'Plugin already exists at %s. Uninstall it first to avoid overwriting a local version.\n' "$INSTALL_PATH" >&2
    exit 1
  fi
done
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$ROOT" && sha256sum -c PACKAGE-SHA256.txt >/dev/null)
elif command -v shasum >/dev/null 2>&1; then
  (cd "$ROOT" && shasum -a 256 -c PACKAGE-SHA256.txt >/dev/null)
else
  printf '%s\n' 'Need sha256sum or shasum to verify this package.' >&2
  exit 1
fi

TMP_BASE=$(CDPATH= cd -- "${TMPDIR:-/tmp}" && pwd)
STAGE=$(mktemp -d "$TMP_BASE/geac-x1-r1-stage.XXXXXX")
cleanup() {
  case "$STAGE" in
    "$TMP_BASE"/geac-x1-r1-stage.*) rm -rf -- "$STAGE" ;;
    *) printf 'Refusing to remove staging path outside temp prefix: %s\n' "$STAGE" >&2; exit 1 ;;
  esac
}
trap cleanup EXIT HUP INT TERM
cp -R "$PLUGIN_SOURCE/." "$STAGE/"
cp "$ROOT/install/hooks.unix.json" "$STAGE/hooks.json"
agy plugin validate "$STAGE"
agy plugin install "$STAGE"
"$ROOT/verify-geac-x1-r1.sh"
printf '%s\n' 'Installed GEAC X1-R1 package preview.'
