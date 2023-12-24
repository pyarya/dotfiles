#!/usr/bin/env bash
# `man` for python functions
#
# A few libraries are imported by default:
#   <name>/[alias]
#   numpy/np
#   pandas/pd
print_help() {
  cat <<HELP
Open the help page for a python function

Usage: $(basename $0) [options] <function>

Options:
    --lib <lib>   Specify a library to import

Numpy as np and Pandas as pd work by default. Prefixing with a library works

Examples:
    $(basename $0) exit
    $(basename $0) --lib os os.getcwd
    $(basename $0) os.getcwd             # Implicity imports \`os\`
    $(basename $0) numpy.random.randint  # Implicity imports \`numpy.random\`
    $(basename $0) np.random.randint     # np -> numpy, then same as above
HELP
}

declare lookup lib
declare -r py="/usr/bin/env python3"

# Parse args
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h | --help)
      print_help
      exit 0
      ;;
    --lib)
      shift

      if [[ -z "$1" ]]; then
        print_help
        exit 1
      else
        lib="$1"
      fi
      ;;
    *)
      lookup="$1"
      ;;
  esac

  shift
done

# Expand aliases
lookup="$(echo "$lookup" | sed 's#^np\.#numpy.#')"
lookup="$(echo "$lookup" | sed 's#^pd\.#pandas.#')"

# Open manpage
if [[ -z "$lookup" ]]; then
  print_help
elif [[ -n "$lib" ]]; then
  $py -c "import $lib; help($lookup)"
elif [[ "$lookup" =~ \. ]]; then
  $py -c "import ${lookup%.*}; help($lookup)"
else
  $py -c "help($lookup)"
fi
