#!/usr/bin/env bash
print_help() {
  cat <<HELP
Check additional installation steps for linux. No output is a good sign

See ~/.configs_pointer/notes/futher_installation/further_installation_linux.md
for a more complete explanation

ARGS:
  help      Print this menu and exit
  status    Checks the status of additional installation steps. May need sudo
HELP
}

configs_pointer_is_setup() {
  if ! [[ -e ~/.configs_pointer ]]; then
    printf "Symlink ~/.configs_pointer does not exist\n"
  elif ! [[ -L ~/.configs_pointer ]]; then
    printf "~/.configs_pointer is not a symlink\n"
  elif ! [[ -x ~/.configs_pointer/post_install.sh ]]; then
    printf "No post_install.sh in directory ~/.configs_pointer\n"
  elif ! [[ ~/.configs_pointer/post_install.sh -ef ./post_install.sh ]]; then
    printf "post_install.sh in directory ~/.configs_pointer is not this file\n"
  else
    return 0
  fi

  printf "Please run ./install.sh before running this file\n"
  printf "Aborting...\n"
  return 1
}

####################
# Sway / Swaylock
####################
swayland_checks() {
  check_sway_wallpaper
  check_swaylock_wallpaper
}

check_sway_wallpaper() {
  local return_code=0

  if ! [[ -r ~/.configs_pointer/sway/default_wallpaper.png ]]; then
    printf "ERR: Missing default wallpaper for sway\n"
    printf "\tAdd default_wallpaper.png to ./sway\n"
    printf "tIt doesn't actually have to be a png file, just that extension\n"
    return_code=1
  fi

  if ! [[ -r ~/.configs_pointer/sway/secondary_wallpaper.png ]]; then
    printf "ERR: Missing secondary wallpaper for sway\n"
    printf "\tAdd secondary_wallpaper.png to ./sway\n"
    printf "tIt doesn't actually have to be a png file, just that extension\n"
    return_code=1
  fi

  return $return_code
}

check_swaylock_wallpaper() {
  local return_code=0

  if ! [[ -r ~/.configs_pointer/swaylock/default_wallpaper.png ]]; then
    printf "ERR: Missing default wallpaper for swaylock\n"
    printf "\tAdd default_wallpaper.png to ./swaylock\n"
    printf "tIt doesn't actually have to be a png file, just that extension\n"
    return_code=1
  fi

  return $return_code
}

####################
# Tmux
####################
tmux_check() {
  check_tmux_plugins
}

check_tmux_plugins() {
  local return_code=0

  if [[ -d ~/.configs_pointer/tmux/plugins ]]; then
    printf "ERR: Missing tmux plugins\n"
    cat <<HELP
    mkdir ~/.configs_pointer/tmux/plugins
    git clone --depth=1 'https://github.com/tmux-plugins/tpm' ~/.configs_pointer/tmux/plugins/tpm
    Press: <prefix>R
    Press: <prefix>I
    Press: <prefix>R
HELP
    return_code=1
  fi

  return $return_code
}

####################
# Xremap
####################
xremap_checks() {
  check_xremap_config
  check_xremap_etc
  check_xremap_executable
  check_xremap_systemd
}

check_xremap_config() {
  local return_code=0

  if ! [[ -r ~/.configs_pointer/xremap/config.yml ]]; then
    printf "ERR: Missing config.yml for xremap\n"
    printf "\tTry ln -s ./xremap/config{_console,}.yml\n"
    return_code=1
  fi

  return $return_code
}

check_xremap_etc() {
  local return_code=0

  if ! [[ -e /etc/xremap/config.yml ]]; then
    printf "ERR: Missing config.yml for xremap in /etc\n"
    printf "\t $ please ln -s ~/.configs_pointer/xremap/config.yml /etc/xremap/config.yml\n"
    return_code=1
  fi

  if ! [[ -e /etc/systemd/system/xremap.service ]]; then
    printf "ERR: Missing service file for xremap\n"
    printf "\t $ please cp ~/.configs_pointer/systemd/xremap.service /etc/systemd/system/xremap.service\n"
    return_code=1
  fi

  return $return_code
}

check_xremap_executable() {
  local return_code=0

  if ! [[ -x /usr/local/bin/xremap ]]; then
    printf "ERR: Missing systemd binary for xremap\n"
    printf "\t $ please cp ~/.cargo/bin/xremap /usr/local/bin/xremap\n"
    return_code=1
  fi

  return $return_code
}

