#!/bin/bash

ALERT="/usr/local/bin/alert.sh"
CONF_DIR="/etc/homelab-alerts/apps.d"
STATE="/var/lib/homelab-alerts/apps.state"

mkdir -p /var/lib/homelab-alerts
touch "$STATE"

# Loop em todos os apps configurados
for CONF in "$CONF_DIR"/*.conf; do
  [ -f "$CONF" ] || continue

  while IFS="|" read -r NAME CHECK_CMD CURRENT_CMD LATEST_CMD; do
    # Ignorar linhas vazias ou comentadas
    [[ -z "$NAME" || "$NAME" =~ ^# ]] && continue

    # Verificar se o app existe nessa LXC
    eval "$CHECK_CMD" >/dev/null 2>&1 || continue

    # Obter versão atual e upstream
    CURRENT=$(eval "$CURRENT_CMD" 2>/dev/null)
    LATEST=$(eval "$LATEST_CMD" 2>/dev/null)

    # Se falhou, pular
    [ -z "$CURRENT" ] || [ -z "$LATEST" ] && continue

    # Se já alertou essa versão, pular
    if grep -q "^$NAME:$LATEST$" "$STATE"; then
      continue
    fi

    # Se versão diferente, alertar
    if [ "$CURRENT" != "$LATEST" ]; then
      MSG=$(printf "Nova versão disponível\n\nAtual: %s\nNova: %s" "$CURRENT" "$LATEST")

      "$ALERT" info \
        "Atualização disponível: $NAME" \
        "$MSG"

      # Atualizar estado
      grep -v "^$NAME:" "$STATE" > "$STATE.tmp"
      echo "$NAME:$LATEST" >> "$STATE.tmp"
      mv "$STATE.tmp" "$STATE"
    fi

  done < "$CONF"
done