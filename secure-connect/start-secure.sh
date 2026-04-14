#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.yml"

echo "=============================================="
echo "  Secure Connect - Local HTTPS Tunnel"
echo "=============================================="
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: config.yml not found"
    echo ""
    echo "Run provision-tunnel.sh first to set up your tunnel"
    exit 1
fi

if command -v cloudflared &> /dev/null; then
    echo "cloudflared found"
else
    echo "Installing cloudflared..."
    if [ "$(uname)" = "Darwin" ]; then
        brew install cloudflared
    elif [ "$(uname)" = "Linux" ]; then
        curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
        chmod +x /tmp/cloudflared
        sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
    fi
fi

source "${SCRIPT_DIR}/.env" 2>/dev/null || true

LOCAL_PORT="${LOCAL_PORT:-3000}"
SERVICE_CMD="${SERVICE_CMD:-npm run dev}"

echo "Configuration:"
echo "  Domain:      ${DOMAIN:-Not configured}"
echo "  Tunnel ID:   ${CLOUDFLARE_TUNNEL_ID:-Not configured}"
echo "  Local Port:  $LOCAL_PORT"
echo ""

check_port() {
    if command -v lsof &> /dev/null; then
        lsof -i ":$LOCAL_PORT" > /dev/null 2>&1
    elif command -v ss &> /dev/null; then
        ss -tlnp | grep -q ":$LOCAL_PORT"
    fi
}

if ! check_port; then
    echo "Starting local service on port $LOCAL_PORT..."
    echo "  Command: $SERVICE_CMD"
    echo ""
    
    (cd "$SCRIPT_DIR/../.." && $SERVICE_CMD) &
    SERVICE_PID=$!
    sleep 3
    
    if ! kill -0 "$SERVICE_PID" 2>/dev/null; then
        echo "WARNING: Service may have failed to start"
    fi
fi

echo "Starting Cloudflare tunnel..."
cloudflared tunnel --config "$CONFIG_FILE" run

echo "Tunnel started: https://${DOMAIN:-your-domain.com}"