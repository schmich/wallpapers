#!/bin/bash

ssh-agent bash -c "ssh-add wallpapers-key && git $*"
