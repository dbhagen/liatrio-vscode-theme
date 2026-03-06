#!/usr/bin/env bash
set -euo pipefail

# Capture screenshots of VS Code with each theme variant.
# Designed for Linux CI with xvfb and imagemagick.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SAMPLE_FILE="$SCRIPT_DIR/sample.ts"

VSIX=$(find "$REPO_DIR" -maxdepth 1 -name '*.vsix' | head -1)
if [[ -z "$VSIX" ]]; then
  echo "No .vsix file found. Run 'npx @vscode/vsce package' first."
  exit 1
fi

USER_DATA=$(mktemp -d)
EXTENSIONS_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$USER_DATA" "$EXTENSIONS_DIR"
}
trap cleanup EXIT

code --extensions-dir "$EXTENSIONS_DIR" --install-extension "$VSIX" --force

capture_theme() {
  local theme_id="$1"
  local output_file="$2"
  local display_num="$3"

  echo "Capturing: $theme_id -> $output_file"

  local settings_dir="$USER_DATA/User"
  mkdir -p "$settings_dir"
  cat > "$settings_dir/settings.json" <<SETTINGS
{
  "workbench.colorTheme": "$theme_id",
  "window.zoomLevel": 0,
  "editor.fontSize": 14,
  "editor.minimap.enabled": false,
  "window.titleBarStyle": "custom",
  "workbench.startupEditor": "none",
  "telemetry.telemetryLevel": "off",
  "window.restoreWindows": "none"
}
SETTINGS

  cat > "$USER_DATA/argv.json" <<ARGV
{ "disable-hardware-acceleration": true }
ARGV

  export DISPLAY=":${display_num}"

  Xvfb ":${display_num}" -screen 0 1920x1080x24 &
  local xvfb_pid=$!
  sleep 2

  code \
    --user-data-dir "$USER_DATA" \
    --extensions-dir "$EXTENSIONS_DIR" \
    --disable-gpu \
    --new-window \
    "$SAMPLE_FILE" &
  local code_pid=$!

  sleep 8

  import -window root "$output_file"

  kill "$code_pid" 2>/dev/null || true
  kill "$xvfb_pid" 2>/dev/null || true
  wait "$code_pid" 2>/dev/null || true
  wait "$xvfb_pid" 2>/dev/null || true
}

capture_theme "Liatrio Dark" "$SCRIPT_DIR/dark.png" 99
capture_theme "Liatrio Light" "$SCRIPT_DIR/light.png" 98

echo "Screenshots saved to $SCRIPT_DIR/"
