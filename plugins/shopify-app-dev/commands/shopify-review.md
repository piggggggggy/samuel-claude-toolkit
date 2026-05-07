---
name: shopify-review
description: Verify Shopify app code against current docs — flags deprecated APIs, missing scopes, stale api_version, and best-practice violations.
argument-hint: "[file paths...]"
---

# /shopify-review

You are reviewing Shopify-related code against the current `shopify.dev` documentation.

## Inputs

Arguments may be file paths. If no arguments given, default to the staged-or-modified files reported by `git diff --name-only HEAD` (filtered to source code).

## Procedure

1. **Ensure the docs cache is fresh**
   ```bash
   bash <skill-dir>/scripts/build_index.sh
   ```
   Locate the skill dir from the active plugin install path. If the skill is not installed, tell the user to install `shopify-app-dev` first and stop.

2. **Read each target file** with the `Read` tool.

3. **Extract Shopify-relevant patterns** from each file:
   - imports from `@shopify/*` packages
   - `shopify.app.toml` blocks: `scopes`, `[webhooks]`, `api_version`, extension declarations
   - GraphQL operations targeting Admin or Storefront APIs
   - calls to `useAppBridge`, `authenticate.admin`, `authenticate.public.appProxy`, `shopify.api.*`, `Session`
   - direct `fetch(...)` calls to `*.myshopify.com` (anti-pattern: use App Bridge / authenticated client)

4. **For each pattern**, run the query pipeline:
   ```bash
   bash <skill-dir>/scripts/query.sh "<pattern keywords>" 3
   ```
   `Read` the top chunk(s) for each.

5. **Verify** against retrieved context. Flag:
   - **deprecated** — API or field marked deprecated in the docs
   - **stale-api-version** — `api_version` older than the latest stable shown in the docs
   - **missing-scope** — used API requires a scope not listed in `[access_scopes]`
   - **best-practice** — recommended pattern is not followed (e.g., direct fetch instead of App Bridge)

6. **Output** one section per file:
   ```
   ### path/to/file.ext
   - [severity] message — citation: [heading path](url)
     suggestion: <one-line fix>
   ```
   If a file has no issues, say `no issues found`.

7. **End with a summary**: total counts by severity. If you augmented with `WebFetch`, list the URLs you fetched.

## Rules

- Do not invent rules: only flag issues you can cite to a retrieved chunk or fetched URL.
- Do not modify files. This is a review, not an edit.
- If the cache fails to build and there is no prior cache, abort and tell the user.
