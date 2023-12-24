#!/bin/bash
# Play MacOS system error sound: System Preferences -> Sound -> Sound Effects

if [[ $(uname) == 'Darwin' ]]; then
    afplay $(defaults read .GlobalPreferences.plist \
        | awk '/sound.beep.sound"/ { gsub(/(.*= ")|(";)/, ""); print }')
fi

# vim: set syntax=bash ff=unix:
