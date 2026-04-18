#!/usr/bin/env bash
# Create an LXC container on Proxmox for Inbox Zero
# Run this on the Proxmox host (or via SSH)
set -euo pipefail

# Configuration — adjust these as needed
CTID="${1:-200}"              # Container ID
HOSTNAME="inbox-zero"
STORAGE="local-lvm"           # Proxmox storage pool
TEMPLATE="local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
MEMORY=4096                   # 4GB RAM
SWAP=512
CORES=2
DISK_SIZE=30                  # 30GB
BRIDGE="vmbr0"

echo "=== Creating LXC container (CT ${CTID}) for Inbox Zero ==="

# Download template if not present
pveam update
if ! pveam list local | grep -q "debian-12-standard"; then
    echo "Downloading Debian 12 template..."
    pveam download local debian-12-standard_12.7-1_amd64.tar.zst
fi

# Create container
pct create "$CTID" "$TEMPLATE" \
    --hostname "$HOSTNAME" \
    --storage "$STORAGE" \
    --rootfs "${STORAGE}:${DISK_SIZE}" \
    --memory "$MEMORY" \
    --swap "$SWAP" \
    --cores "$CORES" \
    --net0 "name=eth0,bridge=${BRIDGE},ip=dhcp" \
    --features "nesting=1,keyctl=1" \
    --unprivileged 0 \
    --start 1

echo "Waiting for container to start..."
sleep 5

# Get container IP
CT_IP=$(pct exec "$CTID" -- hostname -I | awk '{print $1}')
echo ""
echo "=== LXC Container Created ==="
echo "  CT ID:    ${CTID}"
echo "  Hostname: ${HOSTNAME}"
echo "  IP:       ${CT_IP}"
echo ""
echo "Next: SSH in or use 'pct enter ${CTID}' and run setup-lxc.sh"
