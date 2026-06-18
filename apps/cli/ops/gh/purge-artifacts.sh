#!/bin/bash
set -euo pipefail

# sak gh purge-artifacts <user> [org]
# Bulk-deletes GitHub Actions artifacts across every repo for <user> and,
# optionally, <org>. Requires: gh (authenticated via `gh auth login`), jq, bc.

command -v gh >/dev/null 2>&1 || { echo "GitHub CLI is not installed. Run: sak install gh" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it first." >&2; exit 1; }

GH_USER="${1:?Usage: sak gh purge-artifacts <user> [org]}"
GH_ORG="${2:-}"

export GH_PAGER=cat

artifacts_file="$(mktemp)"
trap 'rm -f "$artifacts_file"' EXIT

get_repos() { gh repo list "$1" --limit 1000 --json name --jq '.[].name'; }

scan_repo() {
  local owner="$1" repo="$2" data count
  data="$(gh api "repos/$owner/$repo/actions/artifacts" 2>/dev/null)" || { echo "  -> error accessing repo"; return 0; }
  count="$(echo "$data" | jq -r '.total_count')"
  if [[ "$count" -gt 0 ]]; then
    echo "  -> found $count artifact(s)"
    echo "$data" | jq -r --arg owner "$owner" --arg repo "$repo" \
      '.artifacts[] | "\($owner)|\($repo)|\(.id)|\(.name)|\(.size_in_bytes)|\(.created_at)"' >> "$artifacts_file"
  else
    echo "  -> no artifacts"
  fi
}

scan_owner() {
  local owner="$1" repos
  [[ -z "$owner" ]] && return 0
  echo "Scanning repositories for: $owner"
  repos="$(get_repos "$owner")"
  [[ -z "$repos" ]] && return 0
  while IFS= read -r repo; do
    echo "Checking: $owner/$repo"
    scan_repo "$owner" "$repo"
  done <<< "$repos"
}

scan_owner "$GH_USER"
scan_owner "$GH_ORG"

TOTAL=0
[[ -f "$artifacts_file" ]] && TOTAL=$(wc -l < "$artifacts_file" | tr -d ' ')

echo
echo "Total artifacts found: $TOTAL"

if [[ "$TOTAL" -eq 0 ]]; then
  echo "Nothing to delete."
  exit 0
fi

printf '%-20s %-25s %-15s %-35s %-12s %s\n' "OWNER" "REPOSITORY" "ARTIFACT ID" "NAME" "SIZE (MB)" "CREATED"
while IFS='|' read -r owner repo id name size created; do
  size_mb=$(echo "scale=2; $size / 1024 / 1024" | bc)
  printf '%-20s %-25s %-15s %-35s %-12s %s\n' "$owner" "$repo" "$id" "$name" "$size_mb" "${created:0:10}"
done < "$artifacts_file"

echo
read -rp "Delete ALL $TOTAL artifact(s)? (yes/no): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { echo "Cancelled."; exit 0; }

while IFS='|' read -r owner repo id name size created; do
  echo "Deleting: $name (id: $id) from $owner/$repo..."
  if gh api -X DELETE "repos/$owner/$repo/actions/artifacts/$id" 2>/dev/null; then
    echo "  done"
  else
    echo "  failed" >&2
  fi
  sleep 0.5
done < "$artifacts_file"

echo
echo "Deletion complete. GitHub can take 6-12 hours to reflect freed storage in your quota."
