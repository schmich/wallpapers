#!/bin/bash

source ./image.sh
source ./bing.sh
source ./spotlight.sh

cd `dirname $0`

store=wallpapers
mkdir -p "$store"

echo "Update wallpapers."
echo "Update Bing." && update-bing "$store"
echo "Update Spotlight." && update-spotlight "$store"

git checkout -b wallpapers
git add -v "$store"
git commit -m "Add wallpapers."
ssh-agent bash -c "ssh-add wallpapers-key && git push -u origin wallpapers"
