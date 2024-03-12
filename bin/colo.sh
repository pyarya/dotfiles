#!/usr/bin/env bash
#
# This script changes the color scheme for the following apps:
#  - Alacritty in ~/.configs_pointer/alacritty/alacritty.toml
#  - Vim (indirectly, vim calls this script to determine its own colors)
#  - Vimiv in ~/.configs_pointer/vimiv/vimiv.conf
#  - Vifm (indirectly like vim)
#  - Tmux (passive)
#  - Bash (passive)
#
# Warning: Many other files in these configs depend on this script. Do not
# rename it or remove it from ~/.configs_pointer/bin/ unnecessarily
print_color_help() {
  cat <<HELP
Changes the color scheme in vim, vifm, vimiv, bash, tmux, and alacritty

Flags:
  -q, --query        Print the current color scheme and exit
  -c, --colorscheme  Print the current color scheme and exit
  -t, --tone         Print the current tone (dark|light) and exit
  -h, --help         Print this message and exit

Available colors:
  gruvboxdark  - Default dark medium contrast
  gruvboxlight  - Light medium contrast
  dracula - High contrast dark
  github  - High contrast white

Example:
    colo.sh gruvboxdark
    colo.sh --colorscheme

$(print_current_colors)
HELP
}

query_color_scheme() {
  if [[ -r "$ALACRITTY_CONF" ]]; then
    echo "$(awk -F/ '/^import =/ {print substr($NF, 1, length($NF)-7)}' "$ALACRITTY_CONF")"
  else
    echo 'base16-gruvbox-dark-pale'
  fi
}

query_color_tone() {
  case "$(query_color_scheme)" in
    base16-gruvbox-dark-pale)  echo 'dark' ;;
    base16-gruvbox-light-hard) echo 'light' ;;
    base16-dracula)            echo 'dark' ;;
    base16-github)             echo 'light' ;;
    *) echo 'dark' ;;
  esac
}

print_current_colors() {
  echo "Current color scheme: $(query_color_scheme)"
  echo "Current color tone:   $(query_color_tone)"
}

# Updates the color scheme for alacritty. Best with alacritty's live reload
change_alacritty_colors() {
  local -r to_color="$1"
  local -r conf_file="$2"

  local tmp="$(mktemp)"
  awk \
    -v c="$to_color" \
    '/^import =/ {
      split($0, a, "/");
      $0="";

      for (i in a) {
        if (i != length(a)) {
          $0 = $0 sprintf("%s/", a[i]);
        }
      }

      $0 = $0 c ".toml\"]"
    } 1' \
    "$conf_file" > "$tmp"

  mv -f "$tmp" "$conf_file"
}

change_vimiv_colors() {
  local -r to_color="$1"
  local -r conf_file="$2"

  local tmp="$(mktemp)"
  awk -v c="$to_color" '/^\s*style = /{ $3=c } 1' "$conf_file" > "$tmp"
  mv -f "$tmp" "$conf_file"
}

# Changes the colors and sets environment variables
change_color_scheme() {
  local -r to_color="$1"

  change_alacritty_colors "$to_color" "$ALACRITTY_CONF"
  change_vimiv_colors "$to_color" "$VIMIV_CONF"
  print_current_colors
}


##########
# Main
##########
declare -r ALACRITTY_CONF=~/.config/alacritty/alacritty.toml
declare -r VIMIV_CONF=~/.config/vimiv/vimiv.conf

case "$1" in
  -t | --tone) query_color_tone ;;
  -c | --colorscheme) echo "$(query_color_scheme)" ;;
  -q | --query) print_current_colors ;;
  -h | --help)  print_color_help ;;
  gruvboxlight) change_color_scheme "base16-gruvbox-light-hard" ;;
  dark | dracula)              change_color_scheme "base16-dracula" ;;
  light | github)               change_color_scheme "base16-github" ;;
  gruvboxdark)   change_color_scheme "base16-gruvbox-dark-pale" ;;
  *) print_color_help ;;
esac
