#!/bin/bash
# Pulls the Obsidian vault into Claude cloud containers via obsidian-headless.
# No-op on local machines: the desktop app already syncs the vault there, and
# running headless sync on the same device as the app causes data conflicts.
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

if ! command -v ob >/dev/null 2>&1; then
  npm install -g obsidian-headless >/dev/null 2>&1 || { echo "vault-sync: could not install obsidian-headless" >&2; exit 0; }
fi

if [ -z "$OBSIDIAN_EMAIL" ] || [ -z "$OBSIDIAN_PASSWORD" ]; then
  echo "vault-sync: OBSIDIAN_EMAIL / OBSIDIAN_PASSWORD not set in environment config; skipping vault sync" >&2
  exit 0
fi

VAULT_DIR="${OBSIDIAN_VAULT_DIR:-$HOME/vault}"
VAULT_NAME="${OBSIDIAN_VAULT_NAME:-Life}"
mkdir -p "$VAULT_DIR"

# ob login has no --json flag (as of this beta CLI); credentials come from env vars only.
ob login --email "$OBSIDIAN_EMAIL" --password "$OBSIDIAN_PASSWORD" \
  || { echo "vault-sync: ob login failed (MFA enabled on the account? flags changed? try 'ob --help')" >&2; exit 0; }

if [ ! -f "$VAULT_DIR/.sync-configured" ]; then
  if [ -n "$OBSIDIAN_VAULT_PASSWORD" ]; then
    ob sync-setup --vault "$VAULT_NAME" --path "$VAULT_DIR" --password "$OBSIDIAN_VAULT_PASSWORD" --json
  else
    ob sync-setup --vault "$VAULT_NAME" --path "$VAULT_DIR" --json
  fi || { echo "vault-sync: sync-setup failed; check vault name with 'ob sync-list-remote --json'" >&2; exit 0; }
  touch "$VAULT_DIR/.sync-configured"
fi

ob sync --path "$VAULT_DIR" || { echo "vault-sync: ob sync failed" >&2; exit 0; }
echo "vault-sync: Obsidian vault '$VAULT_NAME' synced to $VAULT_DIR"
exit 0
