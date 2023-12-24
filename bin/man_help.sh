#!/usr/bin/env bash
# `man` for programs that only support --help instead of a manpage
#
print_help() {
  cat <<HELP
Open a program's --help in vim

Usage: $(basename $0) <cli-name>

Examples:
    $(basename $0) dust
    $(basename $0) cargo
HELP
}

declare -r pgm="$1"

if command -v "$pgm" &>/dev/null; then
  "$pgm" --help | nvim -R -c 'set syn=man' --
else
  echo "Error: No command `$pgm` found"
  exit 1
fi
