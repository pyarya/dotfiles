#!/usr/bin/env bash
declare newname
newname="$(~/.configs_pointer/bin/rename_for_shell.sh "$@")"

if [[ $? -eq 0 ]]; then
  if ! ~/.configs_pointer/bin/rename_and_move.sh "$@"; then
    exit 1
  fi
  printf '%s' "$newname"
else
  exit 2
fi
