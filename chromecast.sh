#!/bin/bash

function update-chromecast {
  dir=$1

  urls=$(for i in `seq 30`; do
    (curl -s -L "https://clients3.google.com/cast/chromecast/home"; echo) |\
      while IFS= read -r line; do echo -e "$line"; done |\
      egrep -oh '"https:[^"]+googleusercontent[^"]+"' |\
      jq -r -s '.[]' |\
      sed 's/1280/1920/g' |\
      sed 's/720/1080/g'

    sleep 0.1
  done | sort | uniq)

  for url in $urls; do
    echo "[chromecast] Found $url."
    store-image "$dir" "$url"
  done
}
