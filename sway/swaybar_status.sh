#!/usr/bin/env bash
battery_charge() {
  if [[ -r /sys/class/power_supply/BAT0/uevent ]]; then
    cat /sys/class/power_supply/BAT0/uevent | awk '
    /POWER_SUPPLY_ENERGY_NOW=/   { split($0, a, "="); curr = a[2]; n++ }
      /POWER_SUPPLY_ENERGY_FULL=/ { split($0, a, "="); full = a[2]; n++ }

      END { if (n == 2) printf "%.1f", curr / full * 100 }
    '
  fi
}

display_brightness() {
  local x

  if command -v ddcutil &>/dev/null; then
    x="$(ddcutil getvcp 10 2>/dev/null |\
      awk 'match($0, /[0-9]+,/) { printf "%s", substr($0, RSTART, RLENGTH - 1) }')"
  fi

  if [[ -z "$x" ]]; then
    x="$(light -G | awk '{ split($0, a, "."); printf "%s", a[1] }')"
  fi

  printf "%s" "$x"
}

get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | awk '
    match($0, /[0-9]+%/) { printf "%s", substr($0, RSTART, RLENGTH - 1) }'
}

remaining_ram() {
  awk '
  /MemTotal:/     { memtotal   = $2 / 1024**2 }
  /MemAvailable:/ { mavailable = $2 / 1024**2 }

  END {
    used = memtotal - mavailable
    printf "%0.1fG / %.1fG", used, memtotal - used
  }
' /proc/meminfo
}

network_info() {
  local IP
  # want to read the output of this command somehow and print it.
  iw dev wlan0 info | grep -i ssid | awk '{ split($0, a, " "); printf "%s ", a[2] }'

  IP=$(ip a show wlan0 | awk 'match($0, /inet (.*)(\/)/, ip) { print ip[1]}')

  if [[ -z "$IP" ]] then
    printf "IPV4: N/A"
  else
    printf "%s" "$IP"
  fi

}


ramu="$(remaining_ram)"
brightness="$(display_brightness)"
volume="$(get_volume)"
charge="$(battery_charge)"
time="$(date +'%d %a %l:%M %p' | awk '{ gsub(/ +/, " "); print }')"
ssid="$(network_info)"

output=''

[[ -z "$ssid" ]] || output+="${ssid} | "
[[ -z "$brightness" ]] || output+="${brightness}cd | "
[[ -z "$volume" ]] || output+="${volume}dB | "
[[ -z "$charge" ]] || output+="[${charge}%] | "
[[ -z "$ramu" ]] || output+="${ramu} | "
[[ -z "$time" ]] || output+="$time"

printf "%s" "$output"
