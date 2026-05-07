---
name: shopify-init
description: Guided walkthrough for bootstrapping a new Shopify app — CLI install, init, scope design, dev, deploy, App Store listing.
argument-hint: "[app-name]"
---

# /shopify-init

Walk the user through bootstrapping a new Shopify app. At every step, retrieve current docs from the `shopify-app-dev` skill cache and cite them.

## Inputs

Optional first argument: the app name. If absent, ask the user once.

## Procedure

For each of the six steps below:
1. Run `bash <skill-dir>/scripts/query.sh "<step keywords>" 3`.
2. `Read` the top chunks.
3. Present the step's instructions, citing `[heading path](url)`.
4. Ask the user to confirm completion before moving to the next step.

### Step 1 — CLI install / version check
Keywords: `cli install version shopify command line`.
Verify `shopify version`. If missing, point to the install instructions you retrieve.

### Step 2 — `shopify app init`
Keywords: `app init template remix node extension scaffold`.
Cover template choices (Remix vs Node), language (TS/JS), and what gets generated. Help the user pick.

### Step 3 — Scope design
Keywords: `access_scopes scopes admin api permissions read write products orders`.
Ask the user what the app needs to do (read products, write orders, etc.) and map each capability to a scope from the retrieved docs. Show the resulting `[access_scopes]` block in `shopify.app.toml`.

### Step 4 — Local dev (`shopify app dev`)
Keywords: `app dev local development tunnel partners dashboard`.
Explain tunnel setup, dev store linkage, and how to install the app on the dev store.

### Step 5 — Deploy (`shopify app deploy`)
Keywords: `app deploy versioning extensions release`.
Cover what `deploy` ships (extensions, configuration), versioning, and how to roll back.

### Step 6 — App Store listing prerequisites
Keywords: `app store listing submission review billing branding privacy`.
Cover billing setup, branding assets, privacy/GDPR, and the submission checklist.

## Rules

- One step at a time. Do not dump all six at once.
- Every recommendation must cite a retrieved chunk.
- If the user is doing something not covered by current docs, say so and offer to `WebFetch` deeper pages.
