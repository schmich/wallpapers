#!/bin/bash

cd `dirname $0`

function download {
  lang=$1
  path=`curl -s "http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$lang" | jq '.images[0].url' | tr -d '"'`
  if [ -z "$path" ]; then
    echo "Unable to find wallpaper URL, skipping."
    return
  fi
  
  url=http://www.bing.com$path
  
  echo "[$lang] Found $url."
  
  file=`echo $url | rev | cut -d/ -f1 | rev | cut -d? -f1`
  out=wallpapers/$file
  
  if [ -f "$out" ]; then
    echo "[$lang] Wallpaper already exists, skipping."
    return
  fi
  
  echo "[$lang] Downloading to $out."
  
  mkdir -p wallpapers
  curl -s -o "$out" "$url"

  md5=`md5sum "$out" | cut -d' ' -f1`
  match=`md5sum wallpapers/* | grep -i $md5 | grep -v $out | head -n 1`
  if [ ! -z "$match" ]; then
    echo "[$lang] Wallpaper already exists, removing."
    rm "$out"
    return
  fi
}

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
  download $lang
done

git checkout -b wallpapers
git add -v wallpapers
git commit -m "Add wallpaper."
ssh-agent bash -c "ssh-add bing-wallpapers-key && git push -u origin wallpapers"
