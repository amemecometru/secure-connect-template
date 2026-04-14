# Secure Connect

Expose your local development server to the world with instant HTTPS - no firewall configuration, no port forwarding, no complex networking.

## What It Does

- Creates a Cloudflare Tunnel connecting your local port to your domain
- Provides free automatic SSL/HTTPS via Cloudflare
- One-command startup with zero router/firewall changes

## Quick Start

```bash
# Clone this template
git clone https://github.com/logiclemonai/secure-connect.git
cd secure-connect

# Run provisioning
./provision-tunnel.sh

# Start secure tunnel
./start-secure.sh
```

## Requirements

- [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/install-cloudflared) installed
- Domain registered in Cloudflare
- Cloudflare API token with DNS and Zone permissions

## Pricing

| Plan | Price | Features |
|------|-------|----------|
| Basic | $69 one-time | Script + config + setup guide |
| Pro | $199 one-time | Basic + custom styling + multiple tunnels |

[**Purchase Basic ($69)**](https://buy.stripe.com/test_14A14mfFx67E5HGbhv77O00) &nbsp;|&nbsp; [**Purchase Pro ($199)**](https://buy.stripe.com/test_6oUaEW0KD0Nkc64fxL77O01)

## Included Files

- `provision-tunnel.sh` - Automated tunnel provisioning
- `start-secure.sh` - Local service + tunnel wrapper
- `config.yml.example` - Tunnel configuration template
- `HANDOFF.md` - Full setup documentation

---

*Powered by LogiclemonAI*