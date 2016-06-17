#!/bin/bash

source ./image.sh
source ./bing.sh
source ./spotlight.sh
source ./chromecast.sh

cd `dirname $0`

store=wallpapers
mkdir -p "$store"

echo "Update wallpapers."
echo "Update Bing." && update-bing "$store"
echo "Update Spotlight." && update-spotlight "$store"
echo "Update Chromecast." && update-chromecast "$store"

git checkout -b wallpapers
git add -v "$store"
git commit -m "Add wallpapers."
ssh-agent bash -c "ssh-add wallpapers-key && git push -u origin wallpapers"
