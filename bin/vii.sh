#!/usr/bin/env bash
# Opens vimiv in thumbnail mode, when there's at least one image in the cwd
declare curr_image="$(fd -d 1 -e 'avif' -e 'gif' -e 'heif' -e 'icns' -e 'jpeg' -e 'jpg' -e 'png' -e 'tiff' -e 'webp' | tail -1)"

if [[ -n "$curr_image" ]]; then
  vimiv \
    --debug gui.eventhandler \
    --command 'unbind <space> --mode=image' \
    --command 'bind <space>h enter library --mode=image' \
    --command 'bind <space>l enter thumbnail --mode=image' \
    --command 'enter library' \
    --command 'enter thumbnail' \
    --command 'goto 0' \
    "$curr_image"
else
  vimiv \
    --debug gui.eventhandler \
    --command 'unbind <space> --mode=image' \
    --command 'bind <space>h enter library --mode=image' \
    --command 'bind <space>l enter thumbnail --mode=image' \
    "$curr_image"
fi
