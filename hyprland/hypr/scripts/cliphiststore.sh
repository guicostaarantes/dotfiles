if [[ $(hyprctl activewindow -j | jq -r .class) == "Bitwarden" ]]
then
	echo "Skipping"
else
	cliphist store
fi
