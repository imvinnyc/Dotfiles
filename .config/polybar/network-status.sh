#!/bin/bash
if nmcli -t -f active,ssid dev wifi | grep -q "^yes"; then
    ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1 == "yes" {print $2}')
    echo " $ssid"
else
    echo "  Offline"
fi
