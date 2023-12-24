#!/usr/bin/env bash
print_help() {
  cat <<HELP
Compresses all pngs in current directory into avifs, with the same timestamp

USAGE:
    ./$(basename "$0")
HELP
}

if [[ -n "$1" ]]; then
  print_help
  exit 0
fi

declare -i RM_COUNT=0

for f in $(fd -e 'png' '(swappy|%)'); do
  rm -f "$f"
  (( RM_COUNT+=1 ))
done

echo "Removed $RM_COUNT files"

declare -r PNG_COUNT=$(fd -e 'png' | wc -l)
declare -i AVIF_COUNT=0
echo "Preparing to compress $PNG_COUNT images"

for f in $(fd -e 'png'); do
  declare png="$f"
  declare avif="${f%.*}.avif"

  magick convert "$png" "$avif"
  touch -r "$png" "$avif"

  (( AVIF_COUNT+=1 ))
  awk -v a="$AVIF_COUNT" -v p="$PNG_COUNT" 'BEGIN {
    printf "Progress: %3d/%d :: %.1f%%\n", a, p, a/p * 100
  }'
done

echo "Done!"
