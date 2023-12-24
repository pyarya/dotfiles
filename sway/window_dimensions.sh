#!/usr/bin/env bash
# Gets a slurp-like output for the focused window with sway borders cropped
declare -a a=( $(swaymsg -t get_tree | jq  '..
  | (.nodes? // empty)[] | select(.focused==true)
  | .rect.x, .window_rect.x, .rect.y, .window_rect.y, .window_rect.width, .window_rect.height, .rect.height') )

if [[ ${#a[@]} -eq 0 ]]; then
  a=( $(swaymsg -t get_tree | jq  '..
    | (.floating_nodes? // empty)[] | select(.focused==true)
    | .rect.x, .window_rect.x, .rect.y, .window_rect.y, .window_rect.width, .window_rect.height, .rect.height') )
fi

if [[ ${#a[@]} -ne 7 ]]; then
  printf 'Failed to find window\n'
  exit 1
elif [[ $((${a[5]} + ${a[3]})) -eq ${a[6]} ]]; then
  printf '%d,%d %dx%d\n' \
    "$((${a[0]} + ${a[1]}))" \
    "${a[2]}" \
    "${a[4]}" \
    "$((${a[5]} - ${a[3]}))"
else
  printf '%d,%d %dx%d\n' \
    "$((${a[0]} + ${a[1]}))" \
    "$((${a[2]} + ${a[3]}))" \
    "${a[4]}" \
    "${a[5]}"
fi
