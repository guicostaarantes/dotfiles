#!/bin/bash
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

echo "Installing/updating packages with brew"
# Development
brew install 
	zsh \
	alacritty \
	neovim \
	ripgrep \
	starship \
	zoxide \
	curl \
	less
echo "Done"

echo "Creating symlinks"
ln -s $SCRIPTDIR/git/gitconfig ~/.gitconfig
ln -s $SCRIPTDIR/neovim ~/.config/nvim
ln -s $SCRIPTDIR/alacritty/alacritty.toml ~/.alacritty.toml
ln -s $SCRIPTDIR/zsh/zshrc-macos ~/.zshrc
echo "Done"
