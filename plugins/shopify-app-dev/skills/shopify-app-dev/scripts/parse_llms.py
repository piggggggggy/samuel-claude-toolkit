#!/usr/bin/env python3
"""Parse a shopify.dev llms.txt file into chunk files and index.json.

Usage: parse_llms.py <path-to-llms.txt>
Reads CACHE_DIR env var (default: ./cache) for output location.
"""
import json
import os
import re
import sys
from collections import Counter
from pathlib import Path

STOPWORDS = set("""
a an and are as at be by for from has have in is it its of on or that the to was were will with
this these those you your we our they them their he she him his her i me my mine
do does did done can could should would may might must shall not no yes if then else when where
which who whom whose what why how also into about over under between within without before after
use using used uses make makes made get gets got run runs running set sets setting
""".split())

GENERIC = {"shopify", "app", "apps"}

HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
URL_RE = re.compile(r"\((https://shopify\.dev/[^\s)]+)\)")
TOKEN_RE = re.compile(r"[A-Za-z][A-Za-z0-9_-]{2,}")


def slugify(parts):
    out = []
    for p in parts[1:]:  # drop root
        s = re.sub(r"[^A-Za-z0-9]+", "-", p).strip("-").lower()
        out.append(s or "section")
    return "__".join(out) or "root"


def keywords_of(text):
    tokens = [t.lower() for t in TOKEN_RE.findall(text)]
    tokens = [t for t in tokens if t not in STOPWORDS and t not in GENERIC]
    return [w for w, _ in Counter(tokens).most_common(10)]


def first_url(body_lines):
    for line in body_lines[:5]:
        m = URL_RE.search(line)
        if m:
            return m.group(1)
    for line in body_lines:
        m = URL_RE.search(line)
        if m:
            return m.group(1)
    return None


def main():
    if len(sys.argv) != 2:
        print("usage: parse_llms.py <llms.txt>", file=sys.stderr)
        sys.exit(2)

    src = Path(sys.argv[1])
    cache = Path(os.environ.get("CACHE_DIR", "./cache"))
    chunks_dir = cache / "chunks"
    chunks_dir.mkdir(parents=True, exist_ok=True)

    text = src.read_text(encoding="utf-8")
    lines = text.splitlines()

    # Walk lines, collect (level, title, body_lines) tuples
    sections = []
    stack = []  # ancestor titles by depth (index 0..2)
    cur_level = None
    cur_title = None
    cur_body = []

    def flush():
        if cur_title is None:
            return
        path = stack[: cur_level - 1] + [cur_title]
        sections.append((cur_level, list(path), cur_body[:]))

    for line in lines:
        m = HEADING_RE.match(line)
        if m:
            flush()
            level = len(m.group(1))
            title = m.group(2).strip()
            # adjust stack: keep ancestors above this level
            stack = stack[: level - 1]
            stack.append(title)
            cur_level = level
            cur_title = title
            cur_body = []
        else:
            cur_body.append(line)
    flush()

    # Build index entries; root section (level 1) is skipped as a chunk
    entries = []
    parent_url_by_path = {}
    for level, path, body in sections:
        body_text = "\n".join(body).strip()
        url = first_url(body) or parent_url_by_path.get(tuple(path[:-1]))
        parent_url_by_path[tuple(path)] = url

        if level == 1:
            continue  # root: not stored as chunk

        slug = slugify(path)
        chunk_path = chunks_dir / f"{slug}.md"
        chunk_path.write_text(body_text + "\n", encoding="utf-8")

        entries.append({
            "slug": slug,
            "path": path,
            "url": url,
            "keywords": keywords_of(body_text + " " + " ".join(path)),
            "parent": path[-2] if len(path) >= 2 else None,
            "size": len(body_text),
        })

    (cache / "index.json").write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