check_xremap_systemd() {
  local return_code=0

  if ! systemctl is-enabled --quiet xremap &>/dev/null; then
    printf "ERR: xremap.service not enabled in systemd\n"
    printf "\t $ systemctl enable xremap\n"
    return_code=1
  fi

  if ! systemctl is-active --quiet xremap &>/dev/null; then
    printf "ERR: systemd is not running xremap.service\n"
    printf "\t $ systemctl start xremap\n"
    return_code=1
  fi

  return $return_code
}

####################
# Browsers
####################
browser_checks() {
  check_firefox_wayland
}

check_firefox_wayland() {
  local return_code=0

  if ! grep 'MOZ_ENABLE_WAYLAND=1' /etc/environment &>/dev/null; then
    printf "ERR: Missing wayland envvar for firefox\n"
    printf '\t $ please echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment\n'
    return_code=1
  fi

  return $return_code
}

####################
# Backlight
####################
backlight_checks() {
  if pacman -Qi ddcutil &>/dev/null; then  # Check if it's a laptop
    printf "All good" &>/dev/null
  else
    check_backlight_rules
  fi
}

check_backlight_rules() {
  local return_code=0

  if ! [[ -e /usr/lib/udev/rules.d/90-backlight.rules ]]; then
    printf "ERR: Missing rules for backlight\n"
    printf "\tFollow the instructions for haikarainen/light on github, at the bottom of the README\n"
    return_code=1
  fi

  if ! id | grep 'video' &>/dev/null; then
    printf "ERR: Your user is not in the video group\n"
    printf "\t $ please usermod -aG video %s\n" "$USER"
    return_code=1
  fi

  return $return_code
}

####################
# Fcitx
####################
fcitx_checks() {
  check_fcitx_envvars
}

check_fcitx_envvars() {
  local return_code=0

  if ! grep -E '^GTK_IM_MODULE=fcitx$' /etc/environment &>/dev/null; then
    printf "ERR: Missing GTK envvar for fcitx\n"
    printf '\t $ please echo "GTK_IM_MODULE=fcitx" >> /etc/environment\n'
    return_code=1
  fi

  if ! grep -E '^QT_IM_MODULE=fcitx$' /etc/environment &>/dev/null; then
    printf "ERR: Missing QT envvar for fcitx\n"
    printf '\t $ please echo "QT_IM_MODULE=fcitx" >> /etc/environment\n'
    return_code=1
  fi

  if ! grep -E '^XMODIFIERS=@im=fcitx$' /etc/environment &>/dev/null; then
    printf "ERR: Missing XMODIFIERS envvar for fcitx\n"
    printf '\t $ please echo "XMODIFIERS=@im=fcitx" >> /etc/environment\n'
    return_code=1
  fi

  return $return_code
}

####################
# Av1 / vimiv
####################
av1_checks() {
  check_vimiv_plugin
  check_libavif
}

check_vimiv_plugin() {
  local return_code=0

  if ! [[ -e /usr/lib/qt/plugins/imageformats/libqavif.so ]]; then
    printf "ERR: Missing avif support for vimiv\n"
    cat <<HELP
    $ curl -LO 'https://github.com/novomesk/qt-avif-image-plugin/archive/refs/tags/v0.5.0.tar.gz'
    $ tar xf qt-avif-image-plugin-0.5.0.tar.gz
    $ cd qt-avif-image-plugin-0.5.0
    $ ./build_libqavif_dynamic.sh
    $ please make install
HELP
    return_code=1
  fi

  return $return_code
}

check_libavif() {
  local return_code=0

  if ! ls /var/lib/pacman/local/libavif* &>/dev/null; then
    printf "ERR: Missing system-wide avif support\n"
    printf "\t $ please pacman -S libavif\n"
    return_code=1
  fi

  return $return_code
}

####################
# Aerc
####################
aerc_checks() {
  check_aerc_accounts
}

check_aerc_accounts() {
  local return_code=0

  if [[ "$(stat -c "%a" ~/.configs_pointer/aerc/accounts.conf)" != "600" ]]; then
    printf "ERR: Aerc's accounts.conf is missing permissions 600\n"
    return_code=1
  fi

  return $return_code
}

####################
# Git
####################
git_checks() {
  check_gitconfig
}

check_gitconfig() {
  local return_code=0

  if ! [[ -r ~/.gitconfig ]]; then
    printf 'ERR: Missing global gitconfig at ~/.gitconfig\n'
    return_code=1
  fi

  return $return_code
}

if [[ "$1" == 'status' && "$(uname -s)" == 'Linux' ]]; then
  configs_pointer_is_setup || exit 1

  swayland_checks
  xremap_checks
  browser_checks
  backlight_checks
  fcitx_checks
  av1_checks
  tmux_check
  aerc_checks
  git_checks
else
  print_help
fi
