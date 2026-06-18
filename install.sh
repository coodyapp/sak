#!/bin/bash
# Bootstrap installer for SAK, served at https://coody.app/install.sh
#
#   curl -fsSL https://coody.app/install.sh | bash
#   curl -fsSL https://coody.app/install.sh | bash -s -- install docker
set -euo pipefail

SAK_HOME="${SAK_HOME:-$HOME/.sak}"
SAK_BIN_DIR="${SAK_BIN_DIR:-$HOME/.local/bin}"
SAK_LATEST_RELEASE_API="https://api.github.com/repos/coodyapp/sak/releases/latest"

if [[ ! -f /etc/debian_version ]] && [[ "$(uname -s)" != "Darwin" ]]; then
  echo "SAK currently supports Debian-based Linux and macOS only." >&2
  echo "Support for other operating systems is coming soon." >&2
  exit 1
fi

echo "Installing SAK CLI..."
echo

sak_tag="$(curl -fsSL "$SAK_LATEST_RELEASE_API" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
[[ -n "$sak_tag" ]] || { echo "Could not determine the latest SAK release." >&2; exit 1; }
SAK_REPO_TARBALL="https://github.com/coodyapp/sak/archive/refs/tags/$sak_tag.tar.gz"
echo "Downloading $sak_tag from $SAK_REPO_TARBALL"

tmp_tarball="$(mktemp)"
tmp_extract="$(mktemp -d)"
trap 'rm -f "$tmp_tarball"; rm -rf "$tmp_extract"' EXIT

curl_progress=(-fL --progress-bar)
[[ -n "${CI:-}" ]] && curl_progress=(-fL -s)
curl "${curl_progress[@]}" "$SAK_REPO_TARBALL" -o "$tmp_tarball"

tar -xzf "$tmp_tarball" -C "$tmp_extract" --strip-components=1

rm -rf "$SAK_HOME"
mkdir -p "$SAK_HOME"
cp -a "$tmp_extract/apps/cli/." "$SAK_HOME/"

mkdir -p "$SAK_BIN_DIR"
chmod +x "$SAK_HOME/bin/sak"
ln -sf "$SAK_HOME/bin/sak" "$SAK_BIN_DIR/sak"

# shellcheck source=/dev/null
source "$SAK_HOME/lib/colors.sh"
sak_set_colors

case "$(basename "${SHELL:-bash}")" in
  zsh) shell_rc="$HOME/.zshrc" ;;
  *) shell_rc="$HOME/.bashrc" ;;
esac
path_note="Added $SAK_BIN_DIR to \$PATH in $shell_rc"
if grep -qs "$SAK_BIN_DIR" "$shell_rc" 2>/dev/null; then
  path_note="$SAK_BIN_DIR is already in \$PATH ($shell_rc)"
else
  echo "export PATH=\"$SAK_BIN_DIR:\$PATH\"" >> "$shell_rc"
fi

sak_version="$("$SAK_HOME/bin/sak" version)"

echo
echo "${C_GREEN}${sak_version} installed successfully!${C_RESET}"
echo
echo "Binary: $SAK_BIN_DIR/sak"
echo "$path_note"
echo
echo "${C_BOLD}To start using SAK, run:${C_RESET}"
echo
echo "  source $shell_rc"
echo "  sak help"

if [[ $# -gt 0 ]]; then
  echo
  export PATH="$SAK_BIN_DIR:$PATH"
  exec "$SAK_HOME/bin/sak" "$@"
fi

echo
echo "${C_BOLD}Next steps:${C_RESET}"
echo
echo "  sak list"
echo "  sak install docker"
