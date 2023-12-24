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

# End up in the same directory as vifm exited in
vifmmv() {
  local dst="$(command vifm --choose-dir - "$@")"
  if [ -z "$dst" ]; then
    printf 'Directory was not changed\n'
    return 1
  fi
  cd "$dst"
}

# Open command script in vim
viw() {
  if [[ -z "$1" ]] || ! which "$1"; then
    printf "No %s found in path\nAborting...\n" "$1"
    exit 1
  elif [[ "$(file "$(which "$1")")" =~ 'ELF.*executable' ]]; then
    printf "%s is a binary\nAborting...\n" "$1"
    exit 1
  else
    "$EDITOR" "$(which "$1")"
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
