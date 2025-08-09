#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q easytag | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# Prepare AppDir
mkdir -p ./AppDir
cp -v /usr/share/applications/easytag.desktop            ./AppDir
cp -v /usr/share/icons/hicolor/256x256/apps/easytag.png  ./AppDir
cp -v /usr/share/icons/hicolor/256x256/apps/easytag.png  ./AppDir/.DirIcon

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/easytag
ln ./AppDir/sharun ./AppDir/AppRun

# MAKE APPIAMGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME"      -O  ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O  ./uruntime-lite
chmod +x ./uruntime*

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S26 -B8 \
	--header uruntime-lite \
	-i ./AppDir -o ./EasyTAG-"$VERSION"-anylinux-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

echo "All Done!"
