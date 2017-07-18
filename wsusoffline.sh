#!/bin/bash

set -eo pipefail
cd "$(dirname "$0")"

if [ -z "$1" ]; then
	echo "Usage: $(basename "$0") <Windows version>"
	echo
	echo "Downloads all required and security updates for the given Windows version."
	echo "Valid values for version are: w61-x64, w100-x64, w61, w100, ..."
	echo "For more information, please take a look at wsusoffline/sh/download-updates.bash."
	exit 2
fi

if [ ! -d wsusoffline ]; then
	echo "==> Downloading WSUS Offline..."
	if ! type -P wget > /dev/null || ! type -P unzip > /dev/null || ! type -P zip > /dev/null; then
		echo "ERROR: This script requires wget, zip and unzip. At least one of these is missing."
		echo "Please install the missing tools."
		exit 1
	fi

	url="$(wget -q -O- "http://download.wsusoffline.net/StaticDownloadLink-recent.txt")"
	wget -O wsus.zip "$url"

	unzip wsus.zip
	rm wsus.zip

	cp wsusoffline-preferences.bash wsusoffline/sh/preferences.bash
fi

bash ./wsusoffline/sh/download-updates.bash "$1" enu -includesp -includecpp -includedotnet

echo "==> Compressing update pack..."
cd wsusoffline/client

contents=()
for item in *; do
	if [ ! "${item:0:1}" = "w" ] || [ "$item" = "wsus" ] || [ "$item" = "$1" ]; then
		contents+=("$item")
	fi
done

zip -r -u "../wsus-pack-$1.zip" "${contents[@]}"
