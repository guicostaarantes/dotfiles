#!/bin/bash
set -e

mirrors_country="Brazil"
timezone="America/Sao_Paulo"
keymap="us"
locale="en_US.UTF-8"

main() {
	unmount_cryptroot
	disk_target
	name_select
	password_select
	wipe_partition_disk
	format_partitions
	pacman_mirrors
	hardware_detect
	basesystem_install
	bootloader_config
	password_set
	localization_config
	home_dir_setup
	fstab_generate
	mkinitcpio_generate
	snapper_config
	mirrors_config
	boot_backup_hook
	zram_config
	# tpm_config
	services_enable

	print "Done, you may now wish to reboot."
}

# Pretty print function.
print() {
	echo -e "\e[92m• \e[4m$1\e[0m"
}

# If re-running script.
unmount_cryptroot() {
	if mount | grep -q /mnt; then
		print "Unmounting subvolumes and closing cryptroot."
		umount -R /mnt
		cryptsetup close cryptroot
	fi
}

disk_target() {
	disks=$(lsblk -dpnoNAME,MODEL,SIZE | grep -P "/dev/sd|nvme|vd")

	echo "Available disks:"
	lsblk -dpnoNAME,MODEL,SIZE | grep -P "/dev/sd|nvme|vd"
	echo ""
	PS3="Select the disk in which to install Arch Linux: "
	select disk in $(awk '{print $1}' <<< "$disks"); do
		print "Installing Arch Linux on $disk."
		break
	done
}

name_select() {
	read -rp "Insert hostname: " hostname
	read -rp "Insert username: " username
}

password_select() {
	read -rsp "Insert password for disk encryption, root user, and own user: " password
	echo ""
	read -rsp "Confirm password: " password_confirm
	echo ""

	if [ -z "$password" ]; then
		print "You need to enter a password."
		password_select
	elif [ "$password" != "$password_confirm" ]; then
		print "Passwords do not match, please try again."
		password_select
	fi
}

wipe_partition_disk() {
	read -rp "All data stored in $disk will be destroyed. Are you sure to continue? [yes/NO]: " confirm
	if [[ "$confirm" != "yes" ]]; then
		print "Aborted since answer was not \"yes\"."
		exit 1
	fi

	print "Wiping $disk."

	wipefs -af "$disk" &> /dev/null
	sgdisk -Zo "$disk" &> /dev/null

	print "Creating the partitions on $disk."

	parted -s "$disk" \
		mklabel gpt \
		mkpart ESP fat32 1MiB 2GiB \
		set 1 esp on \
		mkpart root 2GiB 100%

	partprobe "$disk"
}

format_partitions() {
	if grep -q "^/dev/nvme" <<< "$disk"; then
		boot_partition="${disk}p1"
		root_partition="${disk}p2"
	else
		boot_partition="${disk}1"
		root_partition="${disk}2"
	fi

	print "Formatting boot partition."

	mkfs.fat -F 32 "$boot_partition" &> /dev/null

	btrfs_setup
	
	print "Mounting boot partition."
	mount "$boot_partition" /mnt/boot/
}

btrfs_setup() {
	print "Encrypting root partition."

	echo -n "$password" | cryptsetup luksFormat "$root_partition" -d -
	echo -n "$password" | cryptsetup open "$root_partition" cryptroot -d -
	cryptroot="/dev/mapper/cryptroot"

	print "Formatting root partition."
	mkfs.btrfs $cryptroot &> /dev/null
	mount $cryptroot /mnt

	print "Creating BTRFS subvolumes."
	for volume in @ @home @hcache @root @vlog @vcache; do
		btrfs subvolume create /mnt/$volume &> /dev/null
	done

	mkdir /mnt/@root/live
	mkdir /mnt/@home/live
	btrfs subvolume create /mnt/@root/live/snapshot &> /dev/null
	btrfs subvolume create /mnt/@home/live/snapshot &> /dev/null

	print "Mounting the newly created subvolumes."
	umount /mnt

	btrfs_opts="noatime,compress-force=zstd:3,discard=async"

	mount -o $btrfs_opts,subvol=@root/live/snapshot $cryptroot /mnt
	mkdir -p /mnt/{boot,home,var/log,var/cache,.snapshots}

	mount -o $btrfs_opts,subvol=@root $cryptroot /mnt/.snapshots
	mount -o $btrfs_opts,subvol=@vlog $cryptroot /mnt/var/log
	mount -o $btrfs_opts,subvol=@vcache $cryptroot /mnt/var/cache
	mount -o $btrfs_opts,subvol=@home/live/snapshot $cryptroot /mnt/home

	mkdir -p /mnt/home/{.snapshots,$username,$username/.cache}
	mount -o $btrfs_opts,subvol=@home $cryptroot /mnt/home/.snapshots
	mount -o $btrfs_opts,subvol=@hcache $cryptroot /mnt/home/$username/.cache

	chattr +C /mnt/var/log
	chattr +C /mnt/var/cache
	chattr +C /mnt/home/$username/.cache
}

pacman_mirrors() {
	print "Updating pacman mirrors."

	reflector \
		--country $mirrors_country \
		--latest 25 \
		--age 24 \
		--protocol https \
		--completion-percent 100 \
		--sort rate \
		--save /etc/pacman.d/mirrorlist
}

hardware_detect() {
	cpu=$(grep vendor_id /proc/cpuinfo)
	if [[ $cpu == *"AuthenticAMD"* ]]; then
		cpu_type="AMD"
		microcode="amd-ucode"
		drivers=(libva-mesa-driver xf86-video-amdgpu)
	else
		cpu_type="Intel"
		microcode="intel-ucode"
		drivers=(intel-media-driver libva-intel-driver xf86-video-intel)
	fi

	print "An $cpu_type CPU has been detected."

	if lspci | grep -i nvidia > /dev/null; then
		print "An NVIDIA GPU has been detected."
		drivers+=(nvidia-open nvidia-utils libva-nvidia-driver)
	fi

	if lspci | grep -i bcm4360 > /dev/null; then
		print "A Broadcom BCM4360 wireless adapter has been detected."
		drivers+=(broadcom-wl)
	fi
}

basesystem_install() {
	print "Installing base system."

	timedatectl set-ntp 1 &> /dev/null

	sed -i 's/#Color/Color/' /etc/pacman.conf
	sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

	pacman -Sy archlinux-keyring --noconfirm

	pkgs=(
		base
		base-devel
		btrfs-progs
		linux
		linux-firmware
		networkmanager
		reflector
		rsync
		snapper
		zram-generator
	)

	yes '' | pacstrap /mnt $microcode "${drivers[@]}" "${pkgs[@]}"

	print "Setting hosts file."
	cat > /mnt/etc/hosts <<- EOF
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   $hostname.localdomain   $hostname
	EOF
}

bootloader_config() {
	computer_model=$(cat /sys/devices/virtual/dmi/id/product_version)
	uuid=$(blkid -s UUID -o value "$root_partition")
	kernel_params="rd.luks.name=$uuid=cryptroot root=$cryptroot rootflags=subvol=@root/live/snapshot rd.systemd.show_status=auto rd.udev.log_level=3 quiet rw"

	if [[ "$computer_model" = "ThinkPad"* ]]; then
		kernel_params+=" psmouse.synaptics_intertouch=1"
	fi

	if [[ "$cpu_type" = "AMD" ]]; then
		kernel_params+=" amd_pstate=active"
	fi

	if lspci | grep -i nvidia > /dev/null; then
		kernel_params+=" nvidia-drm.modeset=1"
	fi

	print "Configuring systemd-boot."

	arch-chroot /mnt bootctl install &> /dev/null
	cat > /mnt/boot/loader/loader.conf <<- EOF
		default arch
		timeout 0
		editor no
	EOF

	cat > /mnt/boot/loader/entries/arch.conf <<- EOF
		title Arch Linux
		linux /vmlinuz-linux
		initrd /$microcode.img
		initrd /initramfs-linux.img
		options $kernel_params
	EOF
}

password_set() {
	print "Setting hostname."
	echo "$hostname" > /mnt/etc/hostname

	print "Setting root password."
	echo "root:$password" | arch-chroot /mnt chpasswd

	print "Adding the user $username to the system with root privilege."
	arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$username" &> /dev/null
	sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers

	print "Setting user password for $username."
	echo "$username:$password" | arch-chroot /mnt chpasswd
}

localization_config() {
	print "Configuring localization settings."

	ln -sf /usr/share/zoneinfo/"$timezone" /mnt/etc/localtime &> /dev/null
	arch-chroot /mnt hwclock --systohc

	echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf
	echo "$locale UTF-8" > /mnt/etc/locale.gen
	echo "LANG=$locale" > /mnt/etc/locale.conf

	arch-chroot /mnt locale-gen &> /dev/null
}

home_dir_setup() {
	print "Setting up home directory."

	mkdir -p /mnt/home/$username
	arch-chroot /mnt chown -R $username:$username /home/$username
}

fstab_generate() {
	print "Generating a new fstab."
	genfstab -U /mnt | sed -e 's/suvolid=[0-9]*,//g' >> /mnt/etc/fstab
}

mkinitcpio_generate() {
	print "Configuring /etc/mkinitcpio.conf."
	cat > /mnt/etc/mkinitcpio.conf <<- EOF
		HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)
		COMPRESSION=(zstd)
	EOF

	print "Generating a new initramfs."
	arch-chroot /mnt mkinitcpio -P &> /dev/null
}

snapper_config() {
	print "Configuring snapper."

	cat > /mnt/etc/snapper/configs/root <<- EOF
		SUBVOLUME="/"
		FSTYPE="btrfs"
		QGROUP=""
		SPACE_LIMIT="0.5"
		FREE_LIMIT="0.2"
		ALLOW_USERS=""
		ALLOW_GROUPS="wheel"
		SYNC_ACL="no"
		BACKGROUND_COMPARISON="yes"
		NUMBER_CLEANUP="yes"
		NUMBER_MIN_AGE="1800"
		NUMBER_LIMIT="6"
		NUMBER_LIMIT_IMPORTANT="3"
		TIMELINE_CREATE="yes"
		TIMELINE_CLEANUP="yes"
		TIMELINE_MIN_AGE="1800"
		TIMELINE_LIMIT_HOURLY="2"
		TIMELINE_LIMIT_DAILY="2"
		TIMELINE_LIMIT_WEEKLY="2"
		TIMELINE_LIMIT_MONTHLY="2"
		TIMELINE_LIMIT_YEARLY="0"
		EMPTY_PRE_POST_CLEANUP="yes"
		EMPTY_PRE_POST_MIN_AGE="1800"
	EOF

	cp /mnt/etc/snapper/configs/root /mnt/etc/snapper/configs/home
	sed -i "1s/.*/SUBVOLUME=\"\/home\"/" /mnt/etc/snapper/configs/home
	echo "SNAPPER_CONFIGS=\"root home\"" > /mnt/etc/conf.d/snapper

	cp /mnt/usr/lib/systemd/system/snapper-cleanup.timer /mnt/etc/systemd/system/snapper-cleanup.timer
	sed -i "s/OnBootSec=.*/OnCalendar=hourly/" /mnt/etc/systemd/system/snapper-cleanup.timer
	sed -i "s/OnUnitActiveSec=.*/Persistent=true/" /mnt/etc/systemd/system/snapper-cleanup.timer
}

mirrors_config() {
	print "Configuring reflector."

	cat > /mnt/etc/xdg/reflector/reflector.conf <<- EOF
		--country $mirrors_country
		--latest 25
		--age 24
		--protocol https
		--completion-percent 100
		--sort rate
		--save /etc/pacman.d/mirrorlist
	EOF
}

boot_backup_hook() {
	print "Configuring /boot backup on kernel upgrades."

	mkdir -p /mnt/etc/pacman.d/hooks
	cat > /mnt/etc/pacman.d/hooks/boot-backup.hook <<- EOF
		[Trigger]
		Operation = Upgrade
		Operation = Install
		Operation = Remove
		Type = Path
		Target = usr/lib/modules/*/vmlinuz

		[Action]
		Depends = rsync
		Description = Backing up /boot...
		When = PreTransaction
		Exec = /usr/bin/rsync -a --delete /boot /.bootbackup
	EOF
}

zram_config() {
	print "Configuring ZRAM."

	cat > /mnt/etc/systemd/zram-generator.conf <<- EOF
		[zram0]
		zram-fraction = 1
		max-zram-size = 4096
	EOF
}

# TODO: currently not working as expected
tpm_config() {
	print "Configuring auto decrypt with TPM."
	if [[ $(cat /sys/class/tpm/tpm0/device/description) == "TPM 2.0 Device" ]]; then
		print "This device supports TPM 2.0, will use it to automatically unencrypt the root partition."
		PASSWORD=$password systemd-cryptenroll $root_partition --tpm2-device=auto --tpm2-pcrs=7
	fi
}

services_enable() {
	print "Enabling services."

	services=(
		archlinux-keyring-wkd-sync.timer
		NetworkManager.service
		linux-modules-cleanup.service
		reflector.timer
		snapper-cleanup.timer
		snapper-timeline.timer
		systemd-oomd
		systemd-timesyncd
	)

	for service in "${services[@]}"; do
		arch-chroot /mnt systemctl enable "$service" &> /dev/null
	done
}

if [ $# = 0 ]; then
	main
else
	"$@"
fi
