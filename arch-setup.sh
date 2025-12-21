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

# Set up audio, bluetooth and network tools
yay -Sy --needed --noconfirm \
	extra/bluetui \
	extra/bluez \
	extra/bluez-utils \
	extra/nethogs \
	extra/pipewire \
	extra/pipewire-pulse \
	extra/wiremix \
	extra/wireplumber
sudo systemctl enable bluetooth
systemctl --user enable pipewire
systemctl --user enable pipewire-pulse
systemctl --user enable wireplumber

# Set up desktop environment
yay -Sy --needed --noconfirm \
	extra/polkit-gnome \
	extra/xdg-desktop-portal-gnome \
	extra/xdg-desktop-portal-gtk
yay -Sy --needed --noconfirm \
	extra/bitwarden \
	extra/brightnessctl \
	extra/cliphist \
	extra/fuse2 \
	extra/fuzzel \
	extra/ibus \
	aur/ibus-uniemoji \
	extra/jq \
	extra/kitty \
	extra/ly \
	extra/mako \
	extra/nautilus \
	extra/niri \
	extra/noto-fonts-emoji \
	extra/swaybg \
	extra/swayidle \
	extra/swaylock \
	extra/vivaldi \
	extra/waybar \
	extra/wl-clipboard \
	aur/wljoywake \
	extra/xwayland-satellite
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service

# Set up terminal environment
yay -Sy --needed --noconfirm \
	extra/btop \
	extra/fastfetch \
	extra/git \
	core/less \
	extra/neovim \
	extra/ripgrep \
	extra/starship \
	extra/ttf-iosevka-nerd \
	extra/zoxide \
	extra/zsh \
	extra/zsh-autosuggestions
sudo chsh -s /bin/zsh $(whoami)

# Set up work packages
yay -Sy --needed --noconfirm \
	aur/android-sdk-cmdline-tools-latest \
	extra/jdk17-openjdk \
	extra/lua-language-server \
	extra/mkcert \
	extra/nvm \
	extra/pyenv \
	extra/qemu-full \
	extra/rustup \
	extra/traefik \
	extra/typescript-language-server \
	extra/virt-manager \
	extra/vscode-json-languageserver
sudo systemctl enable libvirtd.socket
sudo usermod -aG libvirt-qemu $(whoami)

# Set up other packages
yay -Sy --needed --noconfirm \
	aur/alvr-bin \
	extra/android-tools \
	extra/blender \
	aur/bottles \
	extra/distrobox \
	extra/gamemode \
	extra/gamescope \
	extra/gimp \
	extra/inkscape \
	extra/libreoffice-still \
	extra/mangohud \
	extra/podman \
	extra/obs-studio \
	extra/qbittorrent \
	multilib/steam \
	aur/vesktop-bin \
	aur/vial-appimage \
	extra/vlc \
	extra/vlc-plugins-all

# Symlinks
./dotfiles-symlinks.sh
