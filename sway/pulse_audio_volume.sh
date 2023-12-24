#!/usr/bin/env bash
# Simple wrapper around pactl to keep volume in [0,100]% range. Optionally
# plays an indicator sound after changing the volume
#
# Args:
#  1: Change amount in percent. An integer
#  2: Sound file to play. No sound is played if omitted or invalid
declare -r ADJUST="$1"
declare -r NOTIFY_SOUND="$2"

declare -r MAX_VOLUME="100"

set_volume() {
  if ! pactl set-sink-volume @DEFAULT_SINK@ "${1}%"; then
    printf "Failed to set default sink volume\n" >&2
    exit 1
  fi

  [[ -z "$NOTIFY_SOUND" ]] || play_notify_sound "$NOTIFY_SOUND"
}

play_notify_sound() {
  if ! [[ -r "$1" ]]; then
    printf "File '%s' is not readable" "$1" >&2
    exit 1
  fi

  if command -v ffmpeg &>/dev/null; then
    ffplay -nodisp -autoexit -v error "$1"
  elif command -v afplay &>/dev/null; then
    afplay "$1"
  else
    printf "Failed to find sound player for volume indication sound\n" >&2
  fi
}

if ! [[ "$ADJUST" =~ ^-?[0-9]+$ ]]; then
  printf "No volume change amount provided\n" >&2
  exit 1
fi

readonly curr_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '
    match($0, /[0-9]+%/) { printf "%s", substr($0, RSTART, RLENGTH - 1) }')

if ! [[ "$curr_volume" =~ ^[0-9]+$ ]]; then
  printf "Failed to find default sink's volume: %s\n" "$curr_volume" >&2
fi

declare -ir new_volume=$(($curr_volume + $ADJUST))

printf "Changing volumes from %d -> %d\n" "$curr_volume" "$new_volume" >&2
if [[ "$new_volume" -gt "$MAX_VOLUME" ]]; then
  set_volume "$MAX_VOLUME"
elif [[ "$new_volume" -lt "0" ]]; then
  set_volume "0"
else
  set_volume "$new_volume"
fi
