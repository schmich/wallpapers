#!/bin/bash

source ./imgur.sh

sync-to-imgur "wallpapers" "imgur.json"
refresh-imgur-access-token "imgur.json"
