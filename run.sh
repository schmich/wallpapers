#!/bin/bash

cd `dirname $0`

path=`curl -s http://www.bing.com | grep -m1 -ioP '\burl:\s*("[^"]+")' | cut -d: -f2 | jq '.' | tr -d '"'`
if [ -z "$path" ]; then
  echo "Unable to find wallpaper URL, exiting."
  exit 1
fi

url=http://www.bing.com$path
file=`echo $url | rev | cut -d/ -f1 | rev`
out=wallpapers/$file

if [ -f "$out" ]; then
  echo "Wallpaper already exists, exiting."
  exit 1
fi

mkdir -p wallpapers
curl -s -o "$out" "$url"

git checkout -b wallpapers
git add -v wallpapers
git commit -m "Add wallpaper."
ssh-agent bash -c "ssh-add bing-wallpapers-key && git push -u origin wallpapers"
