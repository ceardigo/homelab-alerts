#!/bin/bash

LOG="/var/log/unattended-upgrades/unattended-upgrades.log"
STATE="/var/lib/homelab-alerts/unattended.failure.alerted"
ALERT="/usr/local/bin/alert.sh"

mkdir -p /var/lib/homelab-alerts

[ -f "$LOG" ] || exit 0

# Pegar última execução
LAST_RUN=$(grep "Starting unattended upgrades script" "$LOG" | tail -1 | cut -d' ' -f1,2)
[ -z "$LAST_RUN" ] && exit 0

# Se já alertou para essa execução, sair
if [ -f "$STATE" ] && grep -q "$LAST_RUN" "$STATE"; then
  exit 0
fi

# Procurar erros desde a última execução
ERRORS=$(awk "/$LAST_RUN/,0" "$LOG" | grep -E "ERROR|Failed|dpkg exited|packages that were upgraded but failed" | head -20)

[ -z "$ERRORS" ] && exit 0

MSG=$(printf "Erros detectados:\n\n%s" "$ERRORS")

"$ALERT" crit \
  "Falha no unattended-upgrades" \
  "$MSG"

# Marcar estado
echo "$LAST_RUN" > "$STATE"