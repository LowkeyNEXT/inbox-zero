#!/usr/bin/env bash
# Generate all required secrets for Inbox Zero .env
set -euo pipefail

ENV_FILE="${1:-apps/web/.env}"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found. Copy .env.example first."
    exit 1
fi

echo "Generating secrets for $ENV_FILE ..."

# Generate and replace empty secret values
for key in AUTH_SECRET INTERNAL_API_KEY EMAIL_ENCRYPT_SECRET UPSTASH_REDIS_TOKEN CRON_SECRET; do
    value=$(openssl rand -hex 32)
    # Only replace if the value is empty (KEY= with nothing after)
    sed -i.bak "s|^${key}=$|${key}=${value}|" "$ENV_FILE"
    echo "  ${key} = ${value:0:8}..."
done

# Salt uses 16 bytes
salt=$(openssl rand -hex 16)
sed -i.bak "s|^EMAIL_ENCRYPT_SALT=$|EMAIL_ENCRYPT_SALT=${salt}|" "$ENV_FILE"
echo "  EMAIL_ENCRYPT_SALT = ${salt:0:8}..."

# Cleanup backup files
rm -f "${ENV_FILE}.bak"

echo ""
echo "Secrets generated. Edit $ENV_FILE to fill in:"
echo "  - NEXT_PUBLIC_BASE_URL"
echo "  - OLLAMA_BASE_URL (your Ollama VM IP)"
echo "  - GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET"
echo "  - MICROSOFT_CLIENT_ID / MICROSOFT_CLIENT_SECRET"
