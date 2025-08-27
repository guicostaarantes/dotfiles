#!/bin/bash
set -e

target="$1"
link_name="$2"

if [ -L "$link_name" ]; then
	current_target=$(readlink "$link_name")
	if [ "$current_target" == "$target" ]; then
		echo "Symlink already correct: $link_name -> $target"
		exit 0
	else
		echo "Symlink exists but points to wrong target: $current_target"
		rm "$link_name"
	fi
elif [ -e "$link_name" ]; then
	echo "A file or directory (not a symlink) already exists at: $link_name"
	mv "$link_name" "$link_name.bkp"
fi

ln -s "$target" "$link_name" && echo "Created symlink: $link_name -> $target"
