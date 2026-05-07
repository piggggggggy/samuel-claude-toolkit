#!/usr/bin/env bash
# Fetch shopify.dev/llms.txt into the cache and rebuild the chunk index.
# Honors If-None-Match / If-Modified-Since when prior meta.json exists.
# TTL: 7 days. Pass --force to bypass TTL.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CACHE_DIR="${CACHE_DIR:-$SKILL_DIR/cache}"
SOURCE_URL="https://shopify.dev/llms.txt"
TTL_SECONDS=$((7 * 24 * 3600))

mkdir -p "$CACHE_DIR/chunks"
META="$CACHE_DIR/meta.json"
LLMS="$CACHE_DIR/llms.txt"

force=0
[ "${1:-}" = "--force" ] && force=1

# TTL check
if [ "$force" -eq 0 ] && [ -f "$META" ] && [ -f "$LLMS" ]; then
  built_at=$(jq -r '.built_at // 0' "$META")
  now=$(date +%s)
  age=$(( now - built_at ))
  if [ "$age" -lt "$TTL_SECONDS" ]; then
    echo "cache fresh (age ${age}s < ttl ${TTL_SECONDS}s); skipping rebuild"
    exit 0
  fi
fi

# Conditional fetch
etag_hdr=()
if [ -f "$META" ]; then
  prev_etag=$(jq -r '.etag // ""' "$META")
  prev_lm=$(jq -r '.last_modified // ""' "$META")
  [ -n "$prev_etag" ] && etag_hdr+=( -H "If-None-Match: $prev_etag" )
  [ -n "$prev_lm" ]   && etag_hdr+=( -H "If-Modified-Since: $prev_lm" )
fi

tmp_body="$(mktemp)"
tmp_hdr="$(mktemp)"
trap 'rm -f "$tmp_body" "$tmp_hdr"' EXIT

http_code=$(curl -sS -o "$tmp_body" -D "$tmp_hdr" -w "%{http_code}" \
  "${etag_hdr[@]}" "$SOURCE_URL" || echo "000")

if [ "$http_code" = "304" ] && [ -f "$LLMS" ]; then
  echo "source unchanged (304); refreshing built_at only"
  jq --argjson now "$(date +%s)" '.built_at = $now' "$META" > "$META.tmp"
  mv "$META.tmp" "$META"
  exit 0
fi

if [ "$http_code" != "200" ]; then
  if [ -f "$LLMS" ]; then
    echo "warn: fetch failed (HTTP $http_code); using existing cache" >&2
    exit 0
  fi
  echo "error: failed to fetch $SOURCE_URL (HTTP $http_code) and no prior cache" >&2
  exit 1
fi

mv "$tmp_body" "$LLMS"

etag=$(awk 'BEGIN{IGNORECASE=1} /^etag:/{sub(/^[^:]*: */,""); sub(/\r$/,""); print; exit}' "$tmp_hdr")
lm=$(awk 'BEGIN{IGNORECASE=1} /^last-modified:/{sub(/^[^:]*: */,""); sub(/\r$/,""); print; exit}' "$tmp_hdr")
size=$(wc -c < "$LLMS" | tr -d ' ')

# Parse into a staging dir so a python3 failure cannot destroy the live cache
staging="$CACHE_DIR/.staging"
rm -rf "$staging"
mkdir -p "$staging/chunks"

if ! CACHE_DIR="$staging" python3 "$SCRIPT_DIR/parse_llms.py" "$LLMS"; then
  rm -rf "$staging"
  echo "error: parse_llms.py failed; live cache untouched" >&2
  exit 1
fi

# Atomic-ish swap: replace chunks dir and index.json from staging
rm -rf "$CACHE_DIR/chunks"
mv "$staging/chunks" "$CACHE_DIR/chunks"
mv "$staging/index.json" "$CACHE_DIR/index.json"
rm -rf "$staging"

jq -n \
  --argjson now "$(date +%s)" \
  --arg etag "$etag" \
  --arg lm "$lm" \
  --argjson size "$size" \
  '{built_at: $now, etag: $etag, last_modified: $lm, source_size: $size, version: 1}' \
  > "$META"

echo "rebuilt index: $(jq 'length' "$CACHE_DIR/index.json") entries, ${size} bytes source"
