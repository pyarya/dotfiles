#!/usr/bin/env bash
# Look into /sys/class/power_supply for your battery-name. It's one of the
# symlinks

declare -r battery_name="$1"
declare -r write_path="$2"

if [[ $# -ne 2 ]]; then
  cat <<HELP
log_battery systemd.timer v2.1

USAGE: $(basename "$0") <battery-name> <csv-path>

EXAMPLES:
    $(basename "$0") BAT0 /home/emiliko/loggers/battery.csv
HELP
  exit 1
elif [[ ! -e "$write_path" && -d "$(dirname "$write_path")" ]]; then
  echo "hostname,time,charge,charge_full,percent,state,energy_rate" > "$write_path"
fi

declare -r $(xargs -0 < "/sys/class/power_supply/${battery_name}/uevent")

awk \
  -v hostname="$(hostname)" \
  -v time="$(date -u +"%Y-%m-%d %H:%M:%S UTC")" \
  -v state="$POWER_SUPPLY_STATUS" \
  -v a="$POWER_SUPPLY_CHARGE_NOW" \
  -v b="$POWER_SUPPLY_CHARGE_FULL" \
  -v c="$POWER_SUPPLY_CHARGE_FULL_DESIGN" \
  -v d="$POWER_SUPPLY_VOLTAGE_NOW" \
  -v e="$POWER_SUPPLY_CURRENT_NOW" \
  -v f="$POWER_SUPPLY_VOLTAGE_MIN_DESIGN" \
'
BEGIN {
  printf "%s,%s,", hostname, time
  printf "%0.4f,", a*f/10**12  # Charge in Wh
  printf "%0.4f,", b*f/10**12  # Charge when full in Wh
  printf "%0.2f%%,", a/b*100   # Battery capacity in percent
  printf "%s,", state
  # Energy rate in W is always absolute, so use state to determine +/-
  printf "%0.4f\n", e*d/10**12
}
' | awk '{print tolower($0)}' >> "$write_path"
