#!/usr/bin/env bash
print_help() {
  cat <<HELP
Converts a given file name to something more sensible

USAGE: $(basename "$0") <file-name>

Removes characters that shouldn't be used in file names. Effectively leaves
/[0-9A-z-_.]/ with a few additional rules (like no leading hyphens)
HELP
}

if [[ -z "$1" ]]; then
  print_help
  exit 1
else
  echo "$@" | awk '{
    split($0, a, "")

    for (i in a) {
      c=a[i]

      if (!length(name) && c == "-")
        continue;
      else if (c ~ /[0-9A-Za-z_.-\/]/)
        name = name c
      else if (c == " ")
        name = name "_"
      else if (c == ":" || c == ";")
        name = name "-"
    }
  }

  END { print name }'
fi
