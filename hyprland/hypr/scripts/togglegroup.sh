if [[ $(hyprctl activewindow -j | jq -r .grouped) == "[]" ]]
then
	hyprctl dispatch togglegroup
else
	hyprctl dispatch moveoutofgroup
fi
