#!/usr/bin/env bash
print_help() {
  cat <<HELP
Opens the target file/directory in the first available browser

Usage: $(basename "$0") <file/dir>
HELP
}

declare -r page="$1"

browser_open() {
  if command -v chromium &>/dev/null; then
    chromium --incognito "$page" &>/dev/null
  elif command -v firefox &>/dev/null; then
    firefox --private-window "$page" &>/dev/null
  else
    echo "Supported browser not found"
  fi
}

if [[ -z "$page" ]]; then
  print_help
elif ! [[ -e "$page" ]]; then
  echo "Requested file does not exist"
  print_help
  exit 1
else
  browser_open "$page" & disown
fi
