#!/bin/bash

ALERT="/usr/local/bin/alert.sh"
STATE="/var/lib/homelab-alerts/trivy.state"
TMP="/tmp/trivy.json"

mkdir -p /var/lib/homelab-alerts

# Se trivy não existir, sair silenciosamente
command -v trivy >/dev/null 2>&1 || exit 0

# Rodar scan apenas HIGH e CRITICAL
trivy fs / \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --format json \
  --quiet \
  --output "$TMP"

# Se arquivo vazio ou inexistente, sair
[ -s "$TMP" ] || exit 0

# Extrair CVEs relevantes
CVES=$(jq -r '
  .Results[].Vulnerabilities[]? |
  select(.Severity=="HIGH" or .Severity=="CRITICAL") |
  "\(.VulnerabilityID) (\(.Severity)) - \(.PkgName)"
' "$TMP" | sort -u)

# Se não achou nada, sair
[ -z "$CVES" ] && exit 0

# Evitar alerta repetido
if [ -f "$STATE" ] && diff -q <(echo "$CVES") "$STATE" >/dev/null; then
  exit 0
fi

MSG=$(printf "CVEs detectadas (HIGH/CRITICAL):\n\n%s" "$CVES")

"$ALERT" crit \
  "Vulnerabilidades detectadas (Trivy)" \
  "$MSG"

# Salvar estado atual
echo "$CVES" > "$STATE"