#!/bin/bash
#
# Script to setup GCP for Android Rom Developing
#
# HandMade by Jyotiraditya
#

# Go to home dir
cd ~

# Some Packages
sudo apt-get update
sudo apt-get install -y bc bison build-essential curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev unzip openjdk-8-jdk python ccache
sudo apt-get upgrade -y

# CCache
ccache -M 500G

# Android SDK
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
rm platform-tools-latest-linux.zip

# Repo
wget https://storage.googleapis.com/git-repo-downloads/repo
chmod a+x repo
sudo install repo /usr/local/bin/repo

# GDrive CLI
wget -O gdrive "https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download"
chmod a+x gdrive
sudo install gdrive /usr/local/bin/gdrive

# Use Ccache
cat <<'EOF' >> ~/.bashrc
export USE_CCACHE=1
EOF

# Add android sdk to path
cat <<'EOF' >> ~/.profile
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi
EOF

# TimeZone (Kolkata GMT+5:30)
sudo ln -sf /usr/share/zoneinfo/Asia/Calcutta /etc/localtime

source ~/.profile
source ~/.bashrc

# GIT
git config --global user.email "Jyotiraditya182@gmail.com"
git config --global user.name "Jyotiraditya"
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=9999999'

