#!/bin/bash

entries="⏾ Logout\n⭮ Reboot\n⏻ Shutdown"

selected=$(echo -e $entries | wofi -W 250 -H 210 -n -i -k /dev/null -S dmenu | awk '{print tolower($2)}')

case $selected in
  logout)
    swaylock -c 000000;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
