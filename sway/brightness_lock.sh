#!/usr/bin/env bash
# Locks the screens and lowers-brightness. Restores brightness on unlock

# Defaults for levels when restored
declare light_restore=3
declare ddc_restore=3

# Levels when dimmed
declare -ri light_dim=1
declare -ri ddc_dim=1

get_brightness() {
  local lvl

  if command -v light &>/dev/null; then
    lvl="$(light -G)"

    if [[ $lvl =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      light_restore="$lvl"
    fi
  fi

  if command -v ddcutil &>/dev/null; then
    lvl="$(ddcutil getvcp 10 | awk '{
      gsub(" ","");  # Remove spaces
      split($0, a, "=");
      split(a[2], a, ","); print a[1]
    }')"

    if [[ $lvl =~ ^[0-9]+$ ]]; then
      ddc_restore="$lvl"
    fi
  fi
}

set_brightness() {
  local -r light_lvl="$1"
  local -r ddc_lvl="$2"

  if command -v light &>/dev/null; then
    light -S "$light_lvl"
  fi

  if command -v ddcutil &>/dev/null; then
    ddcutil setvcp 10 "$ddc_lvl"
  fi
}

swaylock &

get_brightness
set_brightness $light_dim $ddc_dim

wait %swaylock
set_brightness $light_restore $ddc_restore
