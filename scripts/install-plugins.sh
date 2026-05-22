#!/usr/bin/env bash
# install-plugins.sh
# Registers the anthropics/skills marketplace and enables the example-skills
# plugin in ~/.claude/settings.json.
#
# Requirements: jq

set -euo pipefail

for cmd in jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not found." >&2
    exit 1
  fi
done

SETTINGS="$HOME/.claude/settings.json"

if [[ ! -f "$SETTINGS" ]]; then
  echo "{}" > "$SETTINGS"
fi

cp "$SETTINGS" "${SETTINGS}.bak"
echo "Backed up settings.json to ${SETTINGS}.bak"

MARKETPLACE_PATCH=$(cat <<'EOF'
{
  "anthropic-agent-skills": {
    "source": {
      "source": "github",
      "repo": "anthropics/skills"
    }
  }
}
EOF
)

PLUGINS_PATCH=$(cat <<'EOF'
{
  "example-skills@anthropic-agent-skills": true
}
EOF
)

jq --argjson mkt "$MARKETPLACE_PATCH" --argjson plugins "$PLUGINS_PATCH" '
  .extraKnownMarketplaces = ((.extraKnownMarketplaces // {}) * $mkt) |
  .enabledPlugins = ((.enabledPlugins // {}) * $plugins)
' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"

echo "Done. anthropics/skills marketplace and example-skills plugin registered in $SETTINGS."
echo "Restart Claude Code for changes to take effect."
