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

# If a TOTP seed is provided, compute the current MFA code so login works with
# MFA enabled on the account. Seed is the base32 string from authenticator enrollment.
MFA_ARGS=()
if [ -n "$OBSIDIAN_TOTP_SECRET" ]; then
  MFA_CODE=$(node -e '
    const c = require("crypto");
    const s = process.env.OBSIDIAN_TOTP_SECRET.replace(/[\s=-]/g, "").toUpperCase();
    const A = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    let bits = "";
    for (const ch of s) { const v = A.indexOf(ch); if (v >= 0) bits += v.toString(2).padStart(5, "0"); }
    const key = Buffer.from(bits.match(/.{8}/g).map(b => parseInt(b, 2)));
    const msg = Buffer.alloc(8);
    msg.writeBigUInt64BE(BigInt(Math.floor(Date.now() / 30000)));
    const h = c.createHmac("sha1", key).update(msg).digest();
    const o = h[h.length - 1] & 15;
    console.log(((h.readUInt32BE(o) & 0x7fffffff) % 1e6).toString().padStart(6, "0"));
  ') && MFA_ARGS=(--mfa "$MFA_CODE")
fi

# ob login has no --json flag (as of this beta CLI); credentials come from env vars only.
ob login --email "$OBSIDIAN_EMAIL" --password "$OBSIDIAN_PASSWORD" "${MFA_ARGS[@]}" \
  || { echo "vault-sync: ob login failed (MFA enabled but no/stale OBSIDIAN_TOTP_SECRET? flags changed? try 'ob --help')" >&2; exit 0; }

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
