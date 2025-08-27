#!/bin/bash

entries="Lock\nReboot\nShutdown"

selected=$(echo -e $entries | fuzzel --dmenu)

case $selected in
  Lock)
    swaylock -f -c 000000;;
  Reboot)
    shutdown -r now;;
  Shutdown)
    shutdown -P now;;
esac
