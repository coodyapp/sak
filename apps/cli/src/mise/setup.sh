#!/bin/bash
set -euo pipefail

echo "Installing mise..."

sudo apt-get update -y
sudo apt-get install -y gpg wget curl
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y mise

if ! grep -qs 'mise activate bash' "$HOME/.bashrc" 2>/dev/null; then
  # shellcheck disable=SC2016
  echo 'eval "$(mise activate bash)"' >> "$HOME/.bashrc"
fi

echo
echo "mise installed: $(mise --version)"
