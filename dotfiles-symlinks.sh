SCRIPTPATH=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")

./make-symlink.sh $SCRIPTDIR/fontconfig $HOME/.config/fontconfig
./make-symlink.sh $SCRIPTDIR/fuzzel $HOME/.config/fuzzel
./make-symlink.sh $SCRIPTDIR/git/gitconfig $HOME/.gitconfig
./make-symlink.sh $SCRIPTDIR/kitty $HOME/.config/kitty
./make-symlink.sh $SCRIPTDIR/mako $HOME/.config/mako
./make-symlink.sh $SCRIPTDIR/mime/mimeapps.list $HOME/.config/mimeapps.list
./make-symlink.sh $SCRIPTDIR/niri $HOME/.config/niri
./make-symlink.sh $SCRIPTDIR/nvim $HOME/.config/nvim
./make-symlink.sh $SCRIPTDIR/waybar $HOME/.config/waybar
./make-symlink.sh $SCRIPTDIR/xcompose/ptbr $HOME/.XCompose
./make-symlink.sh $SCRIPTDIR/zsh/zshrc $HOME/.zshrc

sudo ./make-symlink.sh $SCRIPTDIR/udev/rules.d /etc/udev/rules.d

# This contains personal info which should not be tied to the repo
if [ ! -f $HOME/.gituser ]; then
	cp $SCRIPTDIR/git/gituser $HOME/.gituser
fi
