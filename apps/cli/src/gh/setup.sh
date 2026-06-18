#!/bin/bash
set -euo pipefail

echo "Installing GitHub CLI..."

command -v wget >/dev/null 2>&1 || (sudo apt-get update -y && sudo apt-get install -y wget)

sudo mkdir -p -m 755 /etc/apt/keyrings
keyring_tmp="$(mktemp)"
trap 'rm -f "$keyring_tmp"' EXIT
wget -nv -O "$keyring_tmp" https://cli.github.com/packages/githubcli-archive-keyring.gpg
sudo cp "$keyring_tmp" /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y gh

echo
echo "GitHub CLI installed: $(gh --version | head -1)"
