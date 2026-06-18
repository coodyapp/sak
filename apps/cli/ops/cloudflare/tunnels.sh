#!/bin/bash
set -euo pipefail

# sak cloudflare tunnels [cloudflared tunnel list args...]
# Lists Cloudflare Tunnels for the authenticated account.
# Requires: cloudflared (authenticated via `cloudflared tunnel login`).

command -v cloudflared >/dev/null 2>&1 || { echo "cloudflared is not installed. Run: sak install cloudflared" >&2; exit 1; }

cloudflared tunnel list "$@"
