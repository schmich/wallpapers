#!/bin/bash

function update-manifest() {
  sha1=$1
  url=$2
  date=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

  entry=`echo '{}' | jq --arg sha1 "$sha1" --arg url "$url" --arg date "$date" '[.sha1=$sha1|.url=$url|.date=$date]'`

  manifesttmp=`mktemp`
  echo "$entry" | cat "$manifest" - | jq -s add - > "$manifesttmp"
  mv "$manifesttmp" "$manifest"
}

function store-image() {
  dest=$1
  url=$2
  
  if [ ! -d "$dest" ]; then
    return
  fi

  manifest="$dest/manifest.json"
  if [ ! -f "$manifest" ]; then
    echo '[]' > "$manifest"
  fi

  exists=`jq --arg url "$url" '.[] | select(.url==$url)' "$manifest"`
  if [ ! -z "$exists" ]; then
    echo "Already have $url (URL)."
    return
  fi

  echo "Downloading $url."
  imagetmp=`mktemp`
  curl -s -o "$imagetmp" "$url"

  if [ $? -ne 0 ]; then
    echo "Failed to download image."
    return
  fi

  sha1=`sha1sum "$imagetmp" | cut -d' ' -f1`

  exists=`jq --arg sha1 "$sha1" '.[] | select(.sha1==$sha1)' "$manifest"`
  if [ ! -z "$exists" ]; then
    echo "Already have $url (sha1)."
    update-manifest "$sha1" "$url"
    return
  fi

  extension=`echo $url | rev | cut -d/ -f1 | rev | cut -d# -f1 | cut -d? -f1 | rev | cut -d. -f1 | rev`
  mv "$imagetmp" "$dest/$sha1.$extension"

  update-manifest "$sha1" "$url"
}
