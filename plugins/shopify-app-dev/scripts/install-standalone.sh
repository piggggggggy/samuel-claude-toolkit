#!/usr/bin/env bash
# Install shopify-app-dev as a standalone setup under ~/.claude/, bypassing the
# plugin manifest. Replaces the <skill-dir> placeholder in SKILL.md and command
# files with $HOME/.claude/skills/shopify-app-dev so bash invocations resolve
# correctly when run by the agent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST_SKILL="$HOME/.claude/skills/shopify-app-dev"
DEST_CMDS="$HOME/.claude/commands"
TARGET='$HOME/.claude/skills/shopify-app-dev'

mkdir -p "$DEST_SKILL" "$DEST_CMDS"

# Copy skill (excluding runtime cache)
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude 'cache' "$ROOT/skills/shopify-app-dev/" "$DEST_SKILL/"
else
  rm -rf "$DEST_SKILL"
  mkdir -p "$DEST_SKILL"
  (cd "$ROOT/skills/shopify-app-dev" && find . -path ./cache -prune -o -type f -print | while read -r f; do
    mkdir -p "$DEST_SKILL/$(dirname "$f")"
    cp "$f" "$DEST_SKILL/$f"
  done)
fi

cp "$ROOT/commands/shopify-review.md" "$DEST_CMDS/"
cp "$ROOT/commands/shopify-init.md"   "$DEST_CMDS/"

# Cross-platform in-place sed: GNU uses `-i`, BSD/macOS uses `-i ''`
sed_inplace=(-i '')
if sed --version >/dev/null 2>&1; then sed_inplace=(-i); fi

for f in "$DEST_SKILL/SKILL.md" "$DEST_CMDS/shopify-review.md" "$DEST_CMDS/shopify-init.md"; do
  sed "${sed_inplace[@]}" "s|<skill-dir>|$TARGET|g" "$f"
done

# Re-mark scripts executable (cp preserves mode but be defensive)
chmod +x "$DEST_SKILL/scripts/"*.sh "$DEST_SKILL/scripts/"*.py 2>/dev/null || true

echo "installed:"
echo "  skill    -> $DEST_SKILL"
echo "  commands -> $DEST_CMDS/shopify-review.md, $DEST_CMDS/shopify-init.md"
echo
echo "verifying placeholder substitution (each count must be 0):"
for f in "$DEST_SKILL/SKILL.md" "$DEST_CMDS/shopify-review.md" "$DEST_CMDS/shopify-init.md"; do
  printf "  %s: %s remaining\n" "$f" "$(grep -c '<skill-dir>' "$f" || true)"
done
echo
echo "uninstall: bash $SCRIPT_DIR/uninstall-standalone.sh"
