#!/usr/bin/env bash
# Backup the .bash_eternal_history file of select users. Files should all be
# named in the format
#
# ${hostname}_${user}_bash_hist

declare -r backup_p=/home/emiliko/safe/bash_eternal_backups
declare -r backup_user=emiliko

mkdir -p "$backup_p"

declare -ar backups=(\
 /home/emiliko/.bash_eternal_history
   "${backup_p}/mirrorside_emiliko_bash_hist"
 /root/.bash_eternal_history
   "${backup_p}/mirrorside_root_bash_hist"
)

for ((i = 0; i < ${#backups[@]}; i += 2)); do
  declare from="${backups[i]}"
  declare to="${backups[i+1]}"

  rsync "$from" "$to"
  chmod 400 "$to"
  chown "$backup_user" "$to"
  chgrp "$backup_user" "$to"
done
