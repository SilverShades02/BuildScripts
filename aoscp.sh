#!/bin/bash

# ccache
export USE_CCACHE=1

# Telegram
export TG=~/BuildScripts/telegram.conf

# Google Drive for Linux
export GDRIVE=/usr/bin/gdrive

# Build related
export TARGET=aoscp_santoni-userdebug
export AOSCP_VERSION=7.0.0
export MAKETARGET=bacon
export AOSCP_BUILDTYPE=unofficial

# Switch to source directory
cd ~/CypherOS

# Delete Old Logs
telegram-send --config $TG --format html "Deleting old logs now"
rm -rf log*.txt

# Date and time
export BUILDDATE=$(date +%Y%m%d)
export BUILDTIME=$(date +%H%M)

# Log
telegram-send --config $TG --format html "Logging to file <code>log-$BUILDDATE-$BUILDTIME.txt</code>"
export LOGFILE=log-$BUILDDATE-$BUILDTIME.txt

# Repo sync
telegram-send --config $TG --format html "Starting repo sync. Executing command: <code>repo sync -f --force-sync --no-tags --no-clone-bundle -c</code>"
repo sync -f --force-sync --no-tags --no-clone-bundle -c
telegram-send --config $TG --format html "repo sync finished."

# envsetup
telegram-send --config $TG --format html "Establishing build environment..."
source build/envsetup.sh

# lunch
telegram-send --config $TG --format html "Starting lunch... Lunching <code>$DEVICENAME</code>"
lunch $TARGET

# installclean
telegram-send --config $TG --format html "Removing out/ directory..."
rm -rf out/

# Build
telegram-send --config $TG --format html "Starting build... Building target <code>$MAKETARGET</code>"
time mka $MAKETARGET -j$(nproc --all) > ./$LOGFILE &
# LAUNCH PROGRESS OBSERVER
sleep 60
while test ! -z "$(pidof soong_ui)"; do
        # Go away for 10 mins
        sleep 120
        # bot: *WAkES uP, triggered*
        # Get latest percentage
        PERCENTAGE=$(cat $LOGFILE | tail -n 1 | awk '{ print $2 }')
        # REPORT PerCentage to that damn TeLeGraM
        telegram-send --config $TG --format html "Current percentage: $PERCENTAGE";
done
EXITCODE=$?
if [ $EXITCODE -ne 0 ];
	then telegram-send --config $TG --format html "Build failed! Check log file <code>$LOGFILE</code>";
	     telegram-send --config $TG --file $LOGFILE;
	exit 1;
fi
telegram-send --config TG --format html "Build finished successfully! Uploading new build..."

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
echo -e "\nID: <code>$FILEID</code>\nPackage name: <code>$NAME</code>\nSize: <code>$SIZE</code>MB\nmd5sum: <code>$MD5</code>\nDownload link: $DLURL" | telegram-send --config $TG --format html --stdin
telegram-send --config $TG --file $LOGFILE
