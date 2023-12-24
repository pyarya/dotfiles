#!/usr/bin/env bash

# ===================================================================
# Shell fixes
# ===================================================================
# SSH alias completion ==============================================
_ssh()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY+=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh rpluto

# Don't auto-executing line when leaving editor =====================
_edit_wo_executing() {
    local editor="${EDITOR:-vi}"
    tmpf="$(mktemp)"
    printf '%s\n' "$READLINE_LINE" > "$tmpf"
    eval "${editor}  ${tmpf}"
    READLINE_LINE="$(<"$tmpf")"
    READLINE_POINT="${#READLINE_LINE}"
    rm -f "${tmpf}"
}

if [[ "$-" =~ "i" ]]; then
  bind -x '"\C-x\C-e":_edit_wo_executing'
  bind -x '"\C-g":_edit_wo_executing'
fi

# End up in the same directory as vifm exited in ====================
vifmmv() {
  local dst="$(command vifm --choose-dir - "$@")"
  if [ -z "$dst" ]; then
    printf 'Directory was not changed\n'
    return 1
  fi
  cd "$dst"
}

# Keyboard layout switching =========================================
sww() {
  if ! [[ -x ~/.configs_pointer/bin/switch_keyboards.sh ]]; then
    echo 'No switch_keyboard.sh script found in ~.configs_pointer/bin'
    exit 1
  else
    ~/.configs_pointer/bin/switch_keyboards.sh "$@"
  fi
}

# Proper manpages ===================================================
man() {
  local command=$(IFS=-, ; echo "$*")

  # When section is specified,override
  if [[ "$1" =~ ^[1-7]$ ]]; then
    local -ri section="$1"

    shift
    command=$(IFS=-, ; echo "$*")

    /usr/bin/man "$section" "$command"
    return $?
  fi

  local manpy=~/.configs_pointer/bin/man_py.sh

  if [[ "$command" =~ \. ]] && "$manpy" "$command" &>/dev/null; then
    "$manpy" "$command"
  elif /usr/bin/man "$command" >/dev/null 2>&1; then
    /usr/bin/man "$command"
  elif command -v "$command" &>/dev/null; then
    "$command" --help | nvim -R -c 'set syn=man' --
  elif command -v "$@" &>/dev/null; then
    "$@" --help | nvim -R -c 'set syn=man' --
  else
    echo "Error: No man page for \`$command\`"
  fi
}

complete -W "console mac pc standard fn small mini" sww

