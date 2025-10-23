# My dotfiles

Scripts and config files to install and update my systems.

`arch-install.sh` wipes a disk and installs Arch Linux in it.

`arch-setup.sh` installs packages, enables services and creates symlinks for config files.

`arch-setup.sh` is an idempotent script, which means that running it multiple times should not cause errors. While it is possible to add packages to the system by manually running `pacman` or `yay`, it is preferred to add them to `arch-setup.sh` and then re-run the script. This way the package gets consolidated in the repository and will be installed in future setups.
