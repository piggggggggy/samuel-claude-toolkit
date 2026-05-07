# shopify-app-dev

Claude Code plugin that assists Shopify app development by retrieving authoritative context from `shopify.dev` docs via a token-efficient, pre-chunked `llms.txt` index.

## Features

- Auto-triggers on Shopify app development questions
- `/shopify-review [paths...]` — verify code against Shopify best practices and current API
- `/shopify-init [app-name]` — guided new-app bootstrap walkthrough

## Requirements

- `bash`
- `curl`
- `jq`
- `python3` (3.8+) — only stdlib used

All four ship with macOS Command Line Tools and are pre-installed on most Linux distributions. Verify with:

```bash
bash --version && curl --version | head -1 && jq --version && python3 --version
```

## Install

### Option A — Marketplace install (persistent)

Inside Claude Code:

```
/plugin marketplace add /absolute/path/to/shopify-app-dev
/plugin install shopify-app-dev@shopify-app-dev
```

`/plugin marketplace add` reads `.claude-plugin/marketplace.json` from the given directory; `/plugin install` then copies the plugin into Claude Code's cache.

### Option B — Local development (no install)

Load the plugin for one Claude Code session without registering it:

```bash
claude --plugin-dir /absolute/path/to/shopify-app-dev
```

If a plugin with the same name is already installed, `--plugin-dir` takes precedence for that session — useful for iterating on changes.

### Option C — Standalone (no plugin system)

Run the bundled installer:

```bash
bash scripts/install-standalone.sh
```

It copies the skill into `~/.claude/skills/shopify-app-dev/`, the two slash commands into `~/.claude/commands/`, and `sed`-substitutes the `<skill-dir>` placeholder so script invocations resolve to `$HOME/.claude/skills/shopify-app-dev`. The `cache/` directory is excluded so each user builds their own.

Uninstall with:

```bash
bash scripts/uninstall-standalone.sh
```

Standalone bypasses the plugin manifest entirely; Claude Code auto-discovers skills under `~/.claude/skills/` and commands under `~/.claude/commands/`. You lose plugin metadata (versioning, namespaced command names) but gain zero-ceremony installation.

The first invocation downloads `https://shopify.dev/llms.txt` and builds the index into the skill's `cache/` directory. Subsequent invocations reuse the cache for 7 days.

## Manual rebuild

```bash
bash skills/shopify-app-dev/scripts/build_index.sh
```
