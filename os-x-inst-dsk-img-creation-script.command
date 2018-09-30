#!/bin/bash

# ---------------------------------------------------------------------------------------------------- #
#
# OS X Installation Disk Image Creation Script
#
# Copyright (c) 2015-2017 tag
# Released under the MIT license
# http://opensource.org/licenses/mit-license.php
#
# ---------------------------------------------------------------------------------------------------- #

# working directory
WORKING_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo
echo "# -------------------------------------------------- #"
echo "#                                                    #"
echo "#    OS X Installation Disk Image Creation Script    #"
echo "#                                                    #"
echo "# -------------------------------------------------- #"
echo
echo "Please deploy an installation package at the same folder."
echo 

# OS X Version Name
OS_X=\
(\
	"Mac OS X 10.0 Cheetah" \
	"Mac OS X 10.1 Puma" \
	"Mac OS X 10.2 Jaguar" \
	"Mac OS X 10.3 Panther" \
	"Mac OS X 10.4 Tiger" \
	"Mac OS X 10.5 Leopard" \
	"Mac OS X 10.6 Snow Leopard" \
	"Mac OS X Lion" \
	"OS X Mountain Lion" \
	"OS X Mavericks" \
	"OS X Yosemite" \
	"OS X El Capitan" \
	"macOS Sierra" \
	"macOS High Sierra" \
	"macOS Mojave" \
)

