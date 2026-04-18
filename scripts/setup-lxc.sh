#!/usr/bin/env bash
# Setup script for Inbox Zero LXC container on Proxmox
# Run this INSIDE the LXC container after creating it
set -euo pipefail

echo "=== Inbox Zero LXC Setup ==="

# Update system
apt-get update && apt-get upgrade -y

# Install Docker
apt-get install -y ca-certificates curl gnupg lsb-release git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

echo "=== Docker installed ==="
docker --version
docker compose version

# Clone Inbox Zero
cd /opt
git clone https://github.com/elie222/inbox-zero.git
cd inbox-zero

echo ""
echo "=== Next steps ==="
echo "1. Copy your .env file to /opt/inbox-zero/apps/web/.env"
echo "2. Generate secrets:  cd /opt/inbox-zero && bash scripts/generate-secrets.sh"
echo "3. Start services:    cd /opt/inbox-zero && docker compose --profile all up -d"
echo "4. Access at:          http://<LXC_IP>:3000"
