#!/bin/bash

SECRETS="/etc/homelab-alerts/secrets.env"

# Carregar segredos (POSIX-safe)
[ -f "$SECRETS" ] || exit 0
. "$SECRETS"

HOST="$(hostname)"
LEVEL="${1:-info}"
TITLE="$2"
BODY="$3"

EMOJI="ℹ️"
[ "$LEVEL" = "warn" ] && EMOJI="⚠️"
[ "$LEVEL" = "crit" ] && EMOJI="🚨"

# Montar mensagem com quebras reais
TEXT=$(printf "*%s [%s]*\n*%s*\n\n%s" \
  "$EMOJI" "$HOST" "$TITLE" "$BODY")

# Escapar SOMENTE underscore (Markdown v1)
TEXT=$(echo "$TEXT" | sed 's/_/\\_/g')

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d parse_mode="Markdown" \
  --data-urlencode text="$TEXT" \
  >/dev/null