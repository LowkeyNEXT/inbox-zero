# Inbox Zero — Self-Hosted on Proxmox

AI-powered email assistant using Ollama for local LLM inference.

## Architecture

```
Proxmox (192.168.50.50)
├── LXC: inbox-zero
│   ├── Docker: inbox-zero app (port 3000)
│   ├── Docker: PostgreSQL
│   ├── Docker: Redis
│   └── Docker: Cron scheduler
└── VM/LXC: ollama (port 11434)
    ├── llama3.1:8b (primary)
    └── qwen3:1.7b (economy)
```

## Quick Start

### 1. Create LXC on Proxmox

```bash
# From Proxmox host (SSH or shell)
bash scripts/create-lxc.sh 200   # 200 = container ID
```

### 2. Setup Docker inside LXC

```bash
# Enter the LXC
pct enter 200
# Run setup
bash /root/setup-lxc.sh
```

### 3. Configure

```bash
cp .env.example .env
# Fill in your values (Ollama IP, OAuth creds, domain)
bash scripts/generate-secrets.sh  # auto-generates secret keys
```

### 4. Deploy

```bash
bash scripts/deploy.sh <LXC_IP>
```

## LLM Config

- Primary: `llama3.1:8b` via Ollama
- Economy: `qwen3:1.7b` via Ollama
- Ollama must have `OLLAMA_HOST=0.0.0.0` to accept remote connections

## OAuth Setup Required

- **Gmail**: Google Cloud Console > APIs & Services > Credentials
- **Outlook**: Azure Portal > App Registrations
- **iCloud**: Not natively supported — forward iCloud mail to Gmail/Outlook
