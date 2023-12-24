#!/usr/bin/env bash
print_help() {
  cat <<HELP
Generate a random password from /dev/urandom, with characters from /[A-z0-9;-]/

Usage: $(basename "$0") <output-length>

Examples:
    $(basename "$0") 20 | wl-copy
    $(basename "$0") 400 > key_file

Special characters: /[;-]/

Length must be at least $MIN_PASSWORD_LENGTH. Passwords are generated until one of each a
lowercase, uppercase, digit, and special character are in the password.
Both special characters are required for passwords >=$LONG_PASSWORD_LENGTH characters long.
Really long passwords have at least 2 of each special character.
HELP
}

shopt -s lastpipe
declare -ri LONG_PASSWORD_LENGTH=15 MIN_PASSWORD_LENGTH=6
declare -gri LENGTH="$1"
declare password=""

generate_password() {
  dd if=/dev/urandom bs=3 count="$(( 10 * LENGTH ))" 2>/dev/null \
    | base64 -w0 \
    | tr '/' '-' \
    | tr '+' ';' \
    | cut -c "1-$LENGTH" \
    | read -r password
}

contains_characterset() {
  local p="$password"
  if [[ $LENGTH -ge $(( 2*LONG_PASSWORD_LENGTH )) ]]; then
    [[ $p =~ [A-Z] && $p =~ [a-z] && $p =~ [0-9] && $p =~ \;.+\; && $p =~ -.+- ]]
  elif [[ $LENGTH -ge $LONG_PASSWORD_LENGTH ]]; then
    [[ $p =~ [A-Z] && $p =~ [a-z] && $p =~ [0-9] && $p =~ \; && $p =~ - ]]
  else
    [[ $p =~ [A-Z] && $p =~ [a-z] && $p =~ [0-9] ]] && [[ $p =~ \; || $p =~ - ]]
  fi
}

if [[ "$1" =~ ^[0-9]+$ && $1 -ge $MIN_PASSWORD_LENGTH ]]; then
  while ! contains_characterset; do
    generate_password "$1"
  done

  echo "$password"
else
  print_help
  exit 1
fi
