#!/bin/bash
# Run SAK straight from a checkout, without installing it.
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin/sak" "$@"
