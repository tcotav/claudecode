#!/usr/bin/env bash
# install-ccnotify.sh
# Installs CCNotify (https://github.com/dazuiba/CCNotify) and registers
# its hooks in ~/.claude/settings.json.
#
# Requirements: macOS, Homebrew, jq

set -euo pipefail

# --- guards -------------------------------------------------------------------

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: CCNotify is macOS-only." >&2
  exit 1
fi

for cmd in brew jq python3 git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not found." >&2
    exit 1
  fi
done

# --- install ------------------------------------------------------------------

INSTALL_DIR="$HOME/.claude/ccnotify"

if [[ -d "$INSTALL_DIR" ]]; then
  echo "CCNotify already cloned at $INSTALL_DIR — pulling latest."
  git -C "$INSTALL_DIR" pull --ff-only
else
  echo "Cloning CCNotify to $INSTALL_DIR..."
  git clone https://github.com/dazuiba/CCNotify.git "$INSTALL_DIR"
fi

echo "Installing terminal-notifier..."
brew install terminal-notifier

# --- patch settings.json ------------------------------------------------------

SETTINGS="$HOME/.claude/settings.json"

# Create settings.json if it doesn't exist
if [[ ! -f "$SETTINGS" ]]; then
  echo "{}" > "$SETTINGS"
fi

# Back up before modifying
cp "$SETTINGS" "${SETTINGS}.bak"
echo "Backed up settings.json to ${SETTINGS}.bak"

HOOKS_PATCH=$(cat <<'EOF'
{
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/ccnotify/ccnotify.py UserPromptSubmit"
        }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/ccnotify/ccnotify.py Stop"
        }
      ]
    }
  ],
  "Notification": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/ccnotify/ccnotify.py Notification"
        }
      ]
    }
  ]
}
EOF
)

# Merge hooks into existing settings, preserving any other keys
jq --argjson hooks "$HOOKS_PATCH" '
  .hooks = (.hooks // {}) * $hooks
' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

echo "Done. CCNotify hooks registered in $SETTINGS."
echo "Restart Claude Code for changes to take effect."
