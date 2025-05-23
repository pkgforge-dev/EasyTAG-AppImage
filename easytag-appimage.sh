#!/bin/sh

set -eux

export ARCH="$(uname -m)"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
SHARUN="https://github.com/VHSgunzo/sharun/releases/latest/download/sharun-$ARCH-aio"
SYSLIBS="/usr/lib"

VERSION=$(pacman -Q easytag | awk 'NR==1 {print $2; exit}')
echo "$VERSION" > ~/version

# Prepare AppDir
mkdir -p ./AppDir
cd ./AppDir

cp -v /usr/share/applications/easytag.desktop            ./
cp -v /usr/share/icons/hicolor/256x256/apps/easytag.png  ./
cp -v /usr/share/icons/hicolor/256x256/apps/easytag.png  ./.DirIcon

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./sharun-aio
chmod +x ./sharun-aio
xvfb-run -a ./sharun-aio l -p -v -e -s -k           \
	/usr/bin/easytag                            \
	"$SYSLIBS"/libvorbis*                       \
	"$SYSLIBS"/libvogg*                         \
	"$SYSLIBS"/libopus*                         \
	"$SYSLIBS"/libwavpack*                      \
	"$SYSLIBS"/libFLAC*                         \
	"$SYSLIBS"/libwavpack*                      \
	"$SYSLIBS"/libid3tag.so*                    \
	"$SYSLIBS"/libXss.so*                       \
	"$SYSLIBS"/gdk-pixbuf-*/*/loaders/*         \
	"$SYSLIBS"/gio/modules/libdconfsettings.so  \
	"$SYSLIBS"/pulseaudio/*
rm -f ./sharun-aio
./sharun -g

# MAKE APPIAMGE WITH URUNTIME
cd ..
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
