#!/bin/bash

SECRETS="/etc/homelab-alerts/secrets.env"

# Carregar segredos
[ -f "$SECRETS" ] || exit 0
source "$SECRETS"

HOST="$(hostname)"
LEVEL="${1:-info}"
TITLE="$2"
BODY="$3"

EMOJI="ℹ️"
[ "$LEVEL" = "warn" ] && EMOJI="⚠️"
[ "$LEVEL" = "crit" ] && EMOJI="🚨"

TEXT="*${EMOJI} [$HOST]*\n*${TITLE}*\n\n${BODY}"

# Escape Markdown
TEXT=$(echo "$TEXT" | sed 's/_/\\_/g; s/*/\\*/g; s/\[/\\[/g')

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d parse_mode="Markdown" \
  --data-urlencode text="$TEXT" \
  >/dev/null