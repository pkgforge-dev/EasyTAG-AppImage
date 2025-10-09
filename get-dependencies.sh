#!/bin/sh

set -eux
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm    \
	base-devel         \
	curl               \
	easytag            \
	git                \
	libxtst            \
	pipewire-audio     \
	pulseaudio         \
	pulseaudio-alsa    \
	wget               \
	xorg-server-xvfb   \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh gtk3-mini libxml2-mini opus-mini gdk-pixbuf2-mini

# for some reason this app ends up opening mesa, but doesn't really need it?
# why would a gtk3 app that edit audio files need mesa???
pacman -Rsndd --noconfirm mesa

echo "All done!"
echo "---------------------------------------------------------------"
