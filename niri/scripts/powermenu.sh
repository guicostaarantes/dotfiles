#!/bin/bash

entries="Lock\nReboot\nShutdown"

selected=$(echo -e $entries | fuzzel --dmenu)

case $selected in
  Lock)
    swaylock -f -i .config/niri/wallpapers/wallhaven-5g22q5.png;;
  Reboot)
    shutdown -r now;;
  Shutdown)
    shutdown -P now;;
esac
