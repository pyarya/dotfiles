#!/usr/bin/env bash
# Args:
#   1: Direction of stack
declare stack=""
declare selected_window="$(yabai -m query --windows --space |\
                           jq '.[] | select(.focused == 1) .id')"

if ! yabai -m window --focus "$1"; then
  echo "Cannot focus $1" >&2
  play_error_sound
  exit 1
fi


if [[ -n "${selected_window}" ]]; then
    yabai -m window --stack "${selected_window}"
    yabai -m window --focus "${selected_window}"
else
  echo "Window id ${selected_window} not found..." >&2
  case "$1" in
    west)  yabai -m window --stack east ;;
    east)  yabai -m window --stack west ;;
    north) yabai -m window --stack south ;;
    south) yabai -m window --stack north ;;
  esac
fi
