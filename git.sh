#!/bin/bash

ssh-agent bash -c "ssh-add bing-wallpapers-key && git $*"
