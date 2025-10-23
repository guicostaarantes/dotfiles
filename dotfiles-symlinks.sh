SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

./make-symlink.sh $SCRIPTDIR/fontconfig ~/.config/fontconfig
./make-symlink.sh $SCRIPTDIR/fuzzel ~/.config/fuzzel
./make-symlink.sh $SCRIPTDIR/git/gitconfig ~/.gitconfig
./make-symlink.sh $SCRIPTDIR/kitty ~/.config/kitty
./make-symlink.sh $SCRIPTDIR/mako ~/.config/mako
./make-symlink.sh $SCRIPTDIR/mime/mimeapps.list ~/.config/mimeapps.list
./make-symlink.sh $SCRIPTDIR/niri ~/.config/niri
./make-symlink.sh $SCRIPTDIR/nvim ~/.config/nvim
./make-symlink.sh $SCRIPTDIR/waybar ~/.config/waybar
./make-symlink.sh $SCRIPTDIR/xcompose/ptbr ~/.XCompose
./make-symlink.sh $SCRIPTDIR/zsh/zshrc ~/.zshrc

sudo ./make-symlink.sh $SCRIPTDIR/udev/rules.d /etc/udev/rules.d

# This contains personal info which should not be tied to the repo
cp -u $SCRIPTDIR/git/gituser ~/.gituser
