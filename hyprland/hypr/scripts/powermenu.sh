#!/bin/bash

entries="Lock\nReboot\nShutdown"

selected=$(echo -e $entries | wofi -W 300 -H 160 -n -i -k /dev/null -S dmenu)

case $selected in
  Lock)
    swaylock -f -c 000000;;
  Reboot)
    reboot;;
  Shutdown)
    poweroff -i;;
esac