echo Select OS X version.
for ((i = 7; i < ${#OS_X[@]}; i++)); do
	echo "[${i}] ${OS_X[${i}]}"
done
read VERSION
INST_PKG_FILENAME="Install ${OS_X[${VERSION}]}"
if [ -e "${WORKING_DIR}/${INST_PKG_FILENAME}.app" ]; then
	echo "${INST_PKG_FILENAME}.app is found. This process will be started."
else
	echo "${INST_PKG_FILENAME}.app is not found. This process will be stopped."
	exit 1
fi

echo ================================================================================
echo Mounting InstallESD.dmg in the OS X installation package...
#echo インストーラ内の InstallESD.dmg をマウントしています...
hdiutil attach "${WORKING_DIR}/${INST_PKG_FILENAME}.app/Contents/SharedSupport/InstallESD.dmg" -noverify -nobrowse -mountpoint "/Volumes/OS X Install ESD"

if [ ${VERSION} -ge 7 -a ${VERSION} -le 10 ]; then
	# OS X Lion -- OS X Yosemite
	echo ================================================================================
	echo Converting BaseSystem.dmg to a sparse image...
	#echo BaseSystem.dmg をスパースイメージに変換しています...
	hdiutil convert "/Volumes/OS X Install ESD/BaseSystem.dmg" -format UDSP -o "${WORKING_DIR}/${INST_PKG_FILENAME}"

	echo ================================================================================
	echo Expanding the sparse image size...
	#echo スパースイメージのサイズを拡張しています...
	hdiutil resize -size 8g "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage"

	echo ================================================================================
	echo Mounting the sparse image...
	#echo スパースイメージをマウントしています...
	hdiutil attach "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -noverify -nobrowse -mountpoint "/Volumes/${INST_PKG_FILENAME}"
else
	# OS X El Capitan --
	echo ================================================================================
	echo Creating a sparse image...
	# echo スパースイメージを作成しています...
	hdiutil create -o "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -size 8g -layout SPUD -fs HFS+J -type SPARSE

	echo ================================================================================
	echo Mounting it...
	# echo 作成したスパースイメージをマウントしてます...
	hdiutil attach "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -noverify -nobrowse -mountpoint "/Volumes/${INST_PKG_FILENAME}"

	echo ================================================================================
	echo Restoring BaseSystem.dmg to ${INST_PKG_FILENAME}.sparseimage...
	# echo BaseSystem.dmg を作成したスパースイメージにレストアしています...
	ls /Volumes
	if [ ${VERSION} -le 12 ]; then
		# macOS Sierra
		asr restore -source "/Volumes/OS X Install ESD/BaseSystem.dmg" -target "/Volumes/${INST_PKG_FILENAME}" -noprompt -noverify -erase
	else
		# macOS High Sierra --
		asr restore -source "${WORKING_DIR}/${INST_PKG_FILENAME}.app/Contents/SharedSupport/BaseSystem.dmg" -target "/Volumes/${INST_PKG_FILENAME}" -noprompt -noverify -erase
	fi
	hdiutil detach "/Volumes/OS X Base System"
	ls /Volumes
	hdiutil attach "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -noverify -nobrowse -mountpoint "/Volumes/${INST_PKG_FILENAME}"
	ls /Volumes
fi

echo ================================================================================
echo Removeing an alias, Packages, from the sparse image...
#echo エイリアス Packages を削除しています...
rm "/Volumes/${INST_PKG_FILENAME}/System/Installation/Packages"

if [ ${VERSION} -ge 7 -a ${VERSION} -le 12 ]; then
	# OS X Lion -- macOS Sierra
	echo ================================================================================
	echo Copying a folder, Packages, to the sparse image...
	#echo フォルダ Packages をコピーしています...
	cp -rp "/Volumes/OS X Install ESD/Packages" "/Volumes/${INST_PKG_FILENAME}/System/Installation/"

	echo ================================================================================
	echo Copying files, BaseSystem.dmg and BaseSystem.chunklist, to the sparse image...
	# echo BaseSystem.dmg および BaseSystem.chunklist をコピーしています...
	# OS X Mavericks 以前は要らない？ そもそも OS X Yosemite で必要なのか？
	cp "/Volumes/OS X Install ESD/BaseSystem.dmg" "/Volumes/${INST_PKG_FILENAME}/"
	cp "/Volumes/OS X Install ESD/BaseSystem.chunklist" "/Volumes/${INST_PKG_FILENAME}/"
else
	# macOS High Sierra --
	echo ================================================================================
	echo Copying a folder, Packages, to the sparse image...
	#echo フォルダ Packages をコピーしています...
	cp -rp "/Volumes/OS X Install ESD/Packages" "/Volumes/${INST_PKG_FILENAME}/System/Installation/"

	echo ================================================================================
	echo Copying files, BaseSystem.dmg and BaseSystem.chunklist, to the sparse image...
	# echo BaseSystem.dmg および BaseSystem.chunklist をコピーしています...
	cp "${WORKING_DIR}/${INST_PKG_FILENAME}.app/Contents/SharedSupport/BaseSystem.dmg" "/Volumes/${INST_PKG_FILENAME}/"
	cp "${WORKING_DIR}/${INST_PKG_FILENAME}.app/Contents/SharedSupport/BaseSystem.chunklist" "/Volumes/${INST_PKG_FILENAME}/"	
fi

echo ================================================================================
echo Unmounting 2 volumes...
#echo アンマウントしています...
hdiutil detach "/Volumes/OS X Install ESD"
hdiutil detach "/Volumes/${INST_PKG_FILENAME}"

echo ================================================================================
echo Compacting the sparse image to eliminate the waste...
#echo スパースイメージの無駄をなくしています...
hdiutil compact "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -batteryallowed

echo ================================================================================
echo Resizing the sparse image...
#echo スパースイメージのサイズを調整しています...
hdiutil resize -size `hdiutil resize -limits "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" | tail -n 1 | awk '{ print $1 }'`b "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage"

echo ================================================================================
echo Converting the sparse image to a DMG file...
#echo スパースイメージを DMG ファイルに変換しています...
hdiutil convert -format UDZO "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -o "${WORKING_DIR}/${INST_PKG_FILENAME}.dmg"

echo ================================================================================
echo Converting the sparse image to a ISO file...
#echo スパースイメージを ISO ファイルに変換しています...
# for OSx86, Hackintosh users
# 夢を見る際に使用。
hdiutil convert -format UDTO "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage" -o "${WORKING_DIR}/${INST_PKG_FILENAME}.cdr"
mv "${WORKING_DIR}/${INST_PKG_FILENAME}.cdr" "${WORKING_DIR}/${INST_PKG_FILENAME}.iso"

echo ================================================================================
echo Removing the sparse image...
#echo スパースイメージを削除しています...
rm "${WORKING_DIR}/${INST_PKG_FILENAME}.sparseimage"

echo ================================================================================
echo Process is end.
#echo 終了しました
