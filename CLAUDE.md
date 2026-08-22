# obsidian-cloud-sync

This repo exists to give Claude Code **cloud sessions** access to an Obsidian vault.
It carries configuration, not application code.

- In cloud sessions (`CLAUDE_CODE_REMOTE=true`): the SessionStart hook syncs the vault to
  `~/vault` via the official `obsidian-headless` CLI. If the vault is missing or stale, use
  the `vault-sync` skill.
- On a machine running the Obsidian desktop app: do NOT run headless sync there — it
  conflicts with the app's own syncing. Read the local vault directly instead.

The vault is personal knowledge-base data. Treat it as private: quote from it to answer
questions, but never publish, commit, or transmit vault contents elsewhere. Never print the
`OBSIDIAN_*` environment variables.

Sync is bidirectional by default: edits made to `~/vault` in a cloud session propagate back
to every device on the account. Edit deliberately.

## Publishing content drawn from this vault (LinkedIn / blog routines)

Any routine that drafts LinkedIn posts, blog posts, or other public content from this
vault — including the weekly Signal Log routine — must additionally follow these rules,
on top of whatever privacy rules that routine's own instructions already state:

- **No current, ongoing situation at Cameron's day job.** Not just "don't name the
  employer" — don't frame a draft around something live and in-progress at work, even in
  the abstract ("this week I ran into X," "a team that might not make it to next quarter,"
  "leadership's current top priority"). A generalized, resolved, or clearly past reflection
  on a work-shaped problem is fine; a draft that reads like a status update on something
  happening right now at his job is not, no matter how genericized the nouns are. If a
  draft leans on this kind of material, generalize the framing away from "this is
  happening to me right now" into "here's a pattern I've noticed," or drop the material.
- **Never reveal, imply, or reference that Cameron is building a product or a company** —
  don't name it, don't call it "the app I'm building" or "my side project," don't use
  details specific enough to identify it. This applies even when the source note itself
  names the project; paraphrase around it or drop that thread of the note entirely.
- **Cross-link a companion blog post from its LinkedIn draft.** When a Tech Byte or Life
  Byte on camzabriskie.com is written as the long-form companion to a LinkedIn draft, the
  LinkedIn post body should end with a line pointing to it (the post's URL is predictable:
  `https://camzabriskie.com/<tech-bytes|life-bytes>/<slug>/`), to drive readers to the
  full version. This applies even before the blog PR is merged, since the URL is fixed by
  the slug.
- **Link the actual source whenever a draft references someone else's work.** If a
  LinkedIn or blog draft is built on a Readwise highlight (an article, a guide, a book
  review, anything with a `book_source_url`), the draft must include that URL, not just
  name the site or author. Pull `book_source_url` (and `url` as a fallback) when fetching
  highlights — don't fetch just `text`/`note`/`book_title`/`book_author`, that leaves the
  link out. This doesn't apply to journal-sourced drafts, where there's no other person's
  work being referenced.

These four came out of real corrections on 2026-08-22: a first-pass draft read as
describing a live work situation even though it never named the employer or the project,
and two drafts referenced articles by name without linking to them. When in doubt, prefer
the more generic version, and always link out when crediting someone else's work.
