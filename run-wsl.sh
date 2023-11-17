#!/bin/bash
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
DATE=$(date '+%Y-%m-%d-%H:%M:%S')

echo "Backup"
mv ~/.config ~/.config-bkp-$DATE
mkdir ~/.config
echo "Done"

echo "Creating symlink for neovim"
ln -s $SCRIPTDIR/neovim ~/.config/nvim
echo "Done"

echo "Creating symlink for zsh"
ln -s $SCRIPTDIR/zsh/zshrc ~/.zshrc
echo "Done"

echo "Creating symlink for tmux"
ln -s $SCRIPTDIR/tmux/tmux.conf ~/.tmux.conf
echo "Done"
