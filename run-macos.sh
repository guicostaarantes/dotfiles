#!/bin/bash
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
DATE=$(date '+%Y-%m-%d-%H:%M:%S')

echo "Backup"
mv ~/.config ~/.config-bkp-$DATE
mkdir ~/.config
mv ~/.alacritty.yml ~/.alacritty-bkp-$DATE.yml
mv ~/.tmux.conf ~/.tmux-bkp-$DATE.conf
echo "Done"

echo "Creating symlink for neovim"
ln -s $SCRIPTDIR/neovim ~/.config/nvim
echo "Done"

echo "Creating symlink for alacritty"
ln -s $SCRIPTDIR/alacritty/alacritty.yml ~/.alacritty.yml
echo "Done"

echo "Creating symlink for fish"
ln -s $SCRIPTDIR/fish ~/.config/fish
echo "Done"

echo "Creating symlink for tmux"
ln -s $SCRIPTDIR/tmux/tmux.conf ~/.tmux.conf
echo "Done"
