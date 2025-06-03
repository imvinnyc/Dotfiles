#!/usr/bin/env bash
set -euo pipefail

BASE="$(cd "$(dirname "$0")/.." && pwd)"
DCONF="$BASE/gnome/gnome-dconf.ini"
EXTLIST="$BASE/gnome/extensions.txt"
EXTDIR="$BASE/gnome/extensions"

echo "⏳ Loading dconf settings …"
dconf load / < "$DCONF"

echo "⏳ Installing local extensions …"
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
cp -r "$EXTDIR"/* "$HOME/.local/share/gnome-shell/extensions" 2>/dev/null || true

echo "⏳ Enabling extensions …"
while read -r uuid; do
  gnome-extensions enable "$uuid" || echo "⚠️  $uuid not found"
done < "$EXTLIST"
gsettings set org.gnome.shell.extensions.dash-to-panel show-appmenu-button false

echo "⏳ Rebuilding font cache …"
fc-cache -fv

echo "✅  Done!  Press Alt+F2 → r or log out/in."
