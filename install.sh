#!/bin/bash
set -e

BIN="/usr/local/bin"
CONF="/etc/homelab-alerts"

echo "➡ Instalando homelab-alerts..."

# NÃO criar / modificar $CONF
# Ele pode ser um bind mount read-only

install -m 755 alert.sh "$BIN/alert.sh"
install -m 755 check-updates.sh "$BIN/check-updates.sh"
install -m 644 cron/check-updates /etc/cron.d/check-updates

echo "✔ Scripts e cron instalados"
echo "ℹ Secrets esperados em $CONF/telegram.env"