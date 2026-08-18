---
name: vault-sync
description: Sync the Obsidian vault into this environment via obsidian-headless, check sync status, or troubleshoot a failed sync. Use when the user asks to sync/refresh the vault, when vault data at ~/vault is missing or stale, or when the weekly sync routine runs.
---

# vault-sync

Pull the latest Obsidian Sync data into this environment using the official
`obsidian-headless` CLI (`ob`).

## Where things are

- Vault contents: `$OBSIDIAN_VAULT_DIR` (default `~/vault`)
- Credentials: `OBSIDIAN_EMAIL`, `OBSIDIAN_PASSWORD`, optional `OBSIDIAN_VAULT_PASSWORD`
  (E2E encryption password) and `OBSIDIAN_VAULT_NAME` (default `Life`) — provided by the
  cloud environment configuration. NEVER print, echo, or write these values anywhere.
- Init script (same logic, runs automatically at session start in cloud):
  `.claude/scripts/cloud-init.sh`

## Cloud only

Only sync when `CLAUDE_CODE_REMOTE=true`. On the user's local machine the Obsidian desktop
app owns syncing (vault at `~/Vaults/Life`); running headless sync there causes data
conflicts. If invoked locally, read the vault directly from `~/Vaults/Life` instead.

## Steps

1. If `ob` is missing: `npm install -g obsidian-headless`
2. `bash "$CLAUDE_PROJECT_DIR/.claude/scripts/cloud-init.sh"` — handles login, first-time
   `sync-setup`, and `ob sync`.
3. Verify: the vault dir should contain markdown files and a `.obsidian/` folder. Report
   file count and last-modified recency, not file contents.

## Troubleshooting

- `obsidian-headless` is an open beta — if a command or flag errors, consult `ob --help`
  and `ob <command> --help`; the flags in the init script may need updating. Fix the script
  and commit the fix so future sessions benefit.
- Wrong/unknown vault name: `ob sync-list-remote --json` lists remote vaults.
- Login failures: usually MFA is enabled on the Obsidian account (cannot be automated) or
  the credentials env vars are missing from the environment config. Report which it is —
  never work around auth by other means.
- Network errors: the environment's network access level may exclude Obsidian's sync
  endpoints; the user must set network access to Full or allowlist the domains in the
  environment dialog.
