#!/bin/bash
set -euo pipefail

# sak cloudflare dns [tunnel-id]
# Deletes DNS CNAME records in a Cloudflare zone that point to a given Tunnel ID.
# Requires: curl, jq, CF_API_TOKEN (DNS edit permission), CF_ZONE_ID.

command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it first." >&2; exit 1; }

CF_API_TOKEN="${CF_API_TOKEN:?Set CF_API_TOKEN (Cloudflare API token with DNS edit permission)}"
CF_ZONE_ID="${CF_ZONE_ID:?Set CF_ZONE_ID (the Cloudflare zone ID)}"

TUNNEL_ID="${1:-}"
[[ -z "$TUNNEL_ID" ]] && read -rp "Tunnel ID: " TUNNEL_ID
[[ -n "$TUNNEL_ID" ]] || { echo "No Tunnel ID provided. Aborting." >&2; exit 1; }

BACKUP_FILE="dns_backup_$(date +%Y%m%d_%H%M%S).json"
echo "Backing up all DNS records to $BACKUP_FILE..."
ALL_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?per_page=500" \
  -H "Authorization: Bearer $CF_API_TOKEN")

if [[ "$(echo "$ALL_RECORDS" | jq -r '.success')" != "true" ]]; then
  echo "Failed to fetch DNS records:" >&2
  echo "$ALL_RECORDS" | jq '.errors' >&2
  exit 1
fi
echo "$ALL_RECORDS" | jq '.' > "$BACKUP_FILE"

RECORDS=$(echo "$ALL_RECORDS" | jq --arg tid "$TUNNEL_ID" \
  '[.result[] | select(.type == "CNAME") | select(.content | contains($tid))]')
TOTAL=$(echo "$RECORDS" | jq 'length')

echo
echo "CNAME records pointing at tunnel $TUNNEL_ID:"
echo "$RECORDS" | jq -r '.[] | "  \(.name)  ->  \(.content)  [id: \(.id)]"'
echo
echo "Total: $TOTAL record(s)"

if [[ "$TOTAL" -eq 0 ]]; then
  echo "Nothing to delete."
  exit 0
fi

read -rp "Delete these $TOTAL record(s)? [y/N] " CONFIRM
[[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]] || { echo "Cancelled."; exit 0; }

echo "$RECORDS" | jq -r '.[].id' | while read -r RECORD_ID; do
  RESULT=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $CF_API_TOKEN")
  if [[ "$(echo "$RESULT" | jq -r '.success')" == "true" ]]; then
    echo "  deleted: $RECORD_ID"
  else
    echo "  failed: $RECORD_ID -- $(echo "$RESULT" | jq -c '.errors')" >&2
  fi
done

echo
echo "Done. Backup saved at: $BACKUP_FILE"
