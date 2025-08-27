#!/bin/bash
set -e

log() {
	echo -e "\e[1;32m[INFO]\e[0m $1"
}
error() {
	echo -e "\e[1;31m[ERROR]\e[0m $1"
}

SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

if [ "$EUID" -eq 0 ]; then
	error "Do not run this script as root."
	exit 1
fi

if ![[ command -v paru &>/dev/null ]]; then
	log "Installing paru"
	sudo pacman -S --needed --noconfirm git base-devel
	BUILD_DIR="/tmp/paru-install"
	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"
	git clone https://aur.archlinux.org/paru-bin.git "$BUILD_DIR"
	cd "$BUILD_DIR"
	makepkg -si --noconfirm
	rm -rf "$BUILD_DIR"
	log "Done installing paru"
fi

log "Installing packages for terminal"
paru -Sy \
	kitty \
	neovim \
	starship \
	ttf-iosevka-term \
	zoxide \
	zsh \
	zsh-autosuggestions
log "Finished installing packages for terminal"

log "Installing niri applications"
log "Done installing niri applications"

log "Installing GUI applications"
paru -Sy \
	bitwarden \
	brave-bin \
	steam
log "Done installing GUI applications"

log "Creating symlinks"
ln -s $SCRIPTDIR/git/gitconfig ~/.gitconfig
ln -s $SCRIPTDIR/kitty ~/.config/kitty
ln -s $SCRIPTDIR/niri ~/.config/niri
ln -s $SCRIPTDIR/nvim ~/.config/nvim
ln -s $SCRIPTDIR/xcompose/ptbr ~/.XCompose
ln -s $SCRIPTDIR/zsh/zshrc-linux ~/.zshrc
log "Finished creating symlinks"
