#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
QUERY="$ROOT/skills/shopify-app-dev/scripts/query.sh"
INDEX="$SCRIPT_DIR/fixtures/sample_index.json"

assert_eq() {
  if [ "$1" != "$2" ]; then echo "FAIL: $3 (expected '$2' got '$1')"; exit 1; fi
}

# 1. "authentication oauth tokens" should rank Authentication chunk first
top=$(INDEX_FILE="$INDEX" bash "$QUERY" "authentication oauth tokens" 1)
assert_eq "$top" "apps__admin-api__authentication" "auth query top result"

# 2. "graphql admin mutation" should rank Admin API first
top=$(INDEX_FILE="$INDEX" bash "$QUERY" "graphql admin mutation" 1)
assert_eq "$top" "apps__admin-api" "admin api query top result"

# 3. "shopify.app.toml scopes webhooks" should rank Configuration first
top=$(INDEX_FILE="$INDEX" bash "$QUERY" "toml scopes webhooks configuration" 1)
assert_eq "$top" "apps__configuration-and-shopify-app-toml" "config query top result"

# 4. Top-3 must include the matching slug for liquid query
top3=$(INDEX_FILE="$INDEX" bash "$QUERY" "liquid sections schema" 3 | tr '\n' ' ')
case "$top3" in
  *themes*) ;;
  *) echo "FAIL: themes should be in top-3 for liquid query (got: $top3)"; exit 1 ;;
esac

echo "PASS"
