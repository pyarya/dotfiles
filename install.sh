#!/usr/bin/env bash
declare MODE=""
declare -r UNIX_CONFIGS=(\
    # Shell
    bash/.profile        ~/.profile
    bash/.inputrc        ~/.inputrc
    bash/.bashrc         ~/.bashrc
    bash/.bash_profile   ~/.bash_profile
    bash/.bash_env       ~/.bash_env
    bash/.bash_prompt    ~/.bash_prompt
    bash/.bash_aliases   ~/.bash_aliases
    bash/.bash_functions ~/.bash_functions

    aerc                         ~/.config/aerc
    alacritty                    ~/.config/alacritty
    git/.gitignore_global        ~/.gitignore_global
    gnupg/gpg-agent.conf         ~/.gnupg/gpg-agent.conf
    mako                         ~/.config/mako
    mpv                          ~/.config/mpv
    chromium/chromium-flags.conf ~/.config/chromium-flags.conf
    chromium/electron-flags.conf ~/.config/electron-flags.conf
    ripgrep                      ~/.config/ripgrep
    swappy                       ~/.config/swappy
    tmux                         ~/.config/tmux
    vifm                         ~/.config/vifm
    vimiv                        ~/.config/vimiv
    warpd                        ~/.config/warpd

    # Vim and Neovim
    vim/.vim          ~/.vim
    vim/.vimrc        ~/.vimrc
    vim/nvim          ~/.config/nvim
    vim/.vim/plugin   ~/.config/nvim/plugin
    vim/.vim/colors   ~/.config/nvim/colors
  ) \
  LINUX_ONLY=(\
    # Swayland
    i3          ~/.config/i3
    sway        ~/.config/sway
    swaylock    ~/.config/swaylock
    xremap      ~/.config/xremap
    yofi        ~/.config/yofi
  ) \
  MAC_ONLY=(\
    skhd                          ~/.config/skhd
    yabai                         ~/.config/yabai
    sketchybar                    ~/.config/sketchybar

    skhd/com.skhd.launcher.plist    ~/Library/LaunchAgents/com.skhd.launcher.plist
    sketchybar/com.sketchybar.launcher.plist  ~/Library/LaunchAgents/com.sketchybar.launcher.plist
    warpd/com.warpd.launcher.plist  ~/Library/LaunchAgents/com.warpd.launcher.plist
    other/vlcrc                   ~/Library/Preferences/org.videolan.vlc/vlcrc
  )

print_help() {
  cat <<HELP
Install or query config files

ARGS:
  mode: One of "status", "install"

FLAGS:
  -s, --silent    Silences printout for properly installed configs
  -b, --basename  Printout includes basename of file for properly installed configs
  -h, --help      Print this menu and exit

USAGE:
    ./install.sh [flags] <mode>
    bash install.sh [flags] <mode>
HELP
}

main() {
  # Verify we're in the right directory ====
  if [[ "$(is_configs_directory)" != "true" ]]; then
    printf 'Please move to the top level git directory with this script\n'
    printf 'Aborting...\n'
    exit 1
  fi

  # Verify or install ~/.configs_pointer ====
  local configs_pointer="$(configs_pointer_is_setup)"

  if [[ "${configs_pointer}" != "valid" ]]; then
    if [[ "${configs_pointer}" == "does not exist" ]]; then
      if ! ln -s "$PWD" ~/.configs_pointer; then
        printf 'Failed to link present directory to ~/.config_pointer\n'
        printf 'Aborting...\n'
        exit 1
      fi
    else
      printf '~/.configs_pointer does not point to this directory\n'
      printf 'Remove ~/.configs_pointer and rerun this script\n'
      printf 'Aborting...\n'
      exit 1
    fi
  fi

  # Default is status
  if [[ $# -eq 0 ]]; then
    iterate_over_configs 'status'
    exit 0
  fi

  # Parse arguments ====
  while [[ $# -gt 0 ]]
  do
    case "$1" in
      -s | --silent)   MODE="${MODE} silent"   ;;
      -b | --basename) MODE="${MODE} basename" ;;
      -h | --help)     MODE="${MODE} help"     ;;
      status)          MODE="${MODE} status"   ;;
      install)         MODE="${MODE} install"  ;;
      *)
        printf 'Invalid argument: "%s"\n' "$1"
        print_help
        exit 1
        ;;
    esac

    shift
  done

  # Run ====
  if [[ "${MODE}" =~ "help" ]]; then
    print_help
    exit 0
  elif [[ "${MODE}" =~ "status" ]]; then
    iterate_over_configs 'status'
  elif [[ "${MODE}" =~ "install" ]]; then
    fix_launchd_plists
    iterate_over_configs 'install'
    create_directory_paths
    other_setup
    print_install_completion_msg
  else
    print_help
  fi

  exit 0
}

#######################################
# Checks if the script is being run from the configs directory.
# Return code:
#   0 if it is the configs directory, 1 otherwise.
# Return string:
#   Describes why this likely isn't the configs directory.
#######################################
is_configs_directory() {
  if ! [[ -d ./.git ]]; then
    printf "Git folder not found in pwd\n"
    printf "no .git directory"
    return 1
  elif ! [[ -x ./install.sh ]]; then
    printf "install.sh not found in pwd\n"
    printf "file install.sh not in pwd"
    return 1
  fi

  printf "true"
  return 0
}

