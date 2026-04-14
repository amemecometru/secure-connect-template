# Secure Connect - Client Handoff Document

## What Is This?

Secure Connect exposes your local development server to the world with instant HTTPS - no firewall configuration, no port forwarding, no complex networking required.

## How It Works

```
Your Computer → Cloudflare Tunnel → Your Domain (HTTPS)
     (localhost:3000)                           (https://yourdomain.com)
```

1. **Local Service**: Your app runs on `localhost:3000`
2. **Tunnel**: `cloudflared` creates a secure tunnel to Cloudflare's edge network
3. **DNS**: Requests to your domain route through Cloudflare to your local machine
4. **SSL**: Cloudflare terminates SSL - you get free HTTPS automatically

## Why This Beats Traditional Methods

| Traditional Port Forwarding | Secure Connect |
|---------------------------|----------------|
| Requires router/firewall config | No router changes |
| No SSL without extra setup | Instant HTTPS |
| IP changes on reconnect | Static URL always works |
| Only works on same network | Accessible from anywhere |
| Complex for non-technical users | One command to start |

## Quick Start

### Prerequisites

1. **Domain**: You own a domain in Cloudflare
2. **API Token**: Create a Cloudflare API token with:
   - `_zone:dns:edit` permissions
   - `_zone:zone:read` permissions

### Setup

```bash
# 1. Clone or navigate to secure-connect
cd secure-connect

# 2. Copy environment template
cp .env.template .env
# Edit .env with your values:
#   CLOUDFLARE_API_TOKEN=your_token
#   DOMAIN=yourdomain.com
#   LOCAL_PORT=3000

# 3. Run provisioning (first time only)
./provision-tunnel.sh

# 4. Start the tunnel
./start-secure.sh
```

### First-Time Setup

Run `./provision-tunnel.sh` which will:
1. Install `cloudflared` (if needed)
2. Authenticate with Cloudflare
3. Create a named tunnel
4. Generate `config.yml`
5. Add CNAME DNS record automatically

### Starting Your Secure Site

```bash
./start-secure.sh
```

Your site will be live at:
- `https://yourdomain.com`
- `https://www.yourdomain.com`

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token | Required |
| `CLOUDFLARE_TUNNEL_TOKEN` | Tunnel-specific token | Optional |
| `DOMAIN` | Your domain | Required |
| `LOCAL_PORT` | Local service port | 3000 |
| `SERVICE_CMD` | Command to start your service | `npm run dev` |

## Troubleshooting

### Tunnel Won't Start

```bash
# Check tunnel is listed
cloudflared tunnel list

# Check config syntax
cloudflared tunnel --config config.yml validate
```

### DNS Not Resolving

```bash
# Verify CNAME in Cloudflare dashboard
# Should point to: <tunnel-id>.cfargotunnel.com
```

### Port Already in Use

```bash
# Check what's using the port
lsof -i :3000

# Change port in .env: LOCAL_PORT=3001
```

### SSL Certificate Issues

Cloudflare provides free SSL. Ensure in Cloudflare dashboard:
- **SSL/TLS**: Full (strict)
- **Always Use HTTPS**: On

## Security Notes

- **Data in transit**: Encrypted via Cloudflare edge
- **Origin verification**: Optional to verify requests come through Cloudflare
- **No exposed ports**: Your machine never directly accessible from internet

## Stopping the Tunnel

```bash
# Ctrl+C to stop
# Or find and kill:
pkill -f cloudflared
```

## Purchase

### Basic Plan - $69 (one-time)
- Provisioning script
- Configuration templates
- Setup guide (this document)

[**Purchase Basic**](https://buy.stripe.com/your-basic-link)

### Pro Plan - $199 (one-time)
- Everything in Basic
- Custom styling/branding
- Multiple tunnel configurations
- Priority setup support

[**Purchase Pro**](https://buy.stripe.com/your-pro-link)

---

## Support

- Cloudflare Tunnel Docs: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps
- LogiclemonAI: https://www.logiclemonai.com

---

*Powered by LogiclemonAI - AI Development & Integration Services*