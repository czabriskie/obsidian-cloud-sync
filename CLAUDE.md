# obsidian-cloud-sync

This repo exists to give Claude Code **cloud sessions** access to Cameron's Obsidian vault.
It carries configuration, not application code.

- In cloud sessions (`CLAUDE_CODE_REMOTE=true`): the SessionStart hook syncs the vault to
  `~/vault` via the official `obsidian-headless` CLI. If the vault is missing or stale, use
  the `vault-sync` skill.
- On Cameron's Mac: do NOT run headless sync (conflicts with the desktop app). The live
  vault is at `~/Vaults/Life`.

The vault is personal knowledge-base data (PARA structure: `1 Projects`, `2 Areas`, …,
daily notes at the root as `YYYY-MM-DD.md`). Treat it as private: quote from it to answer
questions, but never publish, commit, or transmit vault contents elsewhere. Never print the
`OBSIDIAN_*` environment variables.

Sync is bidirectional: edits made to `~/vault` in a cloud session propagate back to all of
Cameron's devices via Obsidian Sync. Edit deliberately.
