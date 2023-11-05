#!/bin/bash
set -e

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

# Development packages
brew install 
	zsh \
	kitty \
	neovim \
	ripgrep \
	starship \
	zoxide \
	curl \
	less

# Symlinks
./create_symlink.sh $SCRIPTDIR/git/gitconfig ~/.gitconfig
./create_symlink.sh $SCRIPTDIR/neovim ~/.config/nvim
./create_symlink.sh $SCRIPTDIR/kitty ~/.config/kitty
./create_symlink.sh $SCRIPTDIR/zsh/zshrc-macos ~/.zshrc
