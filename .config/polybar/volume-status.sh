#!/usr/bin/env bash

# Grab Master mixer state once
mixer=$(amixer get Master)

if grep -q '\[off\]' <<< "$mixer"; then
  # Muted  -  show muted-speaker icon + text
  printf ' Muted\n'
else
  # Not muted  -  extract first percentage number
  vol=$(grep -o '[0-9]\{1,3\}%' <<< "$mixer" | head -n1)
  printf ' %s\n' "$vol"
fi
