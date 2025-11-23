#!/bin/bash
set -e

DOMAIN="${domain}"
EMAIL="${email}"
DB_PASS="${db_pass}"
WEBROOT="/var/www/n8n"
APP_DIR="/opt/n8n"

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
cat >/etc/nginx/sites-available/n8n <<EOF
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

ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/n8n
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
cat >/etc/nginx/sites-available/n8n <<EOF
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
        proxy_pass http://127.0.0.1:5678;
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

# --- docker-compose stack for n8n + Postgres ---
mkdir -p "$${APP_DIR}"

cat >"$${APP_DIR}/docker-compose.yml" <<EOF
version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: n8n
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: $${DB_PASS}
    volumes:
      - n8n-db:/var/lib/postgresql/data

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    depends_on:
      - postgres
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: n8n
      DB_POSTGRESDB_USER: n8n
      DB_POSTGRESDB_PASSWORD: $${DB_PASS}

      N8N_PORT: 5678
      N8N_PROTOCOL: https
      N8N_HOST: $${DOMAIN}
      WEBHOOK_URL: https://$${DOMAIN}/
      N8N_EDITOR_BASE_URL: https://$${DOMAIN}/

    volumes:
      - n8n-data:/home/node/.n8n

volumes:
  n8n-db:
  n8n-data:
EOF

cd "$${APP_DIR}"
docker compose pull
docker compose up -d
