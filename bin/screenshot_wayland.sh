#!/usr/bin/env bash
# Take and resize screenshots on wayland
#
# Input sources: Full, selection, dimensions, latest taken screenshot
# Filters: Resize, drop-shadow
# Output sources: File, clipboard
#
# Screenshot default: .png
# Resize default: .avif
#
# Each screenshot has 1 or more input sources and 1 or more output sources. The
# image extention is determined by the output file, --extension option, or
# defaults. Regardless of extension, every screenshot is first saved as a
# lossless PNG then converted to other formats. All intermediate files are
# saved in a temporary directory set by the --tmp-dir option
#
# Setting the --tmp-dir alongside the --resize option will modify the latest
# image in that directory
print_help() {
  cat <<HELP
Take and resize screenshots on wayland

USAGE: $(basename "$1") [FLAGS] <ARG> [FILE]

FLAGS:
    -c, --clipboard  Save the screenshot to your clipboard
    -h, --help       Print this help message and exit

OPTIONS:
    -d, --drop-shadow <size> Save the screenshot with a drop-shadow on a white background
    -e, --extension <ext>    Change image extention saved
    -r, --resize <size>      Resize the latest screenshot instead of taking a new one
    -s, --size <dimensions>  Screenshot exact dimensions
    -t, --tmp-dir <dir>      Set the temporary save and resize source directory

ARGS:
    area   Takes a screenshot of an area selected by the mouse. Like cmd+shift+4
    full   Screenshots the full screen
    markup Edit latest image in swappy. Incompatible with most options

EXAMPLES:
    $(basename "$1") full ~/Pictures/elaina_bubble_tea.png
    $(basename "$1") -c area ~/Pictures/elaina_bubble_tea.png
    $(basename "$1") -c -d 10 -s '20,400 200x180' ~/Pictures/elaina_bubble_tea.png
    $(basename "$1") --resize 80% ~/Pictures/elaina_bubble_tea.webp

Saves full original copy under /tmp/screenshots_tmp/. The latest resize is
available at [FILE] or in the clipboard.

Make sure to specify --clipboard or a file path. There is no default!
HELP
}

declare CROP SHADOW IS_CLIPBOARD IS_SWAPPY OUTPUT_PATH RESIZE EXT TMP_DIR TMP_PATH
declare -r SLURP_REGEX="^[0-9]+,[0-9]+[[:space:]][0-9]+x[0-9]+$"

# Not possible to call script without 2 args
parse_args() {
  if [[ $# -eq 0 ]]; then
    print_help "$0"
    return 1
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c | --clipboard)
        IS_CLIPBOARD=true
        shift
        ;;
      -d | --drop-shadow)
        shift
        if [[ "$1" =~ ^[0-9]+x[0-9]+$ ]]; then
          SHADOW="$1"
        elif [[ "$1" =~ ^[0-9]+$ ]]; then
          SHADOW="${1}x${1}"
        else
          printf 'No size argument found for --drop-shadow option\n'
          return 2
        fi
        shift
        ;;
      -e | --extension)
        shift
        if [[ "$1" =~ ^\.[a-z0-9]+$ ]]; then
          EXT="${1:1}"
        elif [[ "$1" =~ ^[a-z0-9]+$ ]]; then
          EXT="$1"
        fi
        shift
        ;;
      -r | --resize)
        shift
        if [[ "$1" =~ [0-9]+%$ ]]; then
          RESIZE="$1"
        elif [[ "$1" =~ [0-9]+$ ]]; then
          RESIZE="$1%"
        else
          printf 'Resize amount not specified. Ex: 100%% or 20\n'
          return 2
        fi
        shift
        ;;
      -s | --size)
        shift
        if [[ "$1" =~  $SLURP_REGEX ]]; then
          CROP="$1"
        else
          printf 'No dimension argument found for --tmp-dir option\n'
          return 2
        fi
        shift
        ;;
      -t | --tmp-dir)
        shift
        if [[ -z "$1" ]]; then
          printf 'No directory argument found for --tmp-dir option\n'
          return 2
        fi
        TMP_DIR="$1"
        shift
        ;;
      -h | --help)
        print_help "$0"
        return 1
        ;;
      area)
        CROP="area"
        shift
        ;;
      full)
        CROP="fullscreen"
        shift
        ;;
      markup)
        IS_SWAPPY=true
        shift
        ;;
      *)
        if [[ -z "$OUTPUT_PATH" ]]; then
          OUTPUT_PATH="$1"
        else
          printf 'Multiple output paths specified when only one was expected\n'
          return 2
        fi
        shift
        ;;
    esac
  done

  # Assert valid number of inputs and outputs
  if [[ -z "$CROP" && -z "$RESIZE" && -z "$IS_SWAPPY" ]]; then
    printf 'No inputs specified!\n'
    print_help "$0"
    return 1
  fi
}

