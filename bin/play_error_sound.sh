#!/usr/bin/env bash
# Play MacOS system error sound: System Preferences -> Sound -> Sound Effects
# Plays sway error sound as well

if [[ $(uname) == 'Darwin' ]]; then
  declare s="$(defaults read .GlobalPreferences.plist \
      | awk '/sound.beep.sound"/ { gsub(/(.*= ")|(";)/, ""); print }')"
  afplay "$s" &>/dev/null &
elif [[ -n ${SWAYSOCK+x} ]]; then
  ffplay -nodisp -autoexit ~/.configs_pointer/sway/error_sound.mp3 &>/dev/null &
fi
