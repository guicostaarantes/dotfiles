#!/bin/bash
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

echo "Creating symlinks"
ln -s $SCRIPTDIR/git/gitconfig ~/.gitconfig
ln -s $SCRIPTDIR/neovim ~/.config/nvim
ln -s $SCRIPTDIR/xcompose ~/.XCompose
ln -s $SCRIPTDIR/zsh/zshrc-bazzite ~/.zshrc
echo "Done"
