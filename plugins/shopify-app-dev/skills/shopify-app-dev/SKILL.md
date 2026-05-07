---
name: shopify-app-dev
description: Use when the user asks about building, designing, configuring, or launching a Shopify app — including Admin/Storefront API, App Bridge, Polaris, Shopify CLI, shopify.app.toml, scopes, webhooks, app/checkout/admin extensions, app deployment, or App Store listing. Activates on mentions of shopify.dev, "shopify app init/dev/deploy", or any Shopify app dev terminology.
---

# Shopify App Development Assistant

You retrieve authoritative context from `shopify.dev` docs through a pre-built `llms.txt` index, then answer with citations. Never speculate beyond the retrieved chunks.

## Required pipeline (every invocation)

Follow these 7 steps in order. Do not skip them.

### 1. Ensure the cache is fresh

Resolve the skill directory: it is the directory containing this `SKILL.md`. Call its scripts:

```bash
bash <skill-dir>/scripts/build_index.sh
```

This is a no-op when the cache exists and is <7 days old. Proceed once it succeeds.

If it fails with no prior cache, tell the user the cache could not be built (network issue) and stop.

### 2. Detect intent categories

From the user's question, pick zero or more categories from this fixed taxonomy:
`build`, `design`, `launch`, `api/admin`, `api/storefront`, `extensions/checkout`, `extensions/admin`, `cli`, `polaris`, `app-bridge`, `webhooks`, `auth`, `billing`, `app-store`.

### 3. Build a keyword string

Lowercase the user's question; remove generic English filler. Keep nouns, library names, file names (`shopify.app.toml`), and any explicit Shopify terms. Append the selected category names from step 2 (they double as keywords).

### 4. Score the index

```bash
bash <skill-dir>/scripts/query.sh "<keyword string>" 5
```

Output is up to 5 slug names, best first.

### 5. Read the top chunks

Use the `Read` tool on each chunk file:
`<skill-dir>/cache/chunks/<slug>.md`

Stop reading once you have ~3 chunks or roughly 8KB of context — whichever comes first.

### 6. Augment with `WebFetch` only if needed

Run AT MOST ONE `WebFetch` per user turn. If multiple triggers below fire, pick the highest-priority candidate (a chunk that explicitly says "see full docs" wins, otherwise the top-scored chunk's URL).

Trigger a `WebFetch` of the chunk's `url` (look it up in `cache/index.json` with `jq`) when ANY of these holds:
- the combined chunk content is shorter than 500 characters,
- the user explicitly asked for "latest" or a version-specific detail,
- `query.sh` returned fewer than 2 slugs,
- a chunk references "see full docs" or similar without including the relevant content.

Last-resort: if no slugs scored above 0 (empty `query.sh` output), run a single `WebSearch` for `site:shopify.dev <user query>` and `WebFetch` the top result.

### 7. Answer with citations

- Cite each non-trivial claim with `[heading path](url)` (use the path/url fields from `index.json`).
- If retrieved context does not cover the question, say so explicitly and offer to fetch deeper docs.
- Do not invent API names, scopes, or field names. Only mention identifiers that appear in the retrieved chunks.

## How to look up a chunk's URL

```bash
jq -r --arg s "<slug>" '.[] | select(.slug == $s) | .url' <skill-dir>/cache/index.json
```

If the result is `null`, skip `WebFetch` for that slug and rely on the chunk content only. If all candidate slugs return `null`, run a `WebSearch` for `site:shopify.dev <user query>` as the fallback.

## When the user asks a meta question

If the user asks how this skill works, what's cached, or wants to force a refresh, run:

```bash
bash <skill-dir>/scripts/build_index.sh --force
```

Then summarize `cache/meta.json` (built_at, source_size, entry count from `jq 'length' cache/index.json`).
