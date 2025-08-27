#!/bin/bash

# Prefer showing names
# app=$(grep -i 'Name=' /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop | cut -d '=' -f2 | fzf)
# exec_command=$(grep -i "Name=$app" /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop | cut -d ':' -f1 | xargs -I {} grep -i 'Exec=' {} | cut -d '=' -f2-)

# Find all .desktop entries and let user select one using fzf
entry_path=$(find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null \
  | fzf --prompt="Launch app: " --preview-window=down:1:wrap)

# Exit if no selection
if [[ -n "$entry_path" ]] then

  # Extract the Exec line
  exec_cmd=$(grep -E '^Exec=' "$entry_path" | head -n1 | cut -d= -f2-)

  # Replace desktop entry field codes like %U, %u, %F, %f with empty strings
  # These are placeholders for URLs, files, etc.
  exec_cmd=$(echo "$exec_cmd" | sed -E 's/ *%[fFuUdDnNickvm]//g')

  # Launch the command detached from the terminal
  is_term=$(grep -E '^Terminal=' "$entry_path" | head -n1 | cut -d= -f2-)
  if [[ $is_term == "true" ]]; then
    nohup kitty -e "$exec_cmd" >/dev/null 2>&1 &
  else
    nohup bash -c "$exec_cmd" >/dev/null 2>&1 &
  fi

fi

# Close the terminal that is running the current script
parent_pid=$(ps -o ppid= -p $$ | tr -d ' ')
kill $parent_pid