# Set defaults
set_global_defaults() {
  if [[ -z "$EXT" && -n "$OUTPUT_PATH" ]]; then
    EXT="${OUTPUT_PATH##*.}"
  elif [[ -z "$EXT" && -n "$RESIZE" ]]; then
    EXT='avif'
  elif [[ -z "$EXT" ]]; then
    EXT='png'
  fi

  if [[ -z "$TMP_DIR" ]]; then
    TMP_DIR="$HOME/Desktop/screenshots_tmp"
  fi

  mkdir -p "$TMP_DIR"
  TMP_PATH="${TMP_DIR}/$(date +%s).png"

  if ! [[ -w "$TMP_DIR" ]]; then
    printf 'Temporary path %s is not writable. Check permissions\n' "$TMP_PATH"
    return 2
  fi
}

# Save screenshot into tmp
get_screenshot() {
  if [[ "$CROP" == "area" ]]; then
    grim -g "$(slurp)" "$TMP_PATH"
  elif [[ "$CROP" == "fullscreen" ]]; then
    grim "$TMP_PATH"
  elif [[ "$CROP" =~ $SLURP_REGEX ]]; then
    grim -g "$CROP" "$TMP_PATH"
  fi
}

apply_drop_shadow() {
  magick convert "$TMP_PATH" \
    \( +clone -background black -shadow "${SHADOW}+0+0" \) \
    +swap -background white -layers merge +repage \
    "$TMP_PATH"
}

# Resize latest screenshot
resize_latest_screenshot() {
  if [[ -n "$IS_SWAPPY" ]] || [[ -n "$RESIZE" && "$RESIZE" == '100%' && "$EXT" == 'png' ]]; then
    TMP_PATH="$(fd -e 'png' -E '*_*' . "$TMP_DIR" | sort | tail -1)"
  elif [[ -n "$RESIZE" ]]; then
    local latest_screenshot="$(fd -e 'png' -E '*_*' . "$TMP_DIR" | sort | tail -1)"
    TMP_PATH="${latest_screenshot%.*}_${RESIZE}.${EXT}"

    if [[ -z "$latest_screenshot" ]]; then
      printf 'No screenshots found to resize\n'
      return 1
    fi

    magick convert "$latest_screenshot" -resize "$RESIZE" "${EXT^^}:$TMP_PATH"
  elif [[ "$EXT" != png ]]; then
    local source_path="$TMP_PATH"
    TMP_PATH="${source_path%.*}.${EXT}"
    magick convert "$source_path" "${EXT^^}:$TMP_PATH"
  fi
}

# Copy screenshot to destination
copy_to_destination() {
  if [[ "$IS_CLIPBOARD" == true ]]; then
    wl-copy < "$TMP_PATH"
  elif [[ "$IS_SWAPPY" == true ]]; then
    swappy -f "$TMP_PATH" -o "${TMP_PATH%.*}_swappy.png"
  fi
  if [[ -n "$OUTPUT_PATH" ]]; then
    cp "$TMP_PATH" "$OUTPUT_PATH"
  fi
}

if ! parse_args "$@"; then
  exit $?
fi
set_global_defaults || exit $?
get_screenshot
[[ -z "$SHADOW" ]] || apply_drop_shadow
resize_latest_screenshot || exit $?
copy_to_destination || exit $?

# wl-copy https://www.reddit.com/r/swaywm/comments/bb4dam/take_screenshot_to_clipboard/
