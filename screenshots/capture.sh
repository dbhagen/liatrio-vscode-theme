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

EXTENSIONS_DIR=$(mktemp -d)
trap 'rm -rf "$EXTENSIONS_DIR"' EXIT

# Install only our theme extension — empty extensions dir means no built-in
# extensions like TypeScript that would show "Analyzing..." in the status bar
code --extensions-dir "$EXTENSIONS_DIR" --install-extension "$VSIX" --force

capture_theme() {
  local theme_id="$1"
  local output_file="$2"
  local display_num="$3"

  echo "Capturing: $theme_id -> $output_file"

  # Use a fresh user data dir per theme to avoid lock conflicts
  local user_data
  user_data=$(mktemp -d)

  local settings_dir="$user_data/User"
  mkdir -p "$settings_dir"
  cat > "$settings_dir/settings.json" <<SETTINGS
{
  "workbench.colorTheme": "$theme_id",
  "window.zoomLevel": 0,
  "editor.fontSize": 14,
  "editor.minimap.enabled": false,
  "editor.scrollbar.vertical": "hidden",
  "editor.scrollbar.horizontal": "hidden",
  "window.titleBarStyle": "custom",
  "workbench.startupEditor": "none",
  "workbench.tips.enabled": false,
  "workbench.panel.defaultLocation": "bottom",
  "workbench.activityBar.visible": false,
  "workbench.sideBar.visible": false,
  "workbench.secondarySideBar.visible": false,
  "workbench.auxiliaryBar.visible": false,
  "window.restoreWindows": "none",
  "telemetry.telemetryLevel": "off",
  "security.workspace.trust.enabled": false,
  "chat.commandCenter.enabled": false,
  "github.copilot.enable": { "*": false },
  "extensions.autoUpdate": false,
  "update.mode": "none",
  "typescript.disableAutomaticTypeAcquisition": true
}
SETTINGS

  cat > "$user_data/argv.json" <<ARGV
{ "disable-hardware-acceleration": true }
ARGV

  export DISPLAY=":${display_num}"

  Xvfb ":${display_num}" -screen 0 1920x1080x24 &
  local xvfb_pid=$!
  sleep 2

  code \
    --user-data-dir "$user_data" \
    --extensions-dir "$EXTENSIONS_DIR" \
    --disable-extensions-except "$VSIX" \
    --disable-gpu \
    --maximize \
    --new-window \
    "$SAMPLE_FILE" &
  local code_pid=$!

  # Give VS Code time to fully render and apply theme
  sleep 12

  # Capture full screen (VS Code is maximized to fill it)
  import -window root "$output_file"

  kill "$code_pid" 2>/dev/null || true
  kill "$xvfb_pid" 2>/dev/null || true
  wait "$code_pid" 2>/dev/null || true
  wait "$xvfb_pid" 2>/dev/null || true

  rm -rf "$user_data"
}

capture_theme "Liatrio Dark" "$SCRIPT_DIR/dark.png" 99
capture_theme "Liatrio Light" "$SCRIPT_DIR/light.png" 98

echo "Screenshots saved to $SCRIPT_DIR/"
