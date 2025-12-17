#!/bin/bash

FLAG="/var/run/reboot-required"
STATE="/var/lib/homelab-alerts/reboot.alerted"
ALERT="/usr/local/bin/alert.sh"

mkdir -p /var/lib/homelab-alerts

# Se não precisa reboot, limpar estado e sair
if [ ! -f "$FLAG" ]; then
  rm -f "$STATE"
  exit 0
fi

# Se já alertou, não repetir
[ -f "$STATE" ] && exit 0

# Coletar pacotes (se existir)
PKGS=""
if [ -f /var/run/reboot-required.pkgs ]; then
  PKGS=$(cat /var/run/reboot-required.pkgs)
fi

MSG="Reboot necessário após atualizações."
[ -n "$PKGS" ] && MSG="$MSG\n\nPacotes:\n$PKGS"

"$ALERT" warn \
  "Reboot necessário" \
  "$MSG"

# Marcar que já alertou
touch "$STATE"