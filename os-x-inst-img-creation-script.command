#!/bin/bash

# ---------------------------------------------------------------------------------------------------- #
#
# OS X Install Image Creation Script
# Usage:
#	1) Deploy this script at any folder
#	2) Deploy "Install OS X <nickname>.app" at the same folder
#	3) Grant execute permission (example: chmod +x <filename>)
#	4) Execute this script (example: ./<filename>)
#
# Copyright (C) 2015 tag. All rights reserved.
#
# ---------------------------------------------------------------------------------------------------- #

# wording dir
work=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# OS X nickname
nickname=El\ Capitan

echo ================================================================================
echo mounting InstallESD.dmg in the OS X installation package
#echo インストーラ内の InstallESD.dmg をマウントしています...
hdiutil attach "${work}/Install OS X ${nickname}.app/Contents/SharedSupport/InstallESD.dmg" -noverify -nobrowse -mountpoint "/Volumes/OS X Install ESD"

echo ================================================================================
echo converting BaseSystem.dmg to a sparse image
#echo BaseSystem.dmg をスパースイメージに変換しています...
hdiutil convert "/Volumes/OS X Install ESD/BaseSystem.dmg" -format UDSP -o "${work}/${nickname}"

echo ================================================================================
echo expanding the sparse image size
#echo スパースイメージのサイズを拡張しています...
hdiutil resize -size 8g "${work}/${nickname}.sparseimage"

echo ================================================================================
echo mounting the sparse image
#echo スパースイメージをマウントしています...
hdiutil attach "${work}/${nickname}.sparseimage" -noverify -nobrowse -mountpoint "/Volumes/${nickname}"

echo ================================================================================
echo removeing an alias, Packages, from the sparse image
#echo エイリアス Packages を削除しています...
rm "/Volumes/${nickname}/System/Installation/Packages"

echo ================================================================================
echo copying a folder, Packages, to the sparse image
echo フォルダ Packages をコピーしています...
cp -rp "/Volumes/OS X Install ESD/Packages" "/Volumes/${nickname}/System/Installation/"

echo ================================================================================
echo copying files, BaseSystem.dmg and BaseSystem.chunklist, to the sparse image
# echo BaseSystem.dmg および BaseSystem.chunklist をコピーしています...
# OS X Mavericks 以前は要らない？ そもそも OS X Yosemite で必要なのか？
cp "/Volumes/OS X Install ESD/BaseSystem.dmg" "/Volumes/${nickname}/"
cp "/Volumes/OS X Install ESD/BaseSystem.chunklist" "/Volumes/${nickname}/"

echo ================================================================================
echo unmounting 2 volumes
#echo アンマウントしています...
hdiutil detach "/Volumes/OS X Install ESD"
hdiutil detach "/Volumes/${nickname}"

echo ================================================================================
echo compacting the sparse image to eliminate the waste
#echo スパースイメージの無駄をなくしています...
hdiutil compact "${work}/${nickname}.sparseimage" -batteryallowed

echo ================================================================================
echo resizing the sparse image
#echo スパースイメージのサイズを調整しています...
hdiutil resize -size `hdiutil resize -limits "${work}/${nickname}.sparseimage" | tail -n 1 | awk '{ print $1 }'`b "${work}/${nickname}.sparseimage"

echo ================================================================================
echo converting the sparse image to a DMG file
#echo スパースイメージを DMG ファイルに変換しています...
hdiutil convert -format UDZO "${work}/${nickname}.sparseimage" -o "${work}/${nickname}.dmg"

# for converting the sparse image to a ISO file
# 上の代わりに↓のコマンドを打つと ISO 化できて、夢を見る準備ができるとか。 (コマンドはこんな感じでいいと思うけど、未検証)
# hdiutil convert -format UDTO "${work}/${nickname}.sparseimage" -o "${work}/${nickname}.cdr"
# mv "${work}/${nickname}.cdr" "${work}/${nickname}.iso"

echo ================================================================================
echo removing the sparse image
#echo スパースイメージを削除しています...
rm "${work}/${nickname}.sparseimage"

echo ================================================================================
echo 終了しました
