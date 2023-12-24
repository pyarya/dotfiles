#!/usr/bin/env bash
declare PACMAN=""

# Linux and Cargo packages are written in pairs: (package_name, binary_name).
# Brew packages only use their binary name and are intended for MacOS.
# The binary name is used to check if the package is already installed from
# another source
declare -r \
  LINUX_PACKAGES=(\
    'dante'        'aerc'
    'w3m'          'aerc'
    'aerc'         'aerc'
    'alacritty'    'alacritty'
    'bat'          'bat'
    'calc'         'calc'
    'dust'         'dust'
    'exa'          'exa'
    'fd'           'fd'
    'foliate'      'foliate'
    'fuzzel'       'fuzzel'
    'fzf'          'fzf'
    'gawk'         'gawk'
    'git'          'git'
    'git-lfs'      'git-lfs'
    'grim'         'grim'
    'pass'         'pass'
    'slurp'        'slurp'
    'swappy'       'swappy'
    'imv'          'imv'
    'jq'           'jq'
    'mpv'          'mpv'
    'neofetch'     'neofetch'
    'neovim'       'nvim'
    'paru'         'paru'
    'ripgrep'      'rg'
    'socat'        'socat'
    'sway'         'sway'
    'swaybg'       'swaybg'
    'swaylock'     'swaylock'
    'tealdeer'     'tldr'
    'tmux'         'tmux'
    'udisks2'      'udisksctl'
    'vifm'         'vifm'
    'viu'          'viu'
    'wl-clipboard' 'wl-paste'
    'wtype'        'wtype'
    'ydotool'      'ydotool'
    'zathura-pdf-mupdf' 'zathura'
    'zathura'      'zathura'
  ) \
  CARGO_PACKAGES=(\
    'alacritty' 'alacritty'
    'bat'       'bat'
    'du-dust'   'dust'
    'exa'       'exa'
    'fd-find'   'fd'
    'ripgrep'   'rg'
    'tealdeer'  'tldr'
    'viu'       'viu'
  ) \
  BREW_PACKAGES=(\
    'bash' 'bat' 'calc' 'coreutils' 'dust' 'exa' 'fd' 'fzf' 'gawk' 'git'
    'imagemagick' 'jq' 'mmv' 'mpv' 'neofetch' 'node' 'nvim' 'pngpaste'
    'python3' 'ripgrep' 'skhd' 'tealdeer' 'tmux' 'vifm' 'viu' 'yabai'
  ) \
  AUR_PACKAGES=(\
    'mmv'                'mmv'
    'nerd-fonts-meslo'   'font-manager'
    'vimiv-qt-git'       'vimiv'
    'warpd-wayland-git'  'warpd'
    'wev'                'wev'
    'wlsunset'           'wlsunset'
  )

print_help() {
  cat <<HELP
Install packages and external scripts. Uses the default package manager for
your system. May not work on some distros

USAGE:
  ./install_packages.sh [ARGS]

ARGS:
  ssh      Downloads essential packages directly via curl
  help     Prints this message and exits (default)
  status   Lists the download status of packages and exits
  install  Installs packages using package managers
HELP
}

main() {
  if ! set_package_manager; then
    printf "Failed to find package manager\nAborting...\n"
    exit 1
  else
    printf "Found \`%s\` as system package manager\n" "${PACMAN}"
  fi

  if [[ "$(uname -s)" == "Darwin" && "$1" == "install" ]]; then
    cp -n ~/.configs_pointer/other/madoka_error.aiff ~/Library/Sounds/madoka_error.aiff
    install_brew_packages
  elif [[ "$(uname -s)" == "Linux" && "$1" == "install" ]]; then
    install_linux_packages
  elif [[ "$1" == "ssh" ]]; then
    install_curl_packages
  elif [[ "$1" == "status" ]]; then
    list_packages
    exit 0
  else
    print_help
    exit 0
  fi

  install_web_packages
  install_cargo_packages

  printf 'Done\n'
}

set_package_manager () {
  if ! command -v brew &>/dev/null && [[ "$(uname -s)" == "Darwin" ]]; then
    eval "$(curl -fsSL 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh')"
  fi

  if   command -v paru    &> /dev/null; then PACMAN='paru -S'
  elif command -v pacman  &> /dev/null; then PACMAN='sudo pacman -S'
  elif command -v apt-get &> /dev/null; then PACMAN='sudo apt-get install'
  elif command -v apk     &> /dev/null; then PACMAN='sudo apk add'
  elif command -v rpm     &> /dev/null; then PACMAN='rpm -ihv'
  elif command -v brew    &> /dev/null; then PACMAN='brew install'
  else
    return 1
  fi
}

list_packages() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    printf "==== Installed by \`%s\` =============\n" "${PACMAN}"

    for pkg in "${BREW_PACKAGES[@]}"; do
      print_package_status "$pkg" "brew"
    done
  elif [[ "$(uname -s)" == "Linux" ]]; then
    printf "==== Installed by \`%s\` =============\n" "${PACMAN}"

    for ((i = 0; i < "${#LINUX_PACKAGES[@]}"; i=(i+2) )); do
      print_package_status "${LINUX_PACKAGES[$i + 1]}" "$PACMAN"
    done
  fi

  printf "==== Installed by \`cargo install\` =============\n"
  for ((i = 0; i < "${#CARGO_PACKAGES[@]}"; i=(i+2) )); do
    print_package_status "${CARGO_PACKAGES[$i + 1]}" "cargo"
  done
}

