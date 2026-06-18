#!/bin/bash
set -euo pipefail

echo "Installing AWS CLI..."

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

sudo apt-get update -y
sudo apt-get install -y unzip curl

arch_zip="awscli-exe-linux-x86_64.zip"
[[ "$(uname -m)" == "aarch64" ]] && arch_zip="awscli-exe-linux-aarch64.zip"
curl -fsSL "https://awscli.amazonaws.com/$arch_zip" -o "$tmp_dir/awscliv2.zip"
unzip -q -o "$tmp_dir/awscliv2.zip" -d "$tmp_dir"

if command -v aws >/dev/null 2>&1; then
  sudo "$tmp_dir/aws/install" --update
else
  sudo "$tmp_dir/aws/install"
fi

echo
echo "AWS CLI installed: $(aws --version)"
echo "Run 'aws configure' to set your credentials."
