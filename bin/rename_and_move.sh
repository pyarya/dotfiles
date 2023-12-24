#!/usr/bin/env bash
print_help() {
  cat <<HELP
Moves the file to a more unix-friendly name

USAGE: $(basename "$0") <original-path>

See rename_for_shell.sh for more details on the renaming mechanics. Does not
work if the directory also has a bad name

EXAMPLES:
  fd -x rename_and_move.sh
HELP
}

if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  print_help
  exit 1
else
  mv -n "$@" "$(~/.configs_pointer/bin/rename_for_shell.sh "$@")" &>/dev/null
fi
