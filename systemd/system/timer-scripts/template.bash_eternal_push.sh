#!/usr/bin/env bash
# Backup the .bash_eternal_history file of select users. Files should all be
# named in the format
#
# ${hostname}_${user}_bash_hist

# Remote is being read out of ${remote_user}'s .ssh/config
# Do not leave a password on the ssh key! Use a restricted user instead

declare -r remote=mirrorside
declare -r remote_user=emiliko
declare -r backup_p='/home/emiliko/safe/bash_eternal_backups'
declare -ar backups=(\
 /home/emiliko/.bash_eternal_history
   "${backup_p}/waybook_emiliko_bash_hist"
 /root/.bash_eternal_history
   "${backup_p}/waybook_root_bash_hist"
)

# Check for internet
if ! curl -m 3 archlinux.org &>/dev/null; then
  echo "Failed to connect to archlinux.org in 3 seconds. No backup was made" >&2
  exit 1
fi

# Make the directory
sudo -u "$remote_user" bash <<CMD
ssh "$remote" "mkdir -p ${backup_p}"
CMD

# Copy over the files
for ((i = 0; i < ${#backups[@]}; i += 2)); do
  declare from="${backups[i]}"
  declare to="${backups[i+1]}"

  # Make an open tmp file
  declare tfile="$(mktemp)"
  cp -f "$from" "$tfile"
  chmod 666 "$tfile"

  sudo -u "$remote_user" bash <<CMD
scp "$tfile" "${remote}:${to}"
echo "Sucessfully transfered ${to}"
CMD
done
