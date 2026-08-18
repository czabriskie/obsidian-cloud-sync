# obsidian-cloud-sync

Gives Claude Code **cloud sessions** access to my Obsidian Sync vault ("Life") by pulling it
into the container with the official [obsidian-headless](https://github.com/obsidianmd/obsidian-headless)
client at session start. Locally this repo does nothing — the desktop app already syncs the vault.

## How it works

- **Setup script** (cloud environment dialog): installs `obsidian-headless` once per
  environment; cached in the environment snapshot (~7-day TTL).
- **SessionStart hook** (`.claude/settings.json`): runs `.claude/scripts/cloud-init.sh` on
  every session. The script is a no-op unless `CLAUDE_CODE_REMOTE=true`, so it never runs on
  my Mac (headless sync + the desktop app on the same device causes conflicts).
- **`vault-sync` skill** (`.claude/skills/vault-sync/`): lets Claude re-sync or troubleshoot
  on demand. It lives in the repo so cloud sessions get it too — personal `~/.claude` skills
  don't travel to cloud containers.
- **Permissions allowlist** (`.claude/settings.json`): pre-approves the `ob` / npm commands
  so scheduled runs need no permission prompts.
- **Weekly routine**: a scheduled cloud agent syncs the vault weekly, which also keeps the
  environment snapshot warm so interactive sessions start fast.

The vault lands at `$HOME/vault` inside the container and is never committed to this repo.

## One-time environment setup (claude.ai/code → environment dialog)

1. **Environment variables** (`.env` format): `OBSIDIAN_EMAIL`, `OBSIDIAN_PASSWORD`,
   `OBSIDIAN_VAULT_NAME` (=Life), and `OBSIDIAN_VAULT_PASSWORD` only if the vault uses a
   custom E2E encryption password.

   ⚠️ Cloud environments have **no secrets store yet** — environment variables are stored in
   plaintext in the environment config and are readable by anyone with access to the
   environment. Keep this environment personal; rotate the password if it may have leaked.

2. **Setup script**:

   ```bash
   npm install -g obsidian-headless || true
   exit 0
   ```

3. **Network access**: set to **Full**, or Custom with Obsidian's API/sync domains allowed
   (the default Trusted list may not include them).

4. **MFA**: `ob login` cannot automate a live MFA code. For unattended runs the Obsidian
   account must not have MFA enabled (or you log in manually once per session).

## Using from the Claude app (remote)

After the one-time environment setup above, everything runs from claude.ai or the mobile app —
no local machine involved:

1. Go to **claude.ai/code** (or the Claude app) → new cloud session → repository
   **czabriskie/obsidian-cloud-sync**, environment **obsidian-vault** (the dedicated
   environment holding the `OBSIDIAN_*` variables — keeps them out of other environments).
2. The SessionStart hook syncs the vault to `~/vault` automatically. Ask Claude to
   "check the vault synced" if unsure (it runs the `vault-sync` skill).
3. To write an article from vault notes, say e.g. *"use the write-article skill: draft an
   article about &lt;topic&gt;"*. Drafts land in `articles/` and are pushed to this repo.
4. The **Weekly Obsidian vault sync** routine (claude.ai/code/routines) re-verifies the
   pipeline every Monday morning and keeps the environment snapshot warm.

## Notes

- `obsidian-headless` is an open beta; if a flag has changed, `ob --help` and
  `ob sync-list-remote --json` are the ground truth. The vault-sync skill says the same.
- Sync mode is bidirectional by default, so edits Claude makes in the cloud propagate back
  to my devices through Obsidian Sync. Use `ob sync-config --mode pull-only` for read-only.
