#!/bin/bash
set -euo pipefail

# sak gh prs [gh pr list args...]
# Thin wrapper around `gh pr list` for the current repo (pass --repo for another).
# Requires: gh (authenticated via `gh auth login`).

command -v gh >/dev/null 2>&1 || { echo "GitHub CLI is not installed. Run: sak install gh" >&2; exit 1; }

gh pr list "$@"
