#!/bin/bash
# Shared OS guards for SAK and tool scripts.
#
# sak itself and the ops commands run on Debian-based Linux and macOS.
# Installing tools (`sak install <tool>`) is Debian-based Linux only for
# now: tool setup.sh scripts are apt/systemd-based and haven't been ported
# to macOS package managers.

is_debian_based() {
  [[ -f /etc/debian_version ]]
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_supported_platform() {
  is_debian_based || is_macos
}

require_supported_platform() {
  if ! is_supported_platform; then
    echo "SAK currently supports Debian-based Linux and macOS only." >&2
    echo "Support for other operating systems is coming soon." >&2
    exit 1
  fi
}

require_debian_based() {
  if ! is_debian_based; then
    echo "Installing tools requires a Debian-based Linux host (Ubuntu, Debian, etc)." >&2
    echo "sak itself and ops commands also run on macOS, but tool installers are Debian-based Linux only for now." >&2
    exit 1
  fi
}
