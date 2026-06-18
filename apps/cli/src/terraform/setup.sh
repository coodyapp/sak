#!/bin/bash
set -euo pipefail

echo "Installing Terraform..."

sudo apt-get update -y
sudo apt-get install -y gnupg software-properties-common curl

sudo install -m 0755 -d /usr/share/keyrings
curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y terraform

echo
echo "Terraform installed: $(terraform -v | head -1)"
