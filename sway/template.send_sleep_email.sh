#!/usr/bin/env bash
declare -r TFILE="$(mktemp)"

cat <<EMAIL > "$TFILE"
From: Systemd-chan <systemd@mami2.moe>
To: Emiliko Mirror <emiliko@mami2.moe>
Subject: Sleep triggered on $(hostname)
Date: $(date)

Dear Emiliko,

$(hostname) went to sleep @ $(date)

============================== Battery ==============================
$(battery_status.sh)
=====================================================================

yours (truly),
Systemd
EMAIL

curl --silent --ssl-reqd \
  --url 'smtps://smtp.gmail.com:465' \
  --user 'systemd%40mami2.moe:app_password_here' \
  --mail-from 'systemd@mami2.moe' \
  --mail-rcpt 'emiliko@mami2.moe' \
  --upload-file "$TFILE"
