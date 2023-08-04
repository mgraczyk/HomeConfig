#!/bin/sh
#
# Setup a new linux machine

# Install packages
sudo apt install i3

# Setup i3 frame dragging
python3 -m pip install --user -r .config/i3/i3-chrome-tab-dragging/requirements.txt
