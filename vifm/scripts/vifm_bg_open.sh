#!/usr/bin/env bash
print_help() {
  cat <<HELP
Open given files in backgrounded programs, preferably using GUI apps

Intended for use with vifm
HELP
}

open_file() {
  case "${1##*.}" in
    pdf)
      zathura "$1" &
      ;;
    avif|icns|jpeg|jpg|png|webp)
      imv "$1" &
      ;;
    mkv|mp3|mp4|webm)
      local has_video="$(ffprobe -hide_banner "$1" 2>&1 | awk '/Stream.+Video/')"

      if [[ -n "$TMUX" && -z "$has_video" ]]; then
        tmux split-window -h
        sleep .2  # Let bash login, otherwise command won't get sent
        tmux send-keys "mpv $1" Enter
      else
        mpv --force-window "$1" &>/dev/null &
      fi
      ;;
    html)
      chromium "$1" &>/dev/null &
      ;;
  esac
}

if [[ -z ${SWAYSOCK+x} ]]; then
  printf 'Sway not running. Will not open gui apps\n' >&2
  exit 1
fi

for arg in "$@"
do
  case "$arg" in
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      open_file "$arg"
      ;;
  esac
done

#swaymsg [con_mark=vifm_window] focus
