#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q easytag | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export APPNAME=EasyTAG
export DESKTOP=/usr/share/applications/easytag.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/easytag.png
export ALWAYS_SOFTWARE=1

# Deploy dependencies
quick-sharun /usr/bin/easytag

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the final app
quick-sharun --test ./dist/*.AppImage
