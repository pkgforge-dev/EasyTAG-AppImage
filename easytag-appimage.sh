#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q easytag | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

export ADD_HOOKS="self-updater.bg.hook"
export OUTNAME=EasyTAG-"$VERSION"-anylinux-"$ARCH".AppImage
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=/usr/share/applications/easytag.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/easytag.png

# Deploy dependencies
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/easytag

# MAKE APPIAMGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
