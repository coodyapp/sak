#!/bin/bash
set -euo pipefail

# sak cloudflare ip [tunnel-id]
# Deletes private network IP routes assigned to a given Tunnel ID.
# Requires: cloudflared (authenticated via `cloudflared tunnel login`), jq.

command -v cloudflared >/dev/null 2>&1 || { echo "cloudflared is not installed. Run: sak install cloudflared" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it first." >&2; exit 1; }

TUNNEL_ID="${1:-}"
[[ -z "$TUNNEL_ID" ]] && read -rp "Tunnel ID: " TUNNEL_ID
[[ -n "$TUNNEL_ID" ]] || { echo "No Tunnel ID provided. Aborting." >&2; exit 1; }

ROUTES=$(cloudflared tunnel route ip list --filter-tunnel-id "$TUNNEL_ID" -o json)
if [[ -z "$ROUTES" || "$ROUTES" == "[]" ]]; then
  echo "No IP routes found for tunnel $TUNNEL_ID."
  exit 0
fi

echo "IP routes for tunnel $TUNNEL_ID:"
echo "$ROUTES" | jq -r '.[].network' | sed 's/^/  - /'

TOTAL=$(echo "$ROUTES" | jq 'length')
echo
echo "Total: $TOTAL route(s)"

read -rp "Delete these $TOTAL route(s)? [y/N] " CONFIRM
[[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]] || { echo "Cancelled."; exit 0; }

echo "$ROUTES" | jq -r '.[].network' | while read -r NETWORK; do
  if RESULT=$(cloudflared tunnel route ip delete "$NETWORK" 2>&1); then
    echo "  deleted: $NETWORK"
  else
    echo "  failed: $NETWORK -- $RESULT" >&2
  fi
done

echo
echo "Done."
