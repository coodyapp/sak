#!/bin/bash
set -euo pipefail

echo "Installing cloudflared..."

sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
  | sudo tee /usr/share/keyrings/cloudflare-main.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/cloudflared.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y cloudflared

echo
echo "cloudflared installed: $(cloudflared --version)"

if [[ -n "${CF_TUNNEL_TOKEN:-}" ]]; then
  if systemctl is-active --quiet cloudflared 2>/dev/null; then
    echo "cloudflared service is already running."
  else
    echo "Registering tunnel as a system service..."
    sudo cloudflared service install "$CF_TUNNEL_TOKEN"
  fi
else
  echo
  echo "Set CF_TUNNEL_TOKEN and re-run to register a tunnel, or run manually:"
  echo "  sudo cloudflared service install <token>"
fi
