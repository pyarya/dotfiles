# Low battery notifier

# Kill already running processes
already_running="$(ps -fC 'grep' -N | grep 'battery_notif.sh' | wc -l)"
if [[ $already_running -gt 1 ]]; then
	pkill -f --older 1 'battery_notif.sh'
fi

# Get path
path="$( dirname "$(readlink -f "$0")" )"

while [[ 0 -eq 0 ]]; do
	battery_status="$(cat /sys/class/power_supply/BAT0/status)"
	battery_charge="$(cat /sys/class/power_supply/BAT0/capacity)"

	notify-send --icon="$path/battery_low.svg" "current charge:" "${battery_charge}%"

	if [[ $battery_status == 'Charging' && $battery_charge -ge 80 ]] then
		if [[ $battery_charge -ge 80 ]] then
			notify-send --icon="$path/battery_full.svg" "Battery charged: 80%" "${battery_charge}%"
			sleep 600
		elif [[ $battery_charge -ge 98 ]] then
			notify-send --icon="$path/battery_full.svg" "Battery Full" "${battery_charge}%"
			sleep 600
		fi

	if [[ $battery_status == 'Discharging' && $battery_charge -le 80 ]]; then
		if   [[ $battery_charge -le 15 ]]; then
			notify-send --icon="$path/battery_low.svg" --urgency=critical "Battery critical!" "${battery_charge}%"
			sleep 180
		elif [[ $battery_charge -le 25 ]]; then
			notify-send --icon="$path/battery_low.svg" --urgency=critical "Battery critical!" "${battery_charge}%"
			sleep 240
		elif [[ $battery_charge -le 40 ]]; then
			notify-send --icon="$path/battery_low.svg" "Battery low!" "${battery_charge}%"
			sleep 360
		elif [[ $battery_charge -le 60 ]]; then
			notify-send --icon="$path/battery_low.svg" "Battery low!" "${battery_charge}%"
			sleep 480
		else
			notify-send --icon="$path/battery_low.svg" "Battery low!" "${battery_charge}%"
			sleep 600
		fi
	else
		notify-send --urgency=critical "Battery critical!" "${battery_charge}%"
		sleep 600
	fi
done
