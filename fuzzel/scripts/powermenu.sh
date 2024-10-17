#!/bin/bash

SELECTION="$(printf " lock\n󰍃 logout\n󰤄 suspend\n reboot\n reboot[UEFI]\n󰤆 poweroff" | fuzzel --dmenu -l 6 -p "󰐦 " --no-exit-on-keyboard-focus-loss --config=$HOME/.config/fuzzel/scripts/keys.ini)"

case $SELECTION in
	*"lock")
		~/.config/sway/brightness_lock.sh;;
	*"suspend")
		systemctl suspend;;
	*"logout")
		swaymsg exit;;
	*"reboot")
		systemctl reboot;;
	*"reboot[uefi]")
		systemctl reboot --firmware-setup;;
	*"poweroff")
		systemctl poweroff;;
esac
