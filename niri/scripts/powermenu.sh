#!/bin/bash

entries="Lock\nReboot\nShutdown"

selected=$(echo -e $entries | fzf)

case $selected in
  Lock)
    nohup swaylock -f -c 000000 &;;
  Reboot)
    shutdown -r now;;
  Shutdown)
    shutdown -P now;;
esac

# Close the terminal that is running the current script
sleep 1
parent_pid=$(ps -o ppid= -p $$ | tr -d ' ')
kill $parent_pid
