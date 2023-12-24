#!/usr/bin/env bash
# Locks the screen and lowers-brightness. Restores brightness on unlock
declare brightness_lvl;

if ! command -v ddcutil &>/dev/null && command -v light &>/dev/null; then
  lvl="$(light -G)"

  (swaylock; light -S "$lvl") &
  light -S 1
elif command -v ddcutil &>/dev/null; then
  lvl="$(ddcutil getvcp 10 | awk '{
    gsub(" ","");  # Remove spaces
    split($0, a, "=");
    split(a[2], a, ",");
    print a[1]
  }')"

  if [[ "$lvl" =~ ^[0-9]+$ ]]; then
    (swaylock; ddcutil setvcp 10 "$lvl") &
    ddcutil setvcp 10 1
  else
    swaylock
  fi
else
  swaylock
fi


