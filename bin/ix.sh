#!/usr/bin/env bash
# Pastebin for terminal. Copies the paste's URL to the clipboard
#
# ix.io isn't very responsive, so it may appear to freeze for a few seconds
#
# Use with visual selection in vim:
# <range>!ix.sh
#
# Lifted from: https://exobrain.sean.fish/vim/magic_wands/

if [[ $1 =~ '-h' ]]; then
  declare -r name="$(basename "$0")"

  cat <<EOF
Paste text onto ix.io. Corresponding ix.io url is copied to the clipboard

EXAMPLES:
    echo "Sample save" | $name
    wl-paste | $name
    pbpaste | $name
    cat | $name
EOF
  exit 0
fi

readonly STDIN="$(cat)"
cat >> /tmp/ix.log <<<"${STDIN}"

declare url="$(curl -s -F 'f:1=<-' http://ix.io <<<"${STDIN}")" || {
  play_error_sound
  exit 1
}

if [[ "$(uname -s)" == 'Darwin' ]]; then
  printf '%s' "${url}" | pbcopy
  osascript -e 'display notification "'"URL: ${url}"'" with title "Vim" subtitle "Copied to clipboard"'
else
  printf '%s' "${url}" | wl-copy
  notify-send -t 2000 'Vim' 'Copied ix url to wl-clipboard'
fi

# vim: set syn=bash ff=unix:
