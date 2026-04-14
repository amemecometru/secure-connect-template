#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
TEMPLATE_FILE="$SCRIPT_DIR/config.yml.example"

echo "=============================================="
echo "  Cloudflare Tunnel Provisioning Script"
echo "=============================================="
echo ""

if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -z "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    echo "ERROR: CLOUDFLARE_API_TOKEN or CLOUDFLARE_TUNNEL_TOKEN required"
    echo ""
    echo "Set your API token in .env:"
    echo "  CLOUDFLARE_API_TOKEN=your_token_here"
    echo ""
    exit 1
fi

echo "Step 1: Installing cloudflared..."
if command -v cloudflared &> /dev/null; then
    echo "  cloudflared already installed"
else
    if [ "$(uname)" = "Darwin" ]; then
        brew install cloudflared
    elif [ "$(uname)" = "Linux" ]; then
        curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
        chmod +x /tmp/cloudflared
        sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
    fi
    echo "  cloudflared installed"
fi

echo ""
echo "Step 2: Authenticating with Cloudflare..."
if [ "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    cloudflared tunnel login
elif [ "$CLOUDFLARE_API_TOKEN" ]; then
    echo "  Using API token (service mode)"
fi
echo "  Authenticated"

echo ""
echo "Step 3: Enter your domain..."
read -p "Enter domain (e.g., example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "ERROR: Domain is required"
    exit 1
fi

echo ""
echo "Step 4: Creating tunnel for $DOMAIN..."
TUNNEL_NAME="${DOMAIN//./-}-tunnel"
TUNNEL_ID=$(cloudflared tunnel create "$TUNNEL_NAME" 2>/dev/null | grep -oP '(?<=ID: )[a-f0-9-]+' || echo "")

if [ -z "$TUNNEL_ID" ]; then
    TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $2}' || echo "")
fi

if [ -z "$TUNNEL_ID" ]; then
    echo "ERROR: Failed to create or find tunnel"
    exit 1
fi

echo "  Tunnel created: $TUNNEL_NAME (ID: $TUNNEL_ID)"

echo ""
echo "Step 5: Creating config.yml..."
LOCAL_PORT="${LOCAL_PORT:-3000}"
SUBDOMAIN="${SUBDOMAIN:-@}"

cat > "$CONFIG_DIR/config.yml" << EOF
tunnel: $TUNNEL_ID
credentials-file: $SCRIPT_DIR/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN
    service: http://localhost:$LOCAL_PORT
  - hostname: www.$DOMAIN
    service: http://localhost:$LOCAL_PORT
  - service: http_status:404
EOF

cat > "$SCRIPT_DIR/.env.template" << EOF
CLOUDFLARE_TUNNEL_ID=$TUNNEL_ID
DOMAIN=$DOMAIN
LOCAL_PORT=$LOCAL_PORT
EOF

echo "  config.yml created"
echo "  .env.template created"

echo ""
echo "Step 6: Adding CNAME record via Cloudflare API..."
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    ZONE_ID=$(curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" | \
        grep -oP '(?<="id":")[a-f0-9]+(?=")' || echo "")
    
    if [ -n "$ZONE_ID" ]; then
        curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"type\":\"CNAME\",\"name\":\"$DOMAIN\",\"content\":\"$TUNNEL_ID.cfargotunnel.com\"}"
        echo "  CNAME record added: $DOMAIN -> $TUNNEL_ID.cfargotunnel.com"
    else
        echo "  Skipped (API token may lack permissions)"
    fi
fi

echo ""
echo "=============================================="
echo "  Provisioning Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. Copy .env.template to .env and configure"
echo "  2. Run: ./start-secure.sh"
echo "  3. Visit: https://$DOMAIN"
echo ""