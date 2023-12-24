#!/usr/bin/env bash
# Turns on outline and turns off shadows in bsp spaces. Leaves them on for
# floating spaces

if [[ "$(yabai -m query --spaces --space | jq '.type')" =~ bsp ]]; then
  yabai -m config window_shadow off
  yabai -m config window_border on
else
  yabai -m config window_shadow on
  yabai -m config window_border off
fi