configs_pointer_is_setup() {
  if ! [[ -e ~/.configs_pointer ]]; then
    printf "does not exist"
    return 1
  elif ! [[ -L ~/.configs_pointer ]]; then
    printf "not a symlink"
    return 1
  elif ! [[ -x ~/.configs_pointer/install.sh ]]; then
    printf "no install.sh at symlink"
    return 1
  elif ! cmp -s ~/.configs_pointer/install.sh ./install.sh; then
    printf "install.sh files differ"
    return 1
  else
    printf "valid"
    return 0
  fi
}

#######################################
# Return the status of a config.
# Arguments:
#   1: Path in configs directory. "from"
#   2: Path on the system. "to"
#######################################
config_status() {
  if [[ "$1" -ef "$2" ]]; then
    printf "linked"
    return 0
  elif [[ -e "$2" ]]; then
    printf "conflict"
    return 1
  elif ! [[ -e "$1" ]]; then
    printf "missing"
    return 1
  else
    printf "not_linked"
    return 1
  fi
}

#╔─────────────────────────────────────────────────────────────────────────────╗
#│ Usεr iητεrfαcε fμηcτiδηs                                                    |
#╚─────────────────────────────────────────────────────────────────────────────╝
#######################################
# Prints the status of a config.
# Arguments:
#   1: Status in {"not_linked", "conflict", "linked"}
#   2: System path to config file
# Outputs:
#   Writes status to stdout
#######################################
print_config_status() {
  if [[ "${MODE}" =~ "basename" ]]; then
    local name="$(basename "$2")"
  else
    local name="$(printf '%s' "$2" | sed 's#'"${HOME}"'#~#')"
  fi

  if ! [[ "${MODE}" =~ "silent" ]] || [[ "$1" != "linked" ]]; then
    case "$1" in
      newly_linked)
                  printf "★  %s :: Newly linked"        "${name}" ;;
      not_linked) printf "✗  %s :: Not Linked"          "${name}" ;;
      conflict)   printf "≠  %s :: Conflicting file"    "${name}" ;;
      missing)    printf "φ  %s :: Missing config file" "${name}" ;;
      linked)     printf "✓  %s :: Linked"              "${name}" ;;
      *)          printf "?  %s :: Status unclear"      "${name}" ;;
    esac

    printf "\n"
  fi
}

print_install_completion_msg() {
  cat <<END

Dotfile installation complete.

To install packages, run: \`./package_install.sh help\`
To check additional options, run: \`./post_install.sh help\`
END
}

#╔─────────────────────────────────────────────────────────────────────────────╗
#│ Cδηfig liηkiηg αrrαys                                                       |
#╚─────────────────────────────────────────────────────────────────────────────╝
create_directory_paths() {
  local a=(\
    ~/.config/vifm/fzf-read
    ~/bin
    ~/safe
  )

  if [[ "$(uname -s)" == "Darwin" ]]; then
    a=("${a[@]}"
      ~/Library/KeyBindings
      ~/Library/Preferences/org.videolan.vlc
    )
  fi

  for d in "${a[@]}"; do
    mkdir -p "$d"
  done
}

# Launchd plists require absolute paths. To make this portable we bundle a
# .template file which has HOMEPATH in place of absolute paths to $HOME. These
# are replaced at install time to create the .plist.
fix_launchd_plists() {
  local a=(
    skhd/com.skhd.launcher.plist     skhd/com.skhd.launcher.template
    sketchybar/com.sketchybar.launcher.plist  sketchybar/com.sketchybar.launcher.template
    warpd/com.warpd.launcher.plist   warpd/com.warpd.launcher.template
  )

  for ((i = 0; i < "${#a[@]}"; i=(i+2) )); do
    local plist="${HOME}/.configs_pointer/${a[$i]}"
    local template="${HOME}/.configs_pointer/${a[$i + 1]}"

    sed -e 's#HOMEPATH#'"${HOME}"'#g' < "${template}" > "${plist}"
  done
}

# Launchd requires an absolute path for sketchbar, which isn't available to brew
other_setup() {
  if which sketchybar &>/dev/null && ! [[ -e ~/.configs_pointer/sketchybar/sketchybar ]]; then
    ln -s "$(which sketchybar)" ~/.configs_pointer/sketchybar/sketchybar &>/dev/null
  fi
}

#######################################
# Prints the status of a config.
# Arguments:
#   1: Path to config file. The "from" path.
#   2: Path to system file. The "to" path.
# Outputs:
#   Writes status to stdout
#######################################
install_config() {
  local status=$(config_status "$1" "$2")

  if [[ "${status}" != "not_linked" ]]; then
    printf '%s\n' "${status}"
    return 1
  fi

  [[ -d "$1" ]] || mkdir -p "$(dirname "$2")"

  if ln -s "$1" "$2"; then
    printf "newly_linked"
    return 0
  else
    return 1
  fi
}

# Arguments
#   1: Mode in {"status", "install"}
iterate_over_configs() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local a=("${UNIX_CONFIGS[@]}" "${MAC_ONLY[@]}")
  else
    local a=("${UNIX_CONFIGS[@]}" "${LINUX_ONLY[@]}")
  fi

  for ((i = 0; i < "${#a[@]}"; i=(i+2) )); do
    local from="${HOME}/.configs_pointer/${a[$i]}"
    local to="${a[$i + 1]}"

    if [[ "$1" == "status" ]]; then
      local status="$(config_status "${from}" "${to}")"
      print_config_status "${status}" "${to}"
    elif [[ "$1" == "install" ]]; then
      local status="$(install_config "${from}" "${to}")"
      print_config_status "${status}" "${to}"
    else
      printf 'Invalid mode "%s" provided\n' "$1"
      exit 1
    fi
  done
}

main "$@"
