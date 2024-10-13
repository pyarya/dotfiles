#!/usr/bin/env bash
declare -r syncpath='/dev/shm/refreshrate.log'
declare -i lasttime=0
declare -ir curr_time="$(date +%s)"

if [[ -f "$syncpath" ]]; then
  lasttime="$(cat "$syncpath")";
fi

if [[ $((curr_time - lasttime)) -lt 3 ]]; then
  exit 0
else
  echo "$curr_time" > "$syncpath"
fi

mode="$(swaymsg -t get_outputs | jq '.[0].current_mode.refresh')"

if [[ $mode -eq 60000 ]]; then
  echo "Setting 120Hz $mode"
  swaymsg output eDP-1 mode 3072x1920@120.002Hz
else
  echo "Setting 60Hz $mode"
  swaymsg output eDP-1 mode 3072x1920@60.000Hz
fi

mode="8"
