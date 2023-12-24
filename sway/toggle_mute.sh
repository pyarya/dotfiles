#!/usr/bin/env bash
# Toggles between muted and the previous volume. Uses `pactl`
#
# EXAMPLES:
#   ./toggle_mute.sh  # Default toggles based on current volume
#   ./toggle_mute.sh mute
#   ./toggle_mute.sh unmute
declare -r vol="$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{ printf $5 }')"
declare -r store=~/.config/sway/toggle_mute_data

# Saves the current non-zero volume and mutes
mute_and_save () {
  [[ "$vol" == "0%" ]] || printf "%s" "$vol" > "$store"
  pactl set-sink-volume @DEFAULT_SINK@ 0%
}

# Restores previous volume, or sets to 10%
unmute () {
  if [[ "$vol" == "0%" && "$(head "$store")" =~ [0-9]+% ]]; then
    pactl set-sink-volume @DEFAULT_SINK@ "$(head "$store")"
  else
    pactl set-sink-volume @DEFAULT_SINK@ 10%
  fi
}

# Main ======
case "$1" in
  mute)
    mute_and_save
    ;;
  unmute)
    unmute
    ;;
  *)
    if [[ "$vol" == "0%" ]]; then
      unmute
    else
      mute_and_save
    fi
    ;;
esac

ffplay -nodisp -autoexit -v error ~/.config/sway/volume_change_sound.mp3
