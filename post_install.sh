#!/usr/bin/env bash
print_help() {
  cat <<HELP
Check additional installation steps for linux. No output is a good sign

See ~/.configs_pointer/notes/futher_installation/further_installation_linux.md
for a more complete explanation

ARGS:
  help      Print this menu and exit
  status    Checks the status of additional installation steps. May need sudo
  build     Compiles additonal binaries
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
  check_sway_sounds
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

check_swaytree_compilation() {
  local src=~/.configs_pointer/bin/sway_tree.rs
  local exe="${src%.*}"

  if [[ -x "$exe" ]]; then
    return 0
  elif command -v rustc &>/dev/null; then
    rustc -C opt-level=3 "$src" -o "$exe"
  fi

  if ! [[ -x "$exe" ]]; then
    printf "ERR: Uncompiled sway_tree.rs script\n"
    printf "\tInstall a rust compiler and rerun this script\n"
    return 1
  fi

  return 0
}

check_sway_sounds() {
  local return_code=0
  local -ra a=(\
    ~/.configs_pointer/sway screenshot_sound.mp3 'screenshot sound'
    ~/.configs_pointer/sway volume_change_sound.mp3 'volume change sound'
    ~/.configs_pointer/sway error_sound.mp3 'error sound'
  )

  for ((i=0; i < ${#a[@]}; i += 3)); do
    if ! [[ -r "${a[i]}/${a[i+1]}" ]]; then
      printf "ERR: Missing %s for sway\n" "${a[i+2]}"
      printf '\tAdd a playable sound file to %s\n' "${a[i]}/${a[i+1]}"
      printf "\tIt doesn't have to be an mp3 file, just make the extension .mp3\n"
      return_code=1
    fi
  done

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

  if ! [[ -d ~/.configs_pointer/tmux/plugins ]]; then
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

####################
# SSH
####################
ssh_checks() {
  check_sshconfig
  check_sshdconfig
}

check_sshconfig() {
  local return_code=0

  if ! [[ -r ~/.ssh/config ]]; then
    printf 'ERR: Missing ssh config at ~/.ssh/config\n'
    printf '\tSee ./ssh/template.config for an example\n'
    return_code=1
  elif ! grep -Eq 'Host (codeberg.org|github.com|\*sr.ht)' ~/.ssh/config; then
    printf 'ERR: No hosts in ~/.ssh/config\n'
    printf '\tSee ./ssh/template.config for an example\n'
    return_code=1
  fi

  return $return_code
}

check_sshdconfig() {
  local return_code=0

  if ! grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config; then
    printf 'ERR: Password authentication permitted in /etc/ssh/sshd_config\n'
    printf '\tSee ./ssh/template.sshd_config for an example\n'
    return_code=1
  fi

  if ! grep -q 'PermitRootLogin no' /etc/ssh/sshd_config; then
    printf 'ERR: Root login permitted in /etc/ssh/sshd_config\n'
    printf '\tSee ./ssh/template.sshd_config for an example\n'
    return_code=1
  fi

  if grep -q 'Port 22' /etc/ssh/sshd_config || ! grep -q 'Port' /etc/ssh/sshd_config; then
    printf 'ERR: Still using port 22 for sshd\n'
    printf '\tSee ./ssh/template.sshd_config for an example\n'
    return_code=1
  fi

  return $return_code
}

####################
# Rust binaries
####################
russy_checks() {
  check_for_russy_bins
}

check_for_russy_bins() {
  local -i return_code=0

  local -a bin_names
  bin_names=($(awk '/name =/ { split($0, a, "\""); print a[2] }' ~/.configs_pointer/bin/rewritten_in_rust/Cargo.toml))

  if [[ $? -eq 0 ]]; then
    for (( i = 1; i < "${#bin_names[@]}"; i++ )); do
      local name="${bin_names[i]}"

      if ! [[ -L "${HOME}/.configs_pointer/bin/${name}" ]] && [[ -e "${HOME}/.configs_pointer/bin/${name}" ]]; then
        printf 'ERR: Conflicting file with rust binary `%s` in bin\n' "$name"
        printf '\tRemove the conflicting file and rerun this script with `build`\n'
        return_code=1
      elif ! [[ -L "${HOME}/.configs_pointer/bin/${name}" ]]; then
        printf 'ERR: Missing rust binary `%s` in bin\n' "$name"
        printf '\tInstall rust and rerun this script with the `build` argument\n'
        return_code=1
      fi
    done
  fi

  return $return_code
}

russy_build() {
  if command -v cargo &>/dev/null; then
    if cargo build --release --manifest-path="$HOME/.configs_pointer/bin/rewritten_in_rust/Cargo.toml"; then
      local name

      for exe in $(fd -d1 -tx . ~/.configs_pointer/bin/rewritten_in_rust/target/release); do
        name="$(basename "$exe")"
        (
          cd ~/.configs_pointer/bin || return 1

          if ! [[ -e "$name" ]]; then
            ln -s "./rewritten_in_rust/target/release/$name" "./$name"
          elif ! [[ -L "$name" ]]; then
            printf 'ERR: Failed to link rust binary \`%s\`\n' "$name"
            printf '\tRemove the conflicting file\n'
          fi
        )
      done
    else
      printf 'ERR: Failed to compile rust binaries\n'
      printf '\tInstall rust to compile additional scripts\n'
      return 1
    fi
  else
    printf 'ERR: No rust compiler found\n'
    printf '\tInstall rust to compile additional scripts\n'
    return 1
  fi
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
  ssh_checks
  russy_checks
elif [[ "$1" == 'build' ]]; then
  russy_build
else
  print_help
fi
