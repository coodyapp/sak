#!/bin/bash
# Shared OS guard for SAK and tool scripts.

is_debian_based() {
  [[ -f /etc/debian_version ]]
}

require_debian_based() {
  if ! is_debian_based; then
    echo "SAK currently supports Debian-based Linux only (Ubuntu, Debian, etc)." >&2
    echo "Support for other operating systems is coming soon." >&2
    exit 1
  fi
}
