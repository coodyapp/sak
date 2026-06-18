#!/bin/bash
set -euo pipefail

# sak cloudflare worker-purge
# Bulk-deletes every non-production Cloudflare Pages deployment for a project
# (works around the dashboard/API limit on projects with 100+ deployments).
# Requires: curl, jq, CF_API_TOKEN (Pages: Edit, Account Settings: Read),
# CF_ACCOUNT_ID, CF_PROJECT_NAME.

command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it first." >&2; exit 1; }

CF_API_TOKEN="${CF_API_TOKEN:?Set CF_API_TOKEN (Account / Cloudflare Pages: Edit, Account / Account Settings: Read)}"
CF_ACCOUNT_ID="${CF_ACCOUNT_ID:?Set CF_ACCOUNT_ID}"
CF_PROJECT_NAME="${CF_PROJECT_NAME:?Set CF_PROJECT_NAME}"

BASE_URL="https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/pages/projects/${CF_PROJECT_NAME}/deployments"
AUTH_HEADERS=(-H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json")

echo "Fetching project info..."
PROJECT_INFO=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/pages/projects/${CF_PROJECT_NAME}" \
  "${AUTH_HEADERS[@]}")

if [[ "$(echo "$PROJECT_INFO" | jq -r '.success')" != "true" ]]; then
  echo "Failed to fetch project. Check CF_ACCOUNT_ID, CF_PROJECT_NAME, and token permissions." >&2
  echo "$PROJECT_INFO" | jq '.errors' >&2
  exit 1
fi

PROD_DEPLOYMENT_ID=$(echo "$PROJECT_INFO" | jq -r '.result.canonical_deployment.id')
echo "Production deployment (preserved): $PROD_DEPLOYMENT_ID"

echo "Collecting all deployments..."
ALL_IDS=()
PAGE=1
while true; do
  RESPONSE=$(curl -s -X GET "${BASE_URL}?per_page=25&page=${PAGE}" "${AUTH_HEADERS[@]}")
  IDS=$(echo "$RESPONSE" | jq -r '.result[].id')
  [[ -z "$IDS" ]] && break
  while IFS= read -r ID; do ALL_IDS+=("$ID"); done <<< "$IDS"
  PAGE=$((PAGE + 1))
done

TO_DELETE=()
for ID in "${ALL_IDS[@]}"; do
  [[ "$ID" != "$PROD_DEPLOYMENT_ID" ]] && TO_DELETE+=("$ID")
done
TOTAL=${#TO_DELETE[@]}

if [[ "$TOTAL" -eq 0 ]]; then
  echo "No deployments to delete. Project is already clean."
  exit 0
fi

echo
echo "The following $TOTAL deployment(s) will be permanently deleted:"
printf '  - %s\n' "${TO_DELETE[@]}"
echo
echo "Project:   $CF_PROJECT_NAME"
echo "Account:   $CF_ACCOUNT_ID"
echo "Preserved: $PROD_DEPLOYMENT_ID (production)"
echo

read -rp "Type YES to confirm deletion of $TOTAL deployment(s): " CONFIRM
[[ "$CONFIRM" == "YES" ]] || { echo "Aborted. Nothing was deleted."; exit 0; }

DELETED=0
FAILED=0
for ID in "${TO_DELETE[@]}"; do
  HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "${BASE_URL}/${ID}?force=true" "${AUTH_HEADERS[@]}")
  if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "204" ]]; then
    echo "  deleted: $ID"
    DELETED=$((DELETED + 1))
  else
    echo "  failed:  $ID (HTTP $HTTP_STATUS)" >&2
    FAILED=$((FAILED + 1))
  fi
  sleep 0.3
done

echo
echo "Deleted: $DELETED, Failed: $FAILED, Preserved: 1 ($PROD_DEPLOYMENT_ID)"
