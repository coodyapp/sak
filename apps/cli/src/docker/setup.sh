#!/bin/bash

set -e

REAL_USER=${SUDO_USER:-$USER}

update_packages() {
  echo "Checking if Docker is installed..."
  if dpkg -l | grep -q docker; then
    echo "Removing old Docker versions..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
  else
    echo "Docker not installed, skipping removal."
  fi

  echo "Installing required packages..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
}

install() {
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
  rm get-docker.sh

  # Ensure Compose plugin is available
  docker compose version &>/dev/null || sudo apt-get install -y docker-compose-plugin
}

setup() {
  sudo groupadd docker || true
  sudo usermod -aG docker "$REAL_USER"

  sudo mkdir -p /etc/docker
  cat << EOF | sudo tee /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  },
  "storage-driver": "overlay2",
  "no-new-privileges": true,
  "debug": false,
  "live-restore": true,
  "userland-proxy": false
}
EOF

  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

check() {
  echo "Checking Docker..."
  if systemctl is-active --quiet docker; then
    echo "Docker is running."
  else
    echo "Docker is not running. Exiting..."
    exit 1
  fi

  echo "Docker version: $(docker --version)"
  echo "Compose version: $(docker compose version)"
}

echo "Starting Docker installation..."
update_packages
install
setup
check

echo
echo "Docker installation completed successfully!"
echo "Please log out and log back in (or run 'newgrp docker') for group permissions to take effect."
echo
