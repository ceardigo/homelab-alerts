#!/bin/bash

LOG="/var/log/unattended-upgrades/unattended-upgrades.log"
STATE="/var/lib/homelab-alerts/unattended.last"
ALERT="/usr/local/bin/alert.sh"

mkdir -p /var/lib/homelab-alerts

[ -f "$LOG" ] || exit 0

LAST_RUN=$(grep "Starting unattended upgrades script" "$LOG" | tail -1 | cut -d' ' -f1,2)
[ -z "$LAST_RUN" ] && exit 0

if [ -f "$STATE" ] && grep -q "$LAST_RUN" "$STATE"; then
  exit 0
fi

if grep -q "All upgrades installed" "$LOG"; then
  RESULT="Atualizações de segurança aplicadas com sucesso."
else
  RESULT="Execução concluída (verificar logs se necessário)."
fi

"$ALERT" info \
  "unattended-upgrades executado" \
  "$RESULT\n\nExecução: $LAST_RUN"

echo "$LAST_RUN" > "$STATE"