#!/bin/bash

# Create a temporary file to store stdin
tempfile=$(mktemp)

# Read stdin into the temporary file
# Use `cat` to preserve binary data
cat > "$tempfile"

# Check if the file is empty
if [ ! -s "$tempfile" ]; then
	notify-send "Clipboard cleared"
elif [[ $(niri msg -j focused-window | jq -r .title) == "Bitwarden" ]] then
	notify-send "Added to clipboard" "Content was NOT added to clipboard history"
else
	notify-send "Added to clipboard" "Content was recorded in clipboard history"
	cat "$tempfile" | cliphist store
fi

# Clean up
rm -f "$tempfile"
