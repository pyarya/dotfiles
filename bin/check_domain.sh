#!/usr/bin/env bash
print_help() {
  cat <<HELP
Check if a domain is available. Sends a notification if it is

USAGE: $(basename "$0") <domain>
HELP
}

if [[ "$1" =~ ^[a-z0-9-]+(\.[a-z]+)+$ ]]; then
  whois "$1" | awk -v d_name="$1" '
  BEGIN { is_available = 1 }

  /Updated Date/ { is_available = 0; print }
  /Creation Date/ { is_available = 0; print }
  /Registry Expiry Date/ { is_available = 0; print }

  END {
    if (is_available) {
      printf "%s is available!!!\n", d_name
      system("notify-send -u critical -t 3600000 \""d_name"\" \"Domain "d_name" is available!\"")
    }
  }
  '
else
  print_help
fi
