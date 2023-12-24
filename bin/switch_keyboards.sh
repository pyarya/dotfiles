#!/usr/bin/env bash
# Usage:  ./switch_keyboards.sh [args]
#
# Args:
#   console    Loads the console version
#   mac        Loads the Mac keyboard version
#   pc         Loads the standard keyboard version
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
  console    Only remaps capslock to ctrl
  help       Print this message and exit
HELP
}

if ! command -v xremap &>/dev/null; then
  printf "xRemap not found\nLayouts were not switched\n"
  exit 1
fi

case "$(echo "$1" | awk '{print tolower($0)}')" in
  console)
    ln -sf ~/.config/xremap/config_console.yml ~/.config/xremap/config.yml
    echo "Switching to minimal console remapping"
    ;;
  mac)
    ln -sf ~/.config/xremap/config_mac.yml ~/.config/xremap/config.yml
    echo "Switching to mac layout :: ALT | SUPER | SPACE"
    ;;
  pc)
    ln -sf ~/.config/xremap/config_standard.yml ~/.config/xremap/config.yml
    echo "Switching to standard layout :: SUPER | ALT | SPACE"
    ;;
  *)
    print_help
    exit 0
    ;;
esac

systemctl restart xremap
sleep 2
