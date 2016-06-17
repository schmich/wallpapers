#!/bin/bash

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
    sleep 0.1
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
