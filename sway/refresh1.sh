#!/bin/bash

# This script is called by the udev rule /etc/udev/refreshrate.rules

export SWAYSOCK="/run/user/1000/$(/bin/ls /run/user/1000 | grep sway)"
export DISPLAY=:0

case $1 in
  "connected")
    echo "connected :) @ $(date)" > /dev/shm/acstatus
    /usr/bin/swaymsg output eDP-1 mode 3072x1920@120.002Hz &>> /dev/shm/acstatus
    ;;
  "disconnected")
    echo "disconnected :( @ $(date)" > /dev/shm/acstatus
    /usr/bin/swaymsg output eDP-1 mode 3072x1920@60.000Hz &>> /dev/shm/acstatus
    ;;
  *)
    echo "unknown" > /dev/shm/acstatus
    /usr/bin/swaymsg output eDP-1 mode 3072x1920@60.000Hz &>> /dev/shm/acstatus
    ;;
esac

exit 0
