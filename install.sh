#!/bin/bash
# Bootstrap installer for sak, served at https://coody.app/install.sh
#
#   curl -fsSL https://coody.app/install.sh | bash
#   curl -fsSL https://coody.app/install.sh | bash -s -- install docker
set -euo pipefail

SAK_HOME="${SAK_HOME:-$HOME/.sak}"
SAK_BIN_DIR="${SAK_BIN_DIR:-$HOME/.local/bin}"
SAK_REPO_TARBALL="https://github.com/coodyapp/sak/archive/refs/heads/main.tar.gz"

if [[ ! -f /etc/debian_version ]]; then
  echo "sak currently supports Debian-based Linux only (Ubuntu, Debian, etc)." >&2
  echo "Support for other operating systems is coming soon." >&2
  exit 1
fi

echo "Installing sak to $SAK_HOME..."
rm -rf "$SAK_HOME"
mkdir -p "$SAK_HOME"
curl -fsSL "$SAK_REPO_TARBALL" | tar -xz -C "$SAK_HOME" --strip-components=1

mkdir -p "$SAK_BIN_DIR"
chmod +x "$SAK_HOME/bin/sak"
ln -sf "$SAK_HOME/bin/sak" "$SAK_BIN_DIR/sak"

case "$(basename "${SHELL:-bash}")" in
  zsh) shell_rc="$HOME/.zshrc" ;;
  *) shell_rc="$HOME/.bashrc" ;;
esac
if ! grep -qs "$SAK_BIN_DIR" "$shell_rc" 2>/dev/null; then
  echo "export PATH=\"$SAK_BIN_DIR:\$PATH\"" >> "$shell_rc"
fi

echo "sak installed!"
echo

if [[ $# -gt 0 ]]; then
  export PATH="$SAK_BIN_DIR:$PATH"
  exec "$SAK_HOME/bin/sak" "$@"
fi

echo "Run 'sak list' to see available tools, or 'sak install docker' to get started."
echo "Restart your shell, or run: export PATH=\"$SAK_BIN_DIR:\$PATH\""
