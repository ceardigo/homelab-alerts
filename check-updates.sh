#!/bin/bash

UPDATES=$(apt list --upgradable 2>/dev/null | grep -v "Listing")

[ -z "$UPDATES" ] && exit 0

/usr/local/bin/alert.sh warn \
  "Atualizações pendentes" \
  "$UPDATES"