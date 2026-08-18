---
name: write-article
description: Draft a long-form article or blog post grounded in Cameron's Obsidian vault notes on a given topic. Syncs the vault first if needed, mines relevant notes, and writes the draft to articles/ in this repo. Use when the user asks for an article, post, or write-up based on their notes.
---

# write-article

Turn vault notes into an article draft, written in Cameron's voice.

## Steps

1. **Ensure the vault is present.** In cloud sessions the SessionStart hook should have
   synced it to `~/vault` (or `$OBSIDIAN_VAULT_DIR`). If it's missing or stale, follow the
   `vault-sync` skill first. On Cameron's Mac, read `~/Vaults/Life` directly instead.
2. **Mine the vault.** Search broadly for the requested topic: note titles, `[[wikilinks]]`,
   tags, daily notes (`YYYY-MM-DD.md` at the vault root), and project folders
   (`1 Projects/`, `2 Areas/`). Collect Cameron's actual ideas, phrasings, and examples —
   the article should be built from what the notes really say, not generic filler.
3. **Learn the voice.** Skim a handful of longer notes and daily entries to pick up tone:
   first person, direct, concrete. Write like that — not like a content-marketing blog.
4. **Draft.** Write the article as Markdown to `articles/YYYY-MM-DD-<slug>.md` in this repo
   (create `articles/` if needed). Front-load the point; include real specifics from the
   notes; end without a summary-of-the-summary.
5. **Commit and push** the draft to `main` so it's visible from any device, and report:
   topic, word count, which vault notes fed it (paths only).

## Boundaries

- The vault is private. Quoting Cameron's own ideas into a draft he asked for is the point,
  but leave out sensitive personal details (health, finances, other people's private info)
  unless the request explicitly asks for them — flag their existence instead.
- Never commit vault files themselves to this repo, and never print `OBSIDIAN_*` env vars.
- Drafts are drafts: don't publish anywhere beyond this repo unless asked.
