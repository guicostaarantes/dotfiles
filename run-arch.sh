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
	( cd $TMPDIR/yay-bin && makepkg -si --noconfirm )
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
	pavucontrol \
	xdg-desktop-portal-hyprland
# Development
yay -S --noconfirm \
	zsh \
	alacritty \
	neovim \
	ripgrep \
	starship \
	zoxide \
	curl \
	less \
	ttf-iosevkaterm-nerd
# Useful apps
yay -S --noconfirm \
	htop \
	bitwarden \
	firefox \
	blender
echo "Done"

echo "Creating symlinks"
ln -s $SCRIPTDIR/neovim ~/.config/nvim
ln -s $SCRIPTDIR/alacritty/alacritty.toml ~/.alacritty.toml
ln -s $SCRIPTDIR/zsh/zshrc-arch ~/.zshrc
ln -s $SCRIPTDIR/hypr ~/.config/hypr
echo "Done"
