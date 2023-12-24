#!/usr/bin/env bash
# Look through `upower --dump` to set this variable
declare -r BATTERY_PATH="$1"
declare -r WRITE_PATH="$2"

if [[ $# -ne 2 ]]; then
  echo "USAGE: $(basename "$0") <battery-path> <csv-path>"
  exit 1
elif [[ ! -e "$WRITE_PATH" && -d "$(dirname "$WRITE_PATH")" ]]; then
  echo "hostname,time,charge,percent,state" > "$WRITE_PATH"
fi

declare -r tmp_file="$(mktemp)"

upower --dump > "$tmp_file"

declare system_name="$(hostname)"
declare current_time="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
declare current_power="$(cat "$tmp_file" | awk '
BEGIN { b = "'"$BATTERY_PATH"'"; t=0 }

match($0, b) { t=1 }

t && match($0, /energy:/) {
  split($0,a," ")
  print a[2]
  exit
}')"
declare current_percentage="$(cat "$tmp_file" | awk '
BEGIN { b = "'"$BATTERY_PATH"'"; t=0 }

match($0, b) { t=1 }

t && match($0, /percentage:/) {
  split($0,a," ")
  print a[2]
  exit
}')"
declare current_state="$(cat "$tmp_file" | awk '
BEGIN { b = "'"$BATTERY_PATH"'"; t=0 }

match($0, b) { t=1 }

t && match($0, /state:/) {
  split($0,a," ")
  print a[2]
  exit
}')"

echo "$system_name,$current_time,$current_power,$current_percentage,$current_state" >> "$WRITE_PATH"
