#!/usr/bin/env bash
# Sends an encrypted email attachment of the bash eternal history directory

declare -r backup_p=/home/emiliko/safe/bash_eternal_backups
declare -r email_msg="$(mktemp)"
declare -r encry_file="$(mktemp)"
chmod 666 "$encry_file"

sudo -u emiliko bash <<CMD
cd "${backup_p}/.." || exit 1
tar czf - "$(basename "$backup_p")" | gpg -e -r emiliko@mami2.moe > "$encry_file"
CMD

declare -r MIMEType="$(file --mime-type "$encry_file" | sed 's/.*: //')"
declare -r attach_name="bash_full_backup_$(date +%s).tgz"

cat <<EMAIL >"$email_msg"
Dear Emiliko,

I thought you might like a backup of your .bash_eternal_history files from all
devices I can access. I used $(hostname) as a central repository to back them
up. Hope you enjoy them!

yours (truly),
Systemd
EMAIL

curl --silent --ssl-reqd \
  --url 'smtps://smtp.fastmail.com:465' \
  --user 'emiliko%40mami2.moe:<password-here>' \
  --mail-from "systemd@mami2.moe" \
  --mail-rcpt 'emiliko@cs.ox.ac.uk' \
  --mail-rcpt 'emiliko@mami2.moe' \
  -F '=(;type=multipart/mixed' \
  -F "=$(cat "$email_msg");type=text/plain" \
  -F "file=@${encry_file};type=${MIMEType};encoder=base64" \
  -F '=)' \
  -H "From: Systemd-chan <systemd@mami2.moe>" \
  -H "Subject: Your weekly bash backup" \
  -H "To: Emiliko Mirror <emiliko@cs.ox.ac.uk>" \
  -H "CC: Emiliko Mirror <emiliko@mami2.moe>" \
  -H "Date: $(date)"
