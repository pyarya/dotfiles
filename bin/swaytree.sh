#!/usr/bin/env bash
i=0

swaymsg -t get_tree | jq '.nodes[1].nodes[].representation' | tr -d '"' | \
while read ln; do
  space_num="$(swaymsg -t get_tree | jq '.nodes[1].nodes['"$i"'].name' | tr -d '"')"

  printf "Workspace %s :: %s\n" "$space_num" "$ln"

  i=$(( i + 1 ))
  printf "%s" "$ln" | sway_tree 2>/dev/null
done
