#!/bin/bash
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
DATE=$(date '+%Y-%m-%d-%H:%M:%S')

echo "Backup"
mv ~/.config ~/.config-bkp-$DATE
mkdir ~/.config
mv ~/.alacritty.yml ~/.alacritty-bkp-$DATE.yml
mv ~/.zshrc ~/.zshrc-bkp-$DATE.conf
echo "Done"

echo "Creating symlink for neovim"
ln -s $SCRIPTDIR/neovim ~/.config/nvim
echo "Done"

echo "Creating symlink for alacritty"
ln -s $SCRIPTDIR/alacritty/alacritty.yml ~/.alacritty.yml
echo "Done"

echo "Creating symlink for zsh"
ln -s $SCRIPTDIR/zsh/zshrc ~/.zshrc
echo "Done"
