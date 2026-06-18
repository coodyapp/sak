#!/bin/bash
set -euo pipefail

check_docker() {
  echo "Checking if Docker is running..."

  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Run 'sak install docker' first." >&2
    exit 1
  fi

  if command -v rc-service >/dev/null 2>&1; then
    rc-service docker status | grep -q started \
      || { echo "Docker is not running. Start it with: rc-service docker start" >&2; exit 1; }
  elif command -v systemctl >/dev/null 2>&1; then
    systemctl is-active --quiet docker \
      || { echo "Docker is not running. Start it with: systemctl start docker" >&2; exit 1; }
  else
    docker info >/dev/null 2>&1 \
      || { echo "Docker is not running or not accessible." >&2; exit 1; }
  fi

  echo "Docker is running."
}

install_agent() {
  echo "Pulling Portainer Agent image..."
  docker pull portainer/agent:latest

  if docker ps -a --format '{{.Names}}' | grep -qx portainer-agent; then
    echo "Removing existing Portainer Agent container..."
    docker rm -f portainer-agent
  fi

  echo "Starting Portainer Agent container..."
  docker run -d \
    --name portainer-agent \
    --restart always \
    -p 9001:9001 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    --network bridge \
    portainer/agent:latest
}

verify() {
  echo "Verifying Portainer Agent installation..."
  sleep 3
  if [[ "$(docker inspect -f '{{.State.Running}}' portainer-agent 2>/dev/null)" == "true" ]]; then
    echo "Portainer Agent is running and accessible on port 9001."
  else
    echo "Failed to start Portainer Agent. Check logs with: docker logs portainer-agent" >&2
    exit 1
  fi
}

check_docker
install_agent
verify

echo
echo "Portainer Agent installation completed successfully!"
echo "Connect to this agent from your Portainer server using this host's address on port 9001."
