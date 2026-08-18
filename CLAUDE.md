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
