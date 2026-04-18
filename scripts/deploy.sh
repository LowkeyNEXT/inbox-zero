#!/usr/bin/env bash
# Deploy Inbox Zero to the LXC container
# Run from your local machine (Mac mini)
set -euo pipefail

LXC_HOST="${1:?Usage: deploy.sh <LXC_IP>}"
REMOTE_DIR="/opt/inbox-zero"

echo "=== Deploying Inbox Zero to ${LXC_HOST} ==="

# Copy .env to the LXC
echo "Copying .env..."
scp "$(dirname "$0")/../.env" "root@${LXC_HOST}:${REMOTE_DIR}/apps/web/.env"

# SSH in and deploy
ssh "root@${LXC_HOST}" bash <<'REMOTE'
set -euo pipefail
cd /opt/inbox-zero

echo "Pulling latest..."
git pull origin main

echo "Starting services..."
docker compose --profile all pull
docker compose --profile all up -d

echo ""
echo "=== Services ==="
docker compose ps
REMOTE

echo ""
echo "=== Deployed ==="
echo "Access Inbox Zero at: http://${LXC_HOST}:3000"
