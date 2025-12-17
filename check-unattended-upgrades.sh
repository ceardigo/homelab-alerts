#!/bin/bash

LOG="/var/log/unattended-upgrades/unattended-upgrades.log"
STATE="/var/lib/homelab-alerts/unattended.last"
ALERT="/usr/local/bin/alert.sh"

mkdir -p /var/lib/homelab-alerts

# Se log não existir, sair
[ -f "$LOG" ] || exit 0

# Pegar última execução
LAST_RUN=$(grep "Starting unattended upgrades script" "$LOG" | tail -1 | cut -d' ' -f1,2)
[ -z "$LAST_RUN" ] && exit 0

# Se já alertou essa execução, sair
if [ -f "$STATE" ] && grep -q "$LAST_RUN" "$STATE"; then
  exit 0
fi

# Detectar se houve upgrades
if grep -q "All upgrades installed" "$LOG"; then
  RESULT="Atualizações de segurança aplicadas com sucesso."
else
  RESULT="Execução concluída (verificar logs se necessário)."
fi

MSG=$(printf "%s\n\nExecução: %s" "$RESULT" "$LAST_RUN")

"$ALERT" info \
  "unattended-upgrades executado" \
  "$MSG"

# Salvar estado
echo "$LAST_RUN" > "$STATE"