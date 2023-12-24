#!/usr/bin/env bash

# Source completion scripts ========================================
source_completion_scripts () {
  [ -r "/usr/local/etc/profile.d/bash_completion.sh" ] && . "/usr/local/etc/profile.d/bash_completion.sh"

  [ -f ~/.git-completion.bash ] && . ~/.git-completion.bash

  # Fzf
  [ -f ~/.fzf.bash ] && . ~/.fzf.bash
    # Arch uses a different location
  [ -f /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash

  if [[ "$(type -t _fzf_setup_completion)" == 'function' ]]; then
    _fzf_setup_completion path mpv vi vii nvim vimiv cat
  fi
}

# Welcome prompts ===================================================
print_version_and_platform () {
  local os_name bash_version

  if [[ -n "${BASH_VERSION}" ]]; then
    bash_version="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
  fi

  case "$(uname)" in
    Linux)
      os_name="$(awk '/PRETTY_NAME/ {
          split($0, a, "=")
          gsub(/"/, "", a[2])
          print a[2]
        }' /etc/os-release)"
      ;;
    Darwin) os_name="MacOS $(sw_vers -productVersion)" ;;
  esac

  printf 'GNU bash %s on %s\n\n' \
    "${bash_version:-Unknown}" "${os_name:-Unknown Platform}"
}

print_user_msg () {
  local username tty_name

  username="$(id -un)"
  tty_name="$(tty | awk '{ print substr($0, 6) }')"

  printf '%s: %s @ %s\n' \
    "${username}" "${tty_name}" "${HOSTNAME}"
}

print_welcome_message () {
  print_version_and_platform
  cal
  print_user_msg
}

# Login items =======================================================
is_ssh_connection () {
  [[ "${-}" =~ i ]] && [[ -z "${TMUX}" ]] && [[ -n "${SSH_CONNECTION}" ]] \
  || [[ -n "${SSH_TTY}" ]]
}

has_tmux () {
  command -v tmux &> /dev/null
}

set_starting_dir () {
  if [[ "$PWD" == "$HOME" && -d ~/safe && "$IS_VIFM_NEST" != 'T' ]]; then
    cd ~/safe
  fi
}

# =============================================================================
# Run script
# =============================================================================
source ~/.bashrc
source ~/.bash_prompt

[[ "$IS_VIFM_NEST" == 'T' ]] || print_welcome_message
printf '\n'

# Start in routing directory on login ====
set_starting_dir

# Attach ssh connections to a dedicated tmux session ====
if is_ssh_connection && has_tmux; then
  tmux new-session -As ssh_tmux 2>&1 \
    | grep -v 'sessions should be nested with care'  # We don't care
fi

# Bash completion ====
source_completion_scripts

# vim: set ft=bash ff=unix:
