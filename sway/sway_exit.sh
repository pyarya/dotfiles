#!/usr/bin/env bash
# Prompts for confirmation. 3 consecutive calls force exit without confirmation
declare -r CNT_FILE=~/.config/sway/sway_exit_counter
declare -ri MAX_COUNT=3

if [[ -e "$CNT_FILE" ]]; then
  declare -i count="$(cat "$CNT_FILE")"
else
  declare -i count=0
fi

(( count++ ))

if [[ $count -ge $MAX_COUNT ]]; then
  swaymsg exit
else
  echo "$count" > "$CNT_FILE"

  swaynag -t warning \
    -m 'Are you sure you want to exit sway?' \
    -Z 'Yes, exit sway' \
    "swaymsg exit"
fi

rm "$CNT_FILE" &>/dev/null
