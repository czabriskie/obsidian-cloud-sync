# obsidian-cloud-sync

Gives Claude Code **cloud sessions** access to an Obsidian Sync vault by pulling it into the
container with the official [obsidian-headless](https://github.com/obsidianmd/obsidian-headless)
client at session start. Locally this repo does nothing — the desktop app already syncs the
vault there.

Obsidian Sync has no public API and is end-to-end encrypted, so there is nothing to call
remotely. The headless client sidesteps that by making the container a sync *device*: it
pulls the encrypted vault and decrypts it locally, exactly like the app on a phone does.

> ### ⚠️ Read this before copying the MFA setup
>
> This repo is built for **one person's personal vault and personal cloud environment**.
>
> Claude cloud environments have no secrets store yet, so the Obsidian credentials — and,
> if you enable the MFA support below, the TOTP seed — sit in plaintext in the environment
> configuration, readable by anyone with access to that environment. In a personal
> environment that's a considered tradeoff: MFA still protects the account against a
> password leak anywhere else, which is most of what MFA does day to day.
>
> **In a shared or team environment this is a hard no.** A TOTP seed sitting next to the
> password it's supposed to protect, where teammates can read both, defeats the entire
> point of the second factor. Don't do it. Use a personal environment, or wait for a real
> secrets store.
>
> The same goes for the vault itself: sync pulls personal notes into a container. Keep the
> environment private.

## How it works

- **Setup script** (cloud environment dialog): installs `obsidian-headless` once per
  environment; cached in the environment snapshot (~7-day TTL).
- **SessionStart hook** (`.claude/settings.json`): runs `.claude/scripts/cloud-init.sh` on
  every session. The script is a no-op unless `CLAUDE_CODE_REMOTE=true`, so it never runs on
  a machine where the desktop app is already syncing (running both on one device causes
  conflicts).
- **Skills** (`.claude/skills/`): `vault-sync` to sync/verify/troubleshoot, `write-article`
  to draft from vault notes. They live in the repo because personal `~/.claude` skills don't
  travel to cloud containers — repo skills do.
- **Permissions allowlist** (`.claude/settings.json`): pre-approves the `ob` / npm commands
  so unattended runs never stall on a prompt.
- **A weekly scheduled routine** re-verifies the pipeline and keeps the environment snapshot
  warm. It's also told to repair the script if the beta CLI's flags drift, and it has
  already done exactly that once.

The vault lands at `$HOME/vault` inside the container and is never committed to this repo.

## Setup

1. **Environment variables** (cloud environment dialog, `.env` format):

   ```
   OBSIDIAN_EMAIL=you@example.com
   OBSIDIAN_PASSWORD=your-account-password
   OBSIDIAN_VAULT_NAME=YourVaultName
   # only if the remote vault uses a custom E2E encryption password:
   OBSIDIAN_VAULT_PASSWORD=your-vault-encryption-password
   # only if MFA is enabled — read the warning above first:
   OBSIDIAN_TOTP_SECRET=BASE32SEEDFROMENROLLMENT
   ```

2. **Setup script**:

   ```bash
   npm install -g obsidian-headless || true
   exit 0
   ```

3. **Network access**: set to **Full**, or Custom with Obsidian's API/sync domains allowed —
   the default Trusted list may not include them.

4. Start a cloud session on this repo. The hook syncs the vault to `~/vault` before Claude
   does anything.

### About the MFA seed

`ob login` accepts `--mfa <code>`, and a TOTP code is just a computation over a base32 seed
(the "can't scan the QR?" string shown during authenticator enrollment). `cloud-init.sh`
computes the current code at login time if `OBSIDIAN_TOTP_SECRET` is set, and behaves
exactly as before if it isn't. Re-read the warning at the top before using it.

## Notes

- `obsidian-headless` is an open beta. Flags drift; `ob --help` and
  `ob sync-list-remote --json` are the ground truth, and the `vault-sync` skill tells agents
  to check there and commit fixes.
- Sync is bidirectional by default, so edits made in a cloud session propagate back to every
  device on the account. `ob sync-config --mode pull-only` makes it read-only.

Write-up of how and why this exists:
https://camzabriskie.com/tech-bytes/vault-in-the-container/
