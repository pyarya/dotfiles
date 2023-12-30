#!/usr/bin/env bash
# Warning: Many other files in these configs depend on this script. Do not
# rename it or remove it from ~/.configs_pointer/bin/ unnecessarily
__print_color_help() {
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

$(__print_current_colors)
HELP
}


# Detect current alacritty color scheme
declare COLOR_SCHEME
declare -r ALACRITTY_CONF=~/.config/alacritty/alacritty.toml
declare -r VIMIV_CONF=~/.config/vimiv/vimiv.conf

if [[ -r "$ALACRITTY_CONF" ]]; then
  COLOR_SCHEME="$(awk -F/ '/^import =/ {print substr($NF, 1, length($NF)-7)}' "$ALACRITTY_CONF")"
else
  COLOR_SCHEME='base16-gruvbox-dark-pale'
fi

# Returns one of "light" or "dark"
__query_color_tone() {
  case "$COLOR_SCHEME" in
    base16-gruvbox-dark-pale)  echo 'dark' ;;
    base16-gruvbox-light-hard) echo 'light' ;;
    base16-dracula)            echo 'dark' ;;
    base16-github)             echo 'light' ;;
    *) echo 'dark' ;;
  esac
}

__print_current_colors() {
  echo "Current color scheme: $COLOR_SCHEME"
  echo "Current color tone:   $(__query_color_tone)"
}

# Changes the colors and sets environment variables
__change_colors_to() {
  COLOR_SCHEME="$1"
  __change_alacritty_colors
  __change_vimiv_colors
  __print_current_colors
}

# Updates the color scheme for alacritty. Best with alacritty's live reload
__change_alacritty_colors() {
  local tmp="$(mktemp)"
  awk \
    -v c="$COLOR_SCHEME" \
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
    "$ALACRITTY_CONF" \
    > "$tmp"

  mv -f "$tmp" "$ALACRITTY_CONF"
}

__change_vimiv_colors() {
  if [[ -w "$VIMIV_CONF" ]]; then
    local tmp="$(mktemp)"
    awk -v c="$COLOR_SCHEME" '/^\s*style = /{ $3=c } 1' "$VIMIV_CONF" > "$tmp"
    mv -f "$tmp" "$VIMIV_CONF"
  fi
}

case "$1" in
  -t | --tone) __query_color_tone ;;
  -c | --colorscheme) echo "$COLOR_SCHEME" ;;
  -q | --query) __print_current_colors ;;
  -h | --help)  __print_color_help ;;
  light | gruvboxlight) __change_colors_to "base16-gruvbox-light-hard" ;;
  dracula)              __change_colors_to "base16-dracula" ;;
  github)               __change_colors_to "base16-github" ;;
  dark | gruvboxdark)   __change_colors_to "base16-gruvbox-dark-pale" ;;
  *) __print_color_help ;;
esac
