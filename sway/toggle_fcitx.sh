#!/usr/bin/env bash
CURRENT_ID="$(pgrep ^fcitx5$)"

if [[ -n "$CURRENT_ID" ]]; then
  kill "$CURRENT_ID"
else
  fcitx5 -d --replace
fi
