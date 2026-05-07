#!/usr/bin/env bash
# Score the chunk index against a query string and emit top-N slugs.
# Usage: query.sh "<query string>" [N=3]
# Env: INDEX_FILE (default: skills/shopify-app-dev/cache/index.json)
set -euo pipefail

q="${1:-}"
n="${2:-3}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEX_FILE="${INDEX_FILE:-$SKILL_DIR/cache/index.json}"

if [ -z "$q" ]; then
  echo "usage: query.sh <query> [N]" >&2
  exit 2
fi
if [ ! -f "$INDEX_FILE" ]; then
  echo "error: index file not found at $INDEX_FILE" >&2
  exit 1
fi

# Lowercase, drop punctuation, split into unique tokens >=3 chars
tokens=$(printf '%s' "$q" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -c 'a-z0-9' '\n' \
  | awk 'length($0) >= 3' \
  | sort -u)

if [ -z "$tokens" ]; then
  echo "error: no usable tokens in query" >&2
  exit 1
fi

# Build jq array argument from tokens
tok_json=$(printf '%s\n' $tokens | jq -R . | jq -s .)

jq -r --argjson toks "$tok_json" --argjson n "$n" '
  def score(entry):
    ([entry.path[]? | ascii_downcase] | join(" ")) as $p
    | (entry.keywords // []) as $kw
    | reduce $toks[] as $t (
        0;
        . + (if ($p | contains($t)) then 3 else 0 end)
          + (if ($kw | map(ascii_downcase) | index($t)) then 1 else 0 end)
      );
  map({slug: .slug, score: score(.), path_len: (.path | length)})
  | map(select(.score > 0))
  | sort_by(-.score, .path_len)
  | .[0:$n]
  | .[] | .slug
' "$INDEX_FILE"