print_package_status() {
  if [[ "$2" == "cargo" ]] && [[ -x "${HOME}/.cargo/bin/$1" ]]; then
    printf "✓  %s :: Installed\n" "$1"
  elif [[ "$2" == "cargo" ]]; then
    printf "✗  %s :: Not installed\n" "$1"
  elif [[ "$2" == brew* ]] && brew list "$1" &>/dev/null; then
    printf "✓  %s :: Installed\n" "$1"
  elif [[ "$2" == brew* ]]; then
    printf "✗  %s :: Not installed\n" "$1"
  elif command -v "$1" &> /dev/null; then
    printf "✓  %s :: Installed\n" "$1"
  else
    printf "✗  %s :: Not installed\n" "$1"
  fi
}

#╔─────────────────────────────────────────────────────────────────────────────╗
#│ Pαckαgε iηsταllεrs                                                          |
#╚─────────────────────────────────────────────────────────────────────────────╝
install_web_packages() {
  if ! command -v rustup &>/dev/null && ask "Install rustup?"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi

  if ! [[ -e ~/.config/tmux/plugins/tpm ]] && ask "Install tmux's plugin manager?"; then
    git clone --depth 1 'https://github.com/tmux-plugins/tpm' ~/.config/tmux/plugins/tpm
    ~/.config/tmux/plugins/tpm/tpm
    ~/.config/tmux/plugins/tpm/bin/install_plugins
    ~/.config/tmux/plugins/tpm/tpm
  fi

  if [[ ! -f ~/.git-prompt.bash ]] && ask "Download git-prompt for bash?"; then
      curl --output ~/.git-prompt.bash\
          'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh'
  fi

  if [[ ! -f ~/.git-completion.bash ]] && ask "Download git-completion for bash?"; then
      curl --output ~/.git-completion.bash\
        'https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash'
  fi

  if [[ ! -f ~/.fzf.bash ]] && ask "Download fzf-completion for bash?"; then
      curl --output ~/.fzf.bash\
        'https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash'
  fi

  if ask "Install vim plugins?"; then
    if command -v vim &>/dev/null; then
      vim +$'if !has(\'nvim\') | PlugInstall --sync | endif' +qall
    elif command -v vi &>/dev/null; then
      vi  +$'if !has(\'nvim\') | PlugInstall --sync | endif' +qall
    else
      printf "Run :PlugInstall in nVim to finish setting up vim's plugins\n"
    fi

    if command -v pip3 &>/dev/null && ! pip3 list 2>&1 | grep -q '^pynvim'; then
      pip3 install pynvim
    fi
  fi
}

install_cargo_packages() {
  if ! command -v cargo &> /dev/null; then
    printf 'Cargo package manager not found\n'
    return 1
  fi

  for ((i = 0; i < "${#CARGO_PACKAGES[@]}"; i=(i+2) )); do
    local bin="${CARGO_PACKAGES[$i + 1]}"
    local name="${CARGO_PACKAGES[$i]}"

    if ! command -v "${bin}" &>/dev/null && ask "Cargo install ${name}?"; then
      cargo install "${name}"
    fi
  done
}

install_brew_packages() {
  brew tap koekeishiya/formulae

  printf 'Checking brew packages. Brew is slow. This may take a while...\n'

  for pkg in "${BREW_PACKAGES[@]}"; do
    if [[ -z "$(brew list "${pkg}")" ]] \
      && ! command -v "${pkg}" &>/dev/null \
      && ask "Install ${pkg}?"; then
      brew install "${pkg}"
    fi
  done
}

# May or may not work. Tested with pacman on arch
install_linux_packages() {
  for ((i = 0; i < "${#LINUX_PACKAGES[@]}"; i=(i+2) )); do
    local bin="${LINUX_PACKAGES[$i + 1]}"
    local name="${LINUX_PACKAGES[$i]}"

    if ! command -v "${bin}" &>/dev/null && ask "Install ${name}?"; then
      eval "${PACMAN} ${name}"
    fi
  done
}

# Very tentative. Only works on linux and only installs essentials for ssh
install_curl_packages() {
  mkdir -p ~/bin

  if ! command -v fzf &>/dev/null && ask 'Download fzf?'; then
    curl --output 'fzf_download.tar.gz' \
      -LO 'https://github.com/junegunn/fzf/releases/download/0.28.0/fzf-0.28.0-linux_amd64.tar.gz'
    tar xf 'fzf_download.tar.gz'
    chmod u+x ./fzf
    rm -f 'fzf_download.tar.gz'
  fi

  if ! command -v neofetch &>/dev/null && ask 'Download neofetch?'; then
    curl --output "neofetch.tar.gz" \
      -LO 'https://github.com/dylanaraps/neofetch/archive/refs/tags/7.1.0.tar.gz'
    tar xf 'neofetch.tar.gz'
    mv ./neofetch-*/neofetch ./neofetch
    rm -rf 'neofetch.tar.gz' 'neofetch-7.1.0'
  fi

  if ! command -v tmux &>/dev/null && ask 'Download tmux?'; then
    curl --output 'tmux.tar.gz' \
      -LO 'https://github.com/tmux/tmux/releases/download/3.2a/tmux-3.2a.tar.gz'
    tar xf 'tmux.tar.gz'
    (cd tmux-* && ./configure && make && mv ./tmux ../tmux)
    rm -rf 'tmux.tar.gz' ./tmux-*
  fi

  if ! command -v nvim &>/dev/null && ask 'Download neovim?'; then
    curl -LO 'https://github.com/neovim/neovim/releases/latest/download/nvim.appimage'
    chmod u+x ./nvim.appimage
    mv ./nvim.appimage ./nvim
  fi
}

#######################################
# Arguments:
#   1: Prompt message
# Return:
#   0 for yes, 1 for no
#######################################
ask () {
  read -rp $'\n'"$1 ([y]/n) "
  [[ "${REPLY:-y}" =~ ^[Yy][es]?$ ]]
}


main "$@"
