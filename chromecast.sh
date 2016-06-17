#!/bin/bash

function update-chromecast {
  dir=$1

  home=`curl -s -L "https://clients3.google.com/cast/chromecast/home"`
  translated=`echo "$home" | while IFS= read -r line; do echo -e "$line"; done`

  urls=`echo "$translated" | egrep -oh '"https:[^"]+googleusercontent[^"]+"' | jq -r -s '.[]' | sed 's/1280/1920/g' | sed 's/720/1080/g'`

  for url in $urls; do
    echo "[chromecast] Found $url."
    store-image "$dir" "$url"
  done
}
