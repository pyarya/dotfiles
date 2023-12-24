#!/usr/bin/env bash
if [[ ! -f "$1" ]]; then
  cat <<HELP
Removes the tailing new line character in a file
$(basename $0) <file>
HELP

  exit 1
fi

declare -r tmp="$(mktemp)"

if [[ "$(tail -c 1 "$1" | wc -l)" = 1 ]]; then
  head -c -1 "$1" > "$tmp"
  mv -f "$tmp" "$1"
fi
