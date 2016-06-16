#!/bin/bash

cd `dirname $0`
mkdir -p wallpapers

source ./image.sh

function update-bing-lang {
  lang=$1
  path=`curl -s "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$lang" | jq '.images[0].url' | tr -d '"'`
  if [ -z "$path" ]; then
    echo "[bing/$lang] Unable to find wallpaper URL, skipping."
    return
  fi
  
  url="http://www.bing.com$path"
  
  echo "[bing/$lang] Found $url."
  
  store-image wallpapers "$url"
}

function update-bing {
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
  
  for lang in $langs; do
    update-bing-lang $lang
  done
}

function update-spotlight {
  url="http://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&cfmt=text,image,poly&sft=jpeg,png,gif&rafb=0&ctry=US&lc=en-US&pl=en-US&ua=Wallpapers&devfam=Windows.Desktop&disphorzres=1920&dispvertres=1080&dispsize=24.0&npid=LockScreen"

  image_urls=''
  for i in `seq 10`; do
    image_urls=`(echo $image_urls ; curl -s "$url" | jq -r '[.batchrsp.items[].item | fromjson | .ad.image_fullscreen_001_landscape.u][]')`
  done

  for url in $image_urls; do
    echo "[spotlight] Found $url."
    store-image wallpapers "$url"
  done
}

update-bing
update-spotlight

git checkout -b wallpapers
git add -v wallpapers
git commit -m "Add wallpaper."
ssh-agent bash -c "ssh-add wallpapers-key && git push -u origin wallpapers"
