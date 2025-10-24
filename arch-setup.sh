#!/bin/bash
set -e

if [ "$EUID" -eq 0 ]; then
	error "Do not run this script as root."
	exit 1
fi

# Enable multilib repository for 32-bit libraries
sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf

# Install yay
if ! command -v yay &>/dev/null; then
	sudo pacman -Sy --needed --noconfirm git base-devel
	BUILD_DIR="/tmp/yay-install"
	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"
	git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR"
	cd "$BUILD_DIR"
	makepkg -si --noconfirm
	rm -rf "$BUILD_DIR"
fi

# Set up firewall
yay -Sy --needed --noconfirm ufw
sudo ufw enable
sudo ufw default allow outgoing
sudo ufw default deny incoming

# Set up audio and bluetooth
yay -Sy --needed --noconfirm \
	bluetuith-bin \
	bluez \
	bluez-utils \
	pipewire \
	pipewire-pulse \
	wiremix \
	wireplumber
sudo systemctl enable bluetooth
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber

# Set up desktop environment
yay -Sy --needed --noconfirm \
	bitwarden \
	cliphist \
	firefox \
	fuse \
	fuzzel \
	ibus \
	jq \
	kitty \
	ly \
	mako \
	nautilus \
	niri \
	noto-fonts-emoji \
	polkit-gnome \
	swaybg \
	swayidle \
	swaylock \
	waybar \
	wl-clipboard \
	wljoywake \
	xwayland-satellite
sudo systemctl enable ly

# Set up terminal environment
yay -Sy --needed --noconfirm \
	btop \
	git \
	less \
	neovim \
	ripgrep \
	starship \
	ttf-iosevka-nerd \
	zoxide \
	zsh \
	zsh-autosuggestions
sudo chsh -s /bin/zsh $(whoami)

# Set up work packages
yay -Sy --needed --noconfirm \
	android-sdk-cmdline-tools-latest \
	jdk17-openjdk \
	lua-language-server \
	mkcert \
	nvm \
	pyenv \
	qemu-full \
	rustup \
	traefik \
	typescript-language-server \
	virt-manager \
	vscode-json-languageserver
sudo systemctl enable libvirtd.socket
sudo usermod -aG libvirt-qemu $(whoami)

# Set up other packages
yay -Sy --needed --noconfirm \
	alvr-launcher-bin \
	bottles \
	distrobox \
	inkscape \
	libreoffice-still \
	podman \
	qbittorrent \
	steam \
	vesktop-bin

# Symlinks
./dotfiles-symlinks.sh
