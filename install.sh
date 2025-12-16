#!/bin/bash
set -e

BIN="/usr/local/bin"
CONF="/etc/homelab-alerts"

echo "➡ Instalando homelab-alerts..."

install -d -m 700 "$CONF"

install -m 755 alert.sh "$BIN/alert.sh"
install -m 755 check-updates.sh "$BIN/check-updates.sh"
install -m 644 cron/check-updates /etc/cron.d/check-updates

echo "✔ Scripts instalados"
echo "⚠️ Garanta que $CONF/secrets.env exista (bind mount ou arquivo local)"