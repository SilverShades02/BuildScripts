#!/bin/bash

# ccache
export USE_CCACHE=1

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
echo "Starting repo sync."
repo sync -f --force-sync --no-tags --no-clone-bundle -c
echo "repo sync finished."

# envsetup
echo "Establishing build environment..."
source build/envsetup.sh
echo "Established"

# lunch
echo "Lunching Now"
lunch $TARGET

# Build
echo "Starting build..."
time mka $MAKETARGET -j$(nproc --all) | tee build.log

EXITCODE=$?
if [ $EXITCODE -eq 0 ];
then
	echo " Build finished successfully"
else
	echo " Build Failed"
fi

# Move zip to ROMs Folder
mv $OUT/aoscp_santoni-$AOSCP_VERSION-$BUILDDATE-$AOSCP_BUILDTYPE.zip /home/Kakashi/ROMs/aoscp_santoni-$AOSCP_VERSION-$BUILDDATE-$AOSCP_BUILDTYPE.zip

# Starting upload!
echo "Uploading to Google Drive..."
gdrive upload ~/ROMs/aoscp_santoni-$AOSCP_VERSION-$BUILDDATE-$AOSCP_BUILDTYPE.zip | tee -a /tmp/gdrive-$BUILDDATE-$BUILDTIME
FILEID=$(cat /tmp/gdrive-$BUILDDATE-$BUILDTIME | tail -n 1 | awk '{ print $2 }')
gdrive share $FILEID
gdrive info $FILEID | tee -a /tmp/gdrive-info-$BUILDDATE-$BUILDTIME
MD5=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Md5sum' | awk '{ print $2 }')
NAME=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Name' | awk '{ print $2 }')
SIZE=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'Size' | awk '{ print $2 }')
DLURL=$(cat /tmp/gdrive-info-$BUILDDATE-$BUILDTIME | grep 'DownloadUrl' | awk '{ print $2 }')
echo -e "\nID: <code>$FILEID</code>\nPackage name: <code>$NAME</code>\nSize: <code>$SIZE</code>MB\nmd5sum: <code>$MD5</code>\nDownload link: $DLURL"
