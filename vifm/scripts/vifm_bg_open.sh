#!/usr/bin/env bash
print_help() {
  cat <<HELP
Open given files in backgrounded programs, preferably using GUI apps and tmux

Intended for use with vifm + tmux
HELP
}

test -z "${SWAYSOCK+x}"
declare -r is_gui=$?

requires_gui_error() {
  printf 'Sway not running. Will not open gui apps\n' >&2
  exit 1
}

open_pdf() {
  zathura "$1" &
}

open_image() {
  imv "$1" &
}

open_av_media() {
    local has_video="$(ffprobe -hide_banner "$1" 2>&1 | awk '/Stream.+Video/')"

    if [[ -n "$TMUX" && -z "$has_video" ]] || [[ ! $is_gui && -n "$TMUX" ]]; then
      tmux split-window -h
      sleep .2  # Let bash login, otherwise command won't get sent
      tmux send-keys "mpv $1" Enter
    elif [[ $is_gui ]]; then
      mpv --force-window "$1" &>/dev/null &
    fi
}

open_webpage() {
  chromium "$1" &>/dev/null &
}

open_vim() {
    tmux new-window -c "#{pane_current_path}"
    sleep .2  # Let bash login, otherwise command won't get sent
    tmux send-keys "vi $1" Enter
}

open_file() {
  case "${1##*.}" in
    pdf)
      if [[ $is_gui ]]; then
        open_pdf "$1"
      else
        requires_gui_error
      fi
      ;;
    avif|icns|jpeg|jpg|png|webp)
      if [[ $is_gui ]]; then
        open_image "$1"
      else
        requires_gui_error
      fi
      ;;
    mkv|mp3|mp4|webm)
      open_av_media "$1"
      ;;
    html)
      if [[ $is_gui ]]; then
        open_webpage "$1"
      else
        requires_gui_error
      fi
      ;;
    *)
      if [[ -n "$TMUX" && -f "$1" && "$(stat -c%s "$1")" -le 1000000 ]]; then
        open_vim "$1"
      fi
      ;;
  esac
}

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
