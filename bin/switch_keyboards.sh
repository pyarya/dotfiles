#!/usr/bin/env bash
# Usage:  ./switch_keyboards.sh [args]
#
# Args:
#   console    Loads the console version
#   mac        Loads the Mac keyboard version
#   pc         Loads the standard keyboard version
#   fn         Loads the version for a standard keyboard without an fn row
#
# Explanation =========
# Mac keyboards place their super key adjacent to the spacebar, while standard
# keyboards put alt in that spot:
#
# Macbook:       Shift | z
#                Fn | Ctrl | Alt | Super | Space
#
# Standard:      Shift | z
#                Fn | Ctrl | Super | Alt | Space
#
# To preserve consistency when switching keyboards, two versions of the same
# xremap config.yml are available. This script toggles between the two
#
# Xremap can also run in a non-graphical console. For this we don't need to
# remap Super and Alt, though we still need other keys, like capslock. An
# optional "console" argument can be passed to this script to load
# config_console.yml
print_help() {
  cat <<HELP
Switches keyboard modifer keys between Mac and PC layouts

USAGE: $(basename "$0") <ARG>

ARGS:
  mac        Remaps assuming super is adjacent to the spacebar
  pc         Remaps assuming alt is adjacent to the spacebar
  fn         Remaps assuming pc + no fn row
  console    Only remaps capslock to ctrl
  help       Print this message and exit
HELP
}

if ! command -v xremap &>/dev/null; then
  printf "xRemap not found\nLayouts were not switched\n"
  exit 1
fi

declare path sw_type="$1"

case "$(echo "$sw_type" | awk '{print tolower($0)}')" in
  console)
    ln -sf ~/.config/xremap/config_console.yml ~/.config/xremap/config.yml
    ;;
  mac)
    ln -sf ~/.config/xremap/config_mac.yml ~/.config/xremap/config.yml
    ;;
  pc | standard)
    ln -sf ~/.config/xremap/config_standard.yml ~/.config/xremap/config.yml
    ;;
  fn | small | mini)
    ln -sf ~/.config/xremap/config_no_fn.yml ~/.config/xremap/config.yml
    ;;
  *)
    if [[ -n "$1" ]]; then
      print_help
      exit 0
    fi
    ;;
esac

if path="$(basename "$(realpath ~/.config/xremap/config.yml)")"; then
  case "$path" in
    config_console.yml)
      echo "Using minimal console remapping";;
    config_mac.yml)
      echo "Using mac layout :: ALT | SUPER | SPACE";;
    config_standard.yml)
      echo "Using standard layout :: ALT | SUPER | SPACE";;
    config_no_fn.yml)
      echo "Using standard no-fn row layout :: ALT | SUPER | SPACE";;
    *)
      echo "Using unidentified layout";;
  esac
else
  echo "xremap config path not found"
fi

sudo /usr/bin/systemctl restart xremap.service
sleep 2
