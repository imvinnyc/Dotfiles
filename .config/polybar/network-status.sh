#!/usr/bin/env bash

info=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status | grep ':connected:' | head -n1)

if [[ -n $info ]]; then
  IFS=':' read -r _dev type _state conn <<< "$info"

  if [[ $type == wifi ]]; then
    printf '  %s\n' "$conn"
  else
    printf '󰈁 Connected\n'
  fi
else
  printf '  Offline\n'
fi
