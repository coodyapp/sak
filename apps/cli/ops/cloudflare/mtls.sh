#!/bin/bash
set -euo pipefail

# sak cloudflare mtls <domain>
# Issues an mTLS certificate chain for <domain> via Let's Encrypt + acme.sh,
# validated through a Cloudflare DNS challenge. Files land in ./certs/<domain>/.
# Requires: CF_TOKEN (Edit zone DNS permission), CF_ZONE_ID, CF_EMAIL.

DOMAIN="${1:?Usage: sak cloudflare mtls <domain>}"
CF_Token="${CF_TOKEN:?Set CF_TOKEN (Cloudflare API token with Edit zone DNS permission)}"
CF_Zone_ID="${CF_ZONE_ID:?Set CF_ZONE_ID}"
EMAIL="${CF_EMAIL:?Set CF_EMAIL (used to register with the certificate authority)}"

CERT_DIR="./certs/$DOMAIN"

if [[ -f "$HOME/.acme.sh/acme.sh" ]]; then
  echo "Removing previous acme.sh installation..."
  "$HOME/.acme.sh/acme.sh" --uninstall
  rm -rf "$HOME/.acme.sh"
fi

echo "Installing acme.sh..."
curl -fsSL https://get.acme.sh | sh -s email="$EMAIL" --no-cron

"$HOME/.acme.sh/acme.sh" --set-default-ca --server letsencrypt

rm -rf "$CERT_DIR"
mkdir -p "$CERT_DIR"

# Required by the acme.sh dns_cf hook -- these exact names are fixed by acme.sh.
export CF_Token
export CF_Zone_ID

echo "Generating certificate for $DOMAIN..."
"$HOME/.acme.sh/acme.sh" --issue --dns dns_cf -d "$DOMAIN" \
  --cert-file      "$CERT_DIR/cert.cer" \
  --key-file       "$CERT_DIR/cert.key" \
  --ca-file        "$CERT_DIR/ca.cer" \
  --fullchain-file "$CERT_DIR/fullchain.cer"

curl -fsSL -o "$CERT_DIR/root.cer" https://letsencrypt.org/certs/isrgrootx1.pem

echo
echo "Certificates generated in: $CERT_DIR"
ls "$CERT_DIR"
