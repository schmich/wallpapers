#!/bin/bash

function update-spotlight {
  dir=$1

  spotlight="http://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&rafb=0&ua=WindowsShellClient%2F0&disphorzres=1920&dispvertres=1080&lo=80000"

  urls=$(for i in `seq 30`; do
    curl -s "$spotlight" | jq -r '[.batchrsp.items[].item | fromjson | .ad.image_fullscreen_001_landscape.u][]'
    sleep 0.1
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
