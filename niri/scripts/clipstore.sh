#!/bin/bash

if [[ -t 0 ]] then
	notify-send "Skipping"
elif [[ $(niri msg -j focused-window | jq -r .title) == "Bitwarden" ]] then
	notify-send "Skipping"
else
	notify-send "Added to clipboard"
	cliphist store
fi
