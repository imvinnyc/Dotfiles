#!/usr/bin/env bash
set -euo pipefail

DCONF="$HOME/gnome/dconf.ini"
EXTLIST="$HOME/gnome/extensions.txt"
EXTDIR="$HOME/gnome/extensions"

echo "Loading dconf settings…"
dconf load / < "$DCONF"

echo "Installing local extensions…"
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
cp -r "$EXTDIR"/* "$HOME/.local/share/gnome-shell/extensions" 2>/dev/null || true

echo "Enabling extensions…"
while read -r uuid; do
  gnome-extensions enable "$uuid" || echo "$uuid not found"
done < "$EXTLIST"

echo "Rebuilding font cache…"
fc-cache -fv

echo "Done!  Press Alt+F2 → r or log out/in."
