#!/bin/bash

function sync-to-imgur() {
  dir=$1
  credentials_file=$2

  imgur_album_id=`jq -r '.album_id' "$credentials_file"`
  imgur_client_id=`jq -r '.client_id' "$credentials_file"`
  imgur_access_token=`jq -r '.access_token' "$credentials_file"`

  echo "Sync $dir to Imgur."

  album_info=`curl -s -H "Authorization: Client-ID $imgur_client_id" "https://api.imgur.com/3/album/$imgur_album_id/images"`
  if [ $? -ne 0 ]; then
    echo "Failed to get Imgur album info ($imgur_album_id)."
    return
  fi

  local_images=`find "$dir" -type f -iname '*.png' -o -iname '*.jpg' -printf "%f\n"`
  imgur_images=`echo "$album_info" | jq -r '.data[].title'`
  upload=`comm -23 <(echo "$local_images" | sort) <(echo "$imgur_images" | sort)`

  for name in $upload; do
    echo "Uploading $name."
    curl -s -H "Authorization: Bearer $imgur_access_token" -X POST -F"album=$imgur_album_id" -F"type=file" -F"image=@$dir/$name" -F"title=$name" "https://api.imgur.com/3/image" >/dev/null
    if [ $? -ne 0 ]; then
      echo "Failed to upload $name."
    fi
  done
}

function refresh-imgur-access-token() {
  credentials_file=$1

  client_id=`jq -r '.client_id' "$credentials_file"`
  client_secret=`jq -r '.client_secret' "$credentials_file"`
  refresh_token=`jq -r '.refresh_token' "$credentials_file"`

  echo "Refresh Imgur access token."

  response=`curl -s -X POST -d"refresh_token=$refresh_token" -d"client_id=$client_id" -d"client_secret=$client_secret" -d"grant_type=refresh_token" https://api.imgur.com/oauth2/token`
  if [ $? -ne 0 ]; then
    echo "Failed to refresh Imgur access token."
    return
  fi

  new_access_token=`echo "$response" | jq -r '.access_token'`
  new_refresh_token=`echo "$response" | jq -r '.refresh_token'`

  credentials_tmp=`mktemp` 
  jq --arg refresh_token "$new_refresh_token" --arg access_token "$new_access_token" '.refresh_token=$refresh_token|.access_token=$access_token' "$credentials_file" > "$credentials_tmp"
  mv "$credentials_tmp" "$credentials_file"

  echo "Access token refreshed."
}
