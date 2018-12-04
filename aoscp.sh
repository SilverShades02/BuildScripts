#!/bin/bash

# ccache
export USE_CCACHE=1

# Telegram
export TG=~/BuildScripts/telegram.conf

# Google Drive for Linux
export GDRIVE=/usr/bin/gdrive

# Switch to source directory
cd ~/CypherOS

# Configs Needed
export TARGET=aoscp_santoni-userdebug
export AOSCP_VERSION=7.0.0
export MAKETARGET=bacon
export AOSCP_BUILDTYPE=unofficial

# Date and time
export BUILDDATE=$(date +%Y%m%d)
export BUILDTIME=$(date +%H%M)

# Repo sync
repo sync -f --force-sync --no-tags --no-clone-bundle -c
# envsetup
source build/envsetup.sh
# lunch
lunch $TARGET
# Build
telegram-send --config $TG --format html "
Repo syncing Done with <code>repo sync -f --force-sync --no-tags --no-clone-bundle -c</code>
Established Build Enviroment...
Lunched target
"
time mka $MAKETARGET -j$(nproc --all) | tee build.log

EXITCODE=$?
if [ $EXITCODE -eq 0 ];
then
	telegram-send --config $TG --format html " Build finished successfully"
else
	telegram-send --config $TG --format html " Build Failed"
fi

# Move zip to ROMs Folder
mv $OUT/aoscp_santoni-$AOSCP_VERSION-$BUILDDATE-$AOSCP_BUILDTYPE.zip /home/Kakashi/ROMs/aoscp_santoni-$AOSCP_VERSION-$BUILDDATE-$AOSCP_BUILDTYPE.zip

# Starting upload!
telegram-send --config $TG --format html "Uploading to Google Drive..."
gdrive upload ~/ROMs/aoscp_santoni-$AOSCP_VERSION-$BUILDDATE-$AOSCP_BUILDTYPE.zip | tee -a /tmp/gdrive-$BUILDDATE-$BUILDTIME
FILEID=$(cat /tmp/gdrive-$BUILDDATE-$BUILDTIME | tail -n 1 | awk '{ print $2 }')
gdrive share $FILEID
gdrive info $FILEID | tee -a /tmp/gdrive-info-$BUILDDATE-$BUILDTIME
MD5=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Md5sum' | awk '{ print $2 }')
NAME=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Name' | awk '{ print $2 }')
SIZE=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Size' | awk '{ print $2 }')
DLURL=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'DownloadUrl' | awk '{ print $2 }')
echo -e "\nID: <code>$FILEID</code>\nPackage name: <code>$NAME</code>\nSize: <code>$SIZE</code>MB\nmd5sum: <code>$MD5</code>\nDownload link: $DLURL" | telegram-send --config $ROL --format html --stdin
