#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cp "$SCRIPT_DIR/fixtures/sample_llms.txt" "$WORK/llms.txt"

# Run parser against the fixture, writing into $WORK/cache
CACHE_DIR="$WORK/cache" \
  python3 "$ROOT/skills/shopify-app-dev/scripts/parse_llms.py" "$WORK/llms.txt"

assert() {
  if ! eval "$1"; then
    echo "FAIL: $2"
    exit 1
  fi
}

assert "[ -f '$WORK/cache/index.json' ]" "index.json should exist"
assert "[ -d '$WORK/cache/chunks' ]" "chunks dir should exist"

count=$(jq 'length' "$WORK/cache/index.json")
assert "[ '$count' -ge 5 ]" "expected >=5 index entries (got $count)"

# Specific chunk for "Authentication" under Apps > Admin API
slug=$(jq -r '.[] | select(.path == ["Shopify Developer Platform","Apps","Admin API","Authentication"]) | .slug' "$WORK/cache/index.json")
assert "[ -n '$slug' ]" "Authentication chunk slug should be present"
assert "[ -f '$WORK/cache/chunks/$slug.md' ]" "Authentication chunk file should exist"

# URL extracted
url=$(jq -r ".[] | select(.slug == \"$slug\") | .url" "$WORK/cache/index.json")
assert "[ '$url' = 'https://shopify.dev/docs/apps/build/authentication-authorization' ]" "url should match"

echo "PASS"
