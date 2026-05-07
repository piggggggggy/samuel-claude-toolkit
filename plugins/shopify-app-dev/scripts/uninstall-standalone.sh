#!/usr/bin/env bash
# Remove a standalone install of shopify-app-dev from ~/.claude/.
set -euo pipefail

DEST_SKILL="$HOME/.claude/skills/shopify-app-dev"
DEST_CMDS="$HOME/.claude/commands"

rm -rf "$DEST_SKILL"
rm -f "$DEST_CMDS/shopify-review.md" "$DEST_CMDS/shopify-init.md"

echo "uninstalled standalone shopify-app-dev"
echo "  removed: $DEST_SKILL"
echo "  removed: $DEST_CMDS/shopify-review.md"
echo "  removed: $DEST_CMDS/shopify-init.md"
