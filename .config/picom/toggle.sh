#!/usr/bin/env bash
# Toggle between fading or sliding window animations

PICOM=$(command -v picom)
DIR="$HOME/.config/picom"
CFG_A="$DIR/picom.conf"
CFG_B="$DIR/picom1.conf"

# Figure out which config picom is currently using
current_cfg=$(
  pgrep -xa picom |
  sed -nE 's|.*--config[ =]([^ ]+).*|\1|p' |
  head -n1
)

# Pick the *other* config
if [[ $current_cfg == "$CFG_A" ]]; then
  next_cfg=$CFG_B
else
  next_cfg=$CFG_A
fi

# Restart picom with the chosen config
pkill -x picom
sleep 0.2
$PICOM --config "$next_cfg" & disown
