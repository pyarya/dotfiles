#!/usr/bin/env bash
# Look through `upower --dump` to set the battery path variable
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

upower --dump | awk '
BEGIN { b = "'"$BATTERY_PATH"'"; t=0 }

t && (match($0, /Device:/) || match($0, /Daemon:/)) {
  exit
}

match($0, b) { t=1 }

t && match($0, /energy:/) {
  split($0,a," ")
  energy = a[2]
}

t && match($0, /percentage:/) {
  split($0,a," ")
  percent = a[2]
}

t && match($0, /state:/) {
  split($0,a," ")
  state = a[2]
}

END {
  print "'"${system_name},${current_time},"'"energy","percent","state
}' >> "$WRITE_PATH"
