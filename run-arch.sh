#!/bin/bash
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
TMPDIR="$SCRIPTDIR"/tmp

echo "Installing yay"
if [ -f "/sbin/yay" ]; then
	echo "Yay already installed"
else
	sudo pacman -S --needed git base-devel
	git clone https://aur.archlinux.org/yay-bin.git $TMPDIR/yay-bin
	( cd $TMPDIR/yay-bin && makepkg -si )
	rm $TMPDIR/yay-bin
fi
echo "Done"

echo "Installing/updating packages with yay"
# Desktop environment
yay -S --noconfirm \
	hyprland \
	waybar \
	wofi \
	mako \
	thunar \
	polkit-gnome \
	xdg-desktop-portal-hyprland
# Development
yay -S --noconfirm \
	zsh \
	alacritty \
	neovim \
	ripgrep \
	starship \
	zoxide \
	ttf-iosevkaterm-nerd
# Useful apps
yay -S --noconfirm \
	brave-bin \
	firefox \
	blender
echo "Done"

echo "Creating symlinks for neovim"
ln -s $SCRIPTDIR/neovim ~/.config/nvim
ln -s $SCRIPTDIR/alacritty/alacritty.toml ~/.alacritty.toml
ln -s $SCRIPTDIR/zsh/zshrc ~/.zshrc
ln -s $SCRIPTDIR/hypr ~/.config/hypr
echo "Done"
