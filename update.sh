#!/bin/bash

wallpapers_dir=wallpapers

cd `dirname $0`
mkdir -p "$wallpapers_dir"

source ./image.sh

function update-bing {
  dir=$1

  langs="
  af ar-sa ar-eg ar-dz ar-tn ar-ye ar-jo ar-kw ar-bh eu be zh-tw
  zh-hk hr da nl-be en-us en-au en-nz en-za en en-tt fo fi fr-be
  fr-ch gd de de-at de-li he hu id it-ch ko lv mk mt no pt-br rm
  ro-mo ru-mo sr sk sb es-mx es-cr es-do es-co es-ar es-cl es-py
  es-sv es-ni sx sv-fi ts tr ur vi ji sq ar-iq ar-ly ar-ma ar-om
  ar-sy ar-lb ar-ae ar-qa bg ca zh-cn zh-sg cs nl en en-gb en-ca
  en-ie en-jm en-bz et fa fr fr-ca fr-lu ga de-ch de-lu el hi is
  it ja lt ms no pl pt ro ru sz sl es es-gt es-pa es-ve es-pe sv
  es-pe es-ec es-uy es-bo es-hn es-pr sv th tn uk ve xh zu
  "

  paths=$(for lang in $langs; do
    curl -s "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=5&mkt=$lang" | jq -r '.images[].urlbase'
  done | sort | uniq)

  if [ -z "$paths" ]; then
    echo "[bing] Unable to find wallpaper URLs, skipping."
    return
  fi

  for path in $paths; do
    url="http://www.bing.com${path}_1920x1080.jpg"
    echo "[bing] Found $url."
    store-image "$dir" "$url"
  done
}

function update-spotlight {
  dir=$1

  spotlight="http://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&rafb=0&ua=WindowsShellClient%2F0&disphorzres=1920&dispvertres=1080&lo=80000"

  urls=$(for i in `seq 30`; do
    curl -s "$spotlight" | jq -r '[.batchrsp.items[].item | fromjson | .ad.image_fullscreen_001_landscape.u][]'
  done | sort | uniq)

  if [ -z "$urls" ]; then
    echo "[spotlight] Unable to find wallpaper URLs, skipping."
    return
  fi

  for url in $urls; do
    echo "[spotlight] Found $url."
    store-image "$dir" "$url"
  done
}

echo "Update wallpapers."
echo "Update Bing." && update-bing "$wallpapers_dir"
echo "Update Spotlight." && update-spotlight "$wallpapers_dir"

git checkout -b wallpapers
git add -v "$wallpapers_dir"
git commit -m "Add wallpapers."
ssh-agent bash -c "ssh-add wallpapers-key && git push -u origin wallpapers"
