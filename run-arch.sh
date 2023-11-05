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

# Limine bootloader
yay -Sy --needed --noconfirm \
	limine \
	limine-mkinitcpio-hook \
	snapper \
	limine-snapper-sync
sudo limine-install
sudo systemctl enable limine-snapper-sync.service

# Set up firewall
sudo pacman -Sy --needed --noconfirm ufw
sudo ufw enable
sudo ufw default allow outgoing
sudo ufw default deny incoming

# Nvidia drivers and utils
sudo pacman -Sy --needed --noconfirm \
	linux-headers \
	nvidia-open-dkms \
	nvidia-utils \
	libva-nvidia-driver \
	egl-wayland \
	qt5-wayland \
	qt6-wayland
	
# Niri packages and settings
yay -Sy --needed --noconfirm \
	cliphist \
	fuzzel \
	ibus \
	jq \
	mako \
	ly \
	nautilus \
	niri \
	noto-fonts-emoji \
	polkit-gnome \
	swaybg \
	swayidle \
	swaylock \
	xwayland-satellite \
	waybar \
	wl-clipboard \
	wljoywake
sudo systemctl enable ly.service

# Terminal packages and settings
yay -Sy --needed --noconfirm \
	btop \
	fzf \
	kitty \
	neovim \
	ripgrep \
	starship \
	ttf-iosevka-nerd \
	zoxide \
	zsh \
	zsh-autosuggestions
sudo chsh -s /bin/zsh $(whoami)

# Misc packages
yay -Sy --needed --noconfirm \
	alvr-launcher-bin \
	android-tools \
	bitwarden \
	bluetuith-bin \
	bottles \
	brave-bin \
	distrobox \
	pavucontrol \
	podman \
	steam \
	vesktop-bin

# Symlinks
SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

./create_symlink.sh $SCRIPTDIR/fontconfig ~/.config/fontconfig
./create_symlink.sh $SCRIPTDIR/fuzzel ~/.config/fuzzel
./create_symlink.sh $SCRIPTDIR/git/gitconfig ~/.gitconfig
./create_symlink.sh $SCRIPTDIR/git/gituser ~/.gituser
./create_symlink.sh $SCRIPTDIR/kitty ~/.config/kitty
./create_symlink.sh $SCRIPTDIR/mako ~/.config/mako
./create_symlink.sh $SCRIPTDIR/mime/mimeapps.list ~/.config/mimeapps.list
./create_symlink.sh $SCRIPTDIR/niri ~/.config/niri
./create_symlink.sh $SCRIPTDIR/nvim ~/.config/nvim
./create_symlink.sh $SCRIPTDIR/waybar ~/.config/waybar
./create_symlink.sh $SCRIPTDIR/xcompose/ptbr ~/.XCompose
./create_symlink.sh $SCRIPTDIR/zsh/zshrc-linux ~/.zshrc

sudo ./create_symlink.sh $SCRIPTDIR/udev/rules.d /etc/udev/rules.d
