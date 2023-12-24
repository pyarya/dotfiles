#!/usr/bin/env bash
# Send a key into mpv. Parses the mpv input.conf to do so
# Sends to pipe named /tmp/mpvfifo unless otherwise specified
#
# Args:
#  1: Key to send
#  2: [Optional] fifo
shopt -s lastpipe

declare -r KEY="$1"
declare -r FIFO="${2:-/tmp/mpvfifo}"
declare CMD=""

awk -v k="$KEY " '
BEGIN { split(k, key, "") }

{
  is_key = 1
  split($0, a, "");

  for (i = 1; i <= length(k); i++)
    is_key = is_key && (a[i] == key[i]);

  if (is_key) {
    if (match($0, /#/))
      print substr($0, length(k)+1, RSTART - length(k) - 1);
    else
      print substr($0, length(k)+1);
  }
}' ~/.config/mpv/input.conf | read -r CMD

echo "$CMD" | socat "$FIFO" -
