#!/bin/bash
set -e

DOMAIN="${domain}"
EMAIL="${email}"
OPENAI_API_KEY="${openai_api_key}"
WEBROOT="/var/www/openwebui"

# --- Basic packages ---
apt-get update -y
apt-get install -y nginx certbot python3-certbot-nginx curl

# Install Docker (docker + docker compose v2)
curl -fsSL https://get.docker.com | sh

systemctl enable docker
systemctl start docker
systemctl enable nginx
systemctl start nginx

# --- Webroot for ACME challenges ---
mkdir -p "$${WEBROOT}"
chown www-data:www-data "$${WEBROOT}"

########################################
# 1) HTTP-only nginx config (no SSL yet)
########################################
cat >/etc/nginx/sites-available/openwebui <<EOF
server {
    listen 80;
    server_name $${DOMAIN};

    root $${WEBROOT};

    location /.well-known/acme-challenge/ {
        alias $${WEBROOT}/.well-known/acme-challenge/;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF

ln -sf /etc/nginx/sites-available/openwebui /etc/nginx/sites-enabled/openwebui
rm -f /etc/nginx/sites-enabled/default || true

nginx -t
systemctl reload nginx

########################################
# 2) Obtain Let's Encrypt certificate
########################################
certbot certonly \
  --webroot -w "$${WEBROOT}" \
  -d "$${DOMAIN}" \
  --email "$${EMAIL}" \
  --agree-tos \
  --non-interactive || echo "Initial certbot run failed, will retry via renew timer."

########################################
# 3) Full HTTP + HTTPS nginx config
########################################
cat >/etc/nginx/sites-available/openwebui <<EOF
# WebSocket upgrade mapping
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 80;
    server_name $${DOMAIN};

    root $${WEBROOT};

    location /.well-known/acme-challenge/ {
        alias $${WEBROOT}/.well-known/acme-challenge/;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $${DOMAIN};

    ssl_certificate     /etc/letsencrypt/live/$${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$${DOMAIN}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    root $${WEBROOT};
    client_max_body_size 50m;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host              \$host;
        proxy_set_header X-Real-IP         \$remote_addr;
        proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade           \$http_upgrade;
        proxy_set_header Connection        \$connection_upgrade;
    }
}
EOF

nginx -t
systemctl reload nginx

# --- systemd service + timer for certbot renew ---
cat >/etc/systemd/system/certbot-renew.service <<EOF
[Unit]
Description=Renew Let's Encrypt certificates

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet
ExecStartPost=/bin/systemctl reload nginx
EOF

cat >/etc/systemd/system/certbot-renew.timer <<EOF
[Unit]
Description=Run certbot renew twice daily

[Timer]
OnCalendar=*-*-* 03,15:00:00
Persistent=true
Unit=certbot-renew.service

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now certbot-renew.timer

# --- Run Open WebUI container ---
docker run -d \
  -p 127.0.0.1:3000:8080 \
  -e OPENAI_API_KEY="$${OPENAI_API_KEY}" \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:v0.6.40-slim