# Open command source code ==========================================
# Only works for scripts and rust executables
_viw_completions() {
  COMPREPLY=($(compgen -c "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _viw_completions viw

viw() {
  if [[ -z "$1" ]] || ! which "$1" &>/dev/null; then
    printf "No %s found in path\n" "$1"
    return 1
  fi

  local path="$(realpath "$(which "$1")")"
  local f_type="$(file "$path")"
  local p_2="$(dirname "$(dirname "$path")")"
  local n_2="$(basename "$p_2")"
  local p_3="$(dirname "$p_2")"

  # Finds rust source file
  if [[ $f_type =~ ELF.*executable && $n_2 == target && -r $p_3/Cargo.toml ]]; then
    path="$(awk -vkey="$1" '
      /\[\[bin\]\]/ {
        if (key == name && length(path)) exit;
        name = ""; path = ""
      }

      /name =/ { split($0, a, "\""); name = a[2] }
      /path =/ { split($0, a, "\""); path = a[2] }

      END { if (key == name && length(path)) print path }
    ' "${p_3}/Cargo.toml")"

    if [[ -z $path ]]; then
      path="src/main.rs"
    fi

    path="${p_3}/${path}"
  fi

  if [[ -r $path ]]; then
    "$EDITOR" "$path"
  else
    echo "Path isn't readable!"
  fi
}

# Open the python manpages ==========================================
manpy() {
  ~/.configs_pointer/bin/man_py.sh $@
}

# Ronald's Universal Number Kounter, standardized syntax for unix calculators
# BSD-style arguments. v for verbose. c/p/b for the corresponding calculator
# Syntax features:
#   ^ and ** both work for exponentiation
#   log()  is base 10
#   ln()   is base e
#   log2() is base 2
# Careful when changing order or sed might sed itself!
runk() {
  local -i is_verbose=0
  local override=""

  if [[ -n "$2" ]]; then
    if [[ "$1" =~ v ]]; then
      is_verbose=1
    fi

    if [[ "$1" =~ c ]]; then
      override="c"
    elif [[ "$1" =~ p ]]; then
      override="p"
    elif [[ "$1" =~ a ]]; then
      override="a"
    elif [[ "$1" =~ b ]]; then
      override="b"
    fi
    shift 1
  fi

  local calc_ver="($(echo "$@" | sed \
    -e 's#log2(\([^)]\+\))#(log(\1)/log(2))#g' \
  ))"
  local py_ver="$(echo "$@" | sed \
    -e 's#\^#**#g' \
    -e 's#\(log([^)]\+)\)#(\1/log(10))#g' \
    -e 's#ln(\([^)]\+\))#log(\1)#g' \
  )"
  local awk_ver="$(echo "$@" | sed \
    -e 's#\*\*#^#g' \
    -e 's#log(\([^)]\+\))#(log(\1)/log(10))#g' \
    -e 's#log2(\([^)]\+\))#(log(\1)/log(2))#g' \
    -e 's#ln(\([^)]\+\))#log(\1)#g' \
  )"
  local bc_ver="$(echo "$@" | sed \
    -e 's#\*\*#^#g' \
    -e 's#ln(\([^)]\+\))#l(\1)#g' \
    -e 's#log(\([^)]\+\))#(l(\1)/l(10))#g' \
    -e 's#log2(\([^)]\+\))#(l(\1)/l(2))#g' \
  )"

  if command -v calc &>/dev/null && [[ -z "$override" ]] || [[ "$override" == c ]]; then
    calc "$calc_ver"
    if [[ $is_verbose -eq 1 ]]; then printf 'Using calc:  %s\n' "$calc_ver"; fi
  elif command -v python3 &>/dev/null && [[ -z "$override" ]] || [[ "$override" == p ]]; then
    python3 -c "from math import *; print($py_ver)"
    if [[ $is_verbose -eq 1 ]]; then printf 'Using python:  %s\n' "$py_ver"; fi
  elif command -v gawk &>/dev/null && [[ -z "$override" ]] || [[ "$override" == a ]]; then
    gawk --bignum "BEGIN { print $awk_ver }"
    if [[ $is_verbose -eq 1 ]]; then printf 'Using gawk:  %s\n' "$awk_ver"; fi
  else
    echo "$bc_ver" | bc --mathlib
    if [[ $is_verbose -eq 1 ]]; then printf 'Using benchcalc:  %s\n' "$bc_ver"; fi
  fi
}

# Better exiting ====================================================
# Don't exit with background jobs still running. Particularly for Qemu
function exit () {
  if [[ "$(jobs | wc -l)" -ne 0 ]]; then
    printf 'Exit prevented.\nThere are background jobs:\n'
    jobs
    return 1
  fi

  builtin exit
}

# Quick way to glance at recent git history
gitllog() {
  git log -n "${1:-6}" --all --oneline --graph --decorate --color=always
}

# Necessary alias ===================================================
russy () {
  if [[ "$1" == "baka" ]]; then
    cargo check
  elif [[ $# -eq 0 ]] && [[ -e ./src/lib.rs ]]; then
    cargo test
  elif [[ $# -eq 0 ]]; then
    cargo run
  elif [[ $# -eq 1 ]] && [[ "$1" =~ \.rs$ ]]; then
    rustc -C opt-level=3 "$1"
  elif [[ "$1" == "run" && "$2" =~ \.rs$ ]]; then
    rustc -C opt-level=3 "$2" && ./"${2%.*}"
  else
    eval "cargo $@"
  fi
}


# ===================================================================
# Switching color schemes
# ===================================================================
complete -W \
  "--help --query dark light dracula github gruvboxdark gruvboxlight" \
  colo colo.sh

# ===================================================================
# Additional utilities
# ===================================================================
# Colored pagination ================================================
function bless () {
    if [[ $1 =~ "-h" ]]; then
        echo 'USAGE:'
        echo '    bless <file_to_paginate>'
    else
        # Do not quote $1. Prevents piped reads
        if command -v bat &> /dev/null; then
            bat --color=always $1 | less -r
            #cat $1 | vim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
            #    -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
            #    -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -
        else
            less -r $1
        fi
    fi
}

# Attach to tmux session ============================================
function ta() {
  if [[ -n "$1" ]]; then
    tmux new -As "$1"
  elif [[ -n "$TMUX" ]]; then
    tmux switch-client -n
  elif [[ ("${-}" =~ i && -z "${TMUX}" && -n "${SSH_CONNECTION}") || -n "${SSH_TTY}" ]]; then
    tmux new-session -As ssh_tmux 2>&1 \
      | grep -v 'sessions should be nested with care'  # Don't care
  else
    tmux attach 2>/dev/null || tmux new -As 0
  fi
}

# Image magick ======================================================
function magika() {
  if [[ "$1" == "a" || "$1" == "av1" ]]; then
    magick convert "$2" "${2%.*}.avif"
  elif [[ "$1" == "i" ]]; then
    shift
    magick identify "$@"
  elif [[ "$1" == "c" ]]; then
    shift
    magick convert "$@"
  else
    magick "$@"
  fi
}

# Make a directory and navigate into it =============================
function cddir() {
    if [[ "$#" -lt 1 ]] || [[ "$1" =~ '--help' ]]; then
        echo 'Function: cddir()'
        echo 'USAGE:'
        echo '    cddir <dir_name>'
    else
        mkdir -p "$1" && cd ./"$1"
    fi
}

# Change the prompt - alias for change_bash_prompt ==================
function bprompt () {
  source ~/.bash_prompt "$@"
}

# Enable truecolors over an ssh connection ==========================
function truecolor () {
  export COLORTERM='truecolor'

  if command -v tmux has-session &> /dev/null; then
    tmux setenv COLORTERM truecolor
  fi

  source ~/.bash_prompt
}


# vim: set ft=bash ff=unix:
