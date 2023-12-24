#!/usr/bin/env bash
if [[ "$(cat /proc/acpi/button/lid/LID0/state | awk '{print $2}')" == closed ]]
then
  sudo /usr/local/bin/send_sleep_email.sh
  systemctl suspend
fi
