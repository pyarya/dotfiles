Hit the ground flying with dotfiles for Unix-like systems including MacOS. These
contain all sorts of goodies for bash, vim, shell scripts, unix notes, and much
more!

# Installation

    $ git clone --depth=1 'ssh://git@github.com:22/Aizuko/configs.git' configs
    $ cd configs && bash ./install.sh --help

Use `./install.sh install` to symlink configs. Anything not linked will be
reported and can be viewed at any time with `./install.sh status`. After linking
files, proceed to the [post-installation](#Post-Installation) section

Don't worry, the script won't overwrite anything and doesn't even touch anything
without an explicit `install` argument

### Info

Verified platforms:

 - **EndeavourOS 5.19.6** with Bash **5.1.16**
 - **MacOS 10.15.{3,5}** with Bash **5.1.8** and **3.2.57**
 - Almost certainly works on any Arch-based distro and likely most of Linux

The mindset behind these:

 - If it can be done in a shell, it probably should be done in a shell
 - The mouse is too far away
 - As fast as possible

Configs are kept as consistent as possible between Mac and Linux, without
sacrificing anything on either end. See the [keybinds for
reference](#Keybinding-methodology)

Linux is configured to run Sway. It's extremely light and incredibly fast.
Although almost everything works on Wayland at this point, the Sway config can
be trivially ported to i3 running on Xorg. An Arch-based distro will make
installing the right packages easier, though is by no means required

MacOS is configured to run Yabai with Skhd. This takes some tweaking. Check out
the [Post-installation section for MacOS](#MacOS) beforehand. These config files
were written on and font MacOS Catalina 10.15. Some things may not work in newer
versions, though most things should be fine

The `./notes` directory contains various reference files. They can be accessed
quickly by running `notes`

# Post Installation

## Both

Use `bash package_install.sh status` to see which packages are missing on your
system. `./package_install.sh install` will try to install additional packages.
This is very likely to work on MacOS and any `pacman`-using distro. If it's not
working, install them manually by looking through `./package_install.sh status`

This script does not install many heavier packages, such as `gimp`, `sway`, and
`ffmpeg`. Check out `./notes/further_installation.md` for a list of these and
install them manually

## Linux

#### Fonts

Many scripts assume you have access to [Meslo LGM
NerdFont](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo/M).
These can be replaced easily with any other nerd font. Other fonts may lack
support for the right character set

    $ mv -i downloaded-fonts/* ~/.local/share/fonts
    # mv -i downloaded-fonts/* /usr/local/share/fonts

See the [ArchWiki](https://wiki.archlinux.org/title/fonts#Manual_installation)
for more information. TexLive downloads a lot of additional fonts by default too

#### xRemap

Remapping keys is done through `xremap`. Despite the name, it works flawlessly
on Wayland, at least in Sway

Depending on your environment, you need to install a different binary, all of
which are available through `cargo`. For example `cargo install xremap
--features sway`. Check [here for more
options](https://github.com/k0kubun/xremap#installation).

If you're using systemd, run the following:

```
# ln -s ~/.configs_pointer/xremap/config{_console,}.yml
# mkdir -p /etc/xremap
# ln -s {~/.configs_pointer,/etc}/xremap/config.yml
# cp ~/.configs_pointer/systemd/xremap.service /etc/systemd/system/xremap.service
# cp ~/.cargo/bin/xremap /usr/local/bin/xremap
# systemctl enable xremap.service
# systemctl start xremap.service
# switch_keyboards.sh pc
```

You can toggle between Mac-style keyboard and standard keyboard with
`switch_keyboards.sh` see the doc-comment `vi $(which switch_keyboards.sh)` for
more information

`sway/config` acts as a hotkey daemon and `wtype` can synthesize input

#### Sway

To run sway, install the `sway` and `swaylock` packages. Both configs reference
`default_wallpaper.png` in their respective directories. Put your wallpaper
there or change the corresponding `config` file

If sway is acting up, try setting/unsetting `WAYLAND_DISPLAY` and `SWAYSOCK`.
`swaymsg` also takes an `-s` option which can specify the socket manually

Sway doesn't adjust the gamma on external displays. Compared to MacOS,
everything looks very washed-out and low contrast. Using `wl-sunset` with `-t
4000 -T 6500 -g 0.9` brings MacOS-like gamma curves

For more information about sway, read the [i3 User's
Guide](https://i3wm.org/docs/userguide.html). Particularly chapters 3 and 4 are
very important for sway

#### Multilingual input
IME-style inputs require a complicated setup on wayland. The method described
here unfortunately scales like Xwayland. That is to say it's very blurry on a
HiDPI display. Also, IMEs don't work in Alacritty yet. Consider [foot
terminal](https://codeberg.org/dnkl/foot) if this is important

If you only need an IME in Chromium, [Google Input
Tools](https://chrome.google.com/webstore/detail/google-input-tools/mclkkofklkfljcocdinagocijmpgbhab)
is a pretty decent solution. It scales properly on wayland and doesn't require a
spotty setup. However, it doesn't work in the search bar and makes network calls
for kanji lookups, which can be really slow

Otherwise you can use fcitx5. Choose a supported IME based on what language you
need [here](https://wiki.archlinux.org/title/Input_method). For the example
below we'll install Mozc

```bash
please pacman -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc
please pacman -S gtk4 # For Chromium support
```

Next add these lines to `/etc/environment`
```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
MOZ_ENABLE_WAYLAND=1
```

Currently, Chromium will only interface with fcitx5 when it's running on the
non-default gtk4. Add `--gtk-version=4` to `~/.config/chromium-flags.conf`. As
of writing, this breaks Chromium's built-in file manager, the one for picking
files. Use Firefox for a better fcitx5 experience

Open fcitx5-configtool to set the required keyboards and change the global
hotkey. For Mozc, you'd move the Mozc keyboard to the left. Not the other
Japanese keyboards, those are not IME-based

You may need to reboot wayland or possibly the entire system. Fcitx5 will now be
available will the following command. Consider adding the following to
`sway/config` if you want it on startup, or use `<M-i>` to toggle in on/off

```bash
fcitx5 -d --replace
```

#### AV1 media
AV1 is the hottest new codec on the block, providing compression levels better
than h265. I've seen it 200x smaller than png, with the same resolution and
color space

To store images as avif, use `magick convert my_image_name.{png,avif}`. `viu`
has no support for avif. `imv` supports it out of the box. `vimiv` requires a qt
plugin for support:

```bash
please pacman -S libavif
# Get the latest release from below, for example
# https://github.com/novomesk/qt-avif-image-plugin/releases/latest
curl -LO 'https://github.com/novomesk/qt-avif-image-plugin/archive/refs/tags/v0.5.0.tar.gz'
tar xf qt-avif-image-plugin-0.5.0.tar.gz
cd qt-avif-image-plugin-0.5.0
./build_libqavif_dynamic.sh
please make install
```

#### Chromium
Chromium does not support screen sharing by default on wayland. To add support
go into `chrome://flags` and enable the "WebRTC PipeWire support" flag. Next
download the following a reboot to allow screen sharing

```
please pacman -S xdg-desktop-portal-wlr libpipewire02
```

Consider disabling "Continue running background apps when Chromium is closed" in
settings

Fix the default fonts in `chrome://settings/fonts`. These are the fallback fonts

#### Firefox
Firefox will start on xorg by default, unless the `MOZ_ENABLE_WAYLAND=1`
environment variable is set. Incognito is enabled through the `--private-window`
flag

Firefox uses `about:config` stored in
`~/.mozilla/firefox/<random-hash>.default-release/prefs.js`. These are the
equivalent of Chromium flags. For these configs, simply switch
`ui.key.menuAccessKeyFocuses` to false, to avoid conflicts with xremap

#### Backlights
Laptops usually control the backlight via apci. One program to control this is
[light](https://github.com/haikarainen/light). By default light requires the use
of root privileges to modify devices. Use systemd rules and the video group to
allow unprivileged users to run it normally:

```bash
curl -LO 'https://raw.githubusercontent.com/haikarainen/light/master/90-backlight.rules'
please mkdir -p /usr/lib/udev/rules.d
please cp 90-backlight.rules /usr/lib/udev/rules.d
# Add your user to the video group
please usermod -aG video emiliko
```

## MacOS

Macs aren't even close to Linux in virtualisation capabilities, window managers,
and customizability in general. However, if you're unfortunate enough to find
yourself with a macbook, all is not lost. Here's a rough porting guide:

| sWayland              | MacOS    |
| --------------------- | -------- |
| SwayWM                | [Yabai](https://github.com/koekeishiya/yabai)        |
| xRemap                | [Karabiner-Elements](https://karabiner-elements.pqrs.org/) |
| ~/.config/sway/config | [skhd](https://github.com/koekeishiya/skhd)          |
| swhkd                 | [skhd](https://github.com/koekeishiya/skhd)          |
| wtype                 | [skhd](https://github.com/koekeishiya/skhd)          |
| systemd               | Launchd                                              |
| Zathura               | [Skim](https://skim-app.sourceforge.io/)             |
| Fuzzel                | [Choose](https://github.com/chipsenkbeil/choose) or Spotlight |
| udisksctl             | `diskutil`
| ~/.local/share/fonts  | FontBook                                             |
| wl-clipboard          | `pbcopy` `pbpaste`                                   |
| sshd                  | System Preference -> Sharing -> Remote Login         |
| Super/Ctrl            | Command                                              |
| Alt                   | Opt                                                  |
| $0                    | +$1000                                               |

For Xorg users, `yabai` is to `skhd` what `bspwm` is to `sxhkd`. Also `launchd`
is wayyy less capable than `systemd` and rarely gets used. The `launchd` script
in `./bin` wraps around all the commands you'll ever need

To use open source apps, run `sudo spctl --master-disable`, then head to System
Preferences -> Security & Privacy -> General and select Anywhere at the bottom.
You can check it's working with `spctl --status`

While you're here, you can go under Software Updates and uncheck everything

#### Window managers

MacOS only allows the default Quartz Compositor, a floating window manager with
too many animations and almost no keyboard controls. There are two open source
tiling window managers, which are just scripts overtop Quartz Compositor as
alternatives. [Amethyst](https://github.com/ianyh/Amethyst) and
[Yabai](https://github.com/koekeishiya/yabai)

Amethyst provides basic tiling of windows and basic keyboard controls. Yabai is
effectively a port of bspwm to MacOS and has much more extensive configuration
than Amethyst, notably controlling workspaces. Unfortunately they don't hold a
candle to Linux managers. Both can be very laggy and Yabai specifically often
freezes up for a few seconds, though these are the only options.

To use Yabai, boot into recovery mode, and disable SIP [as explained
here](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection).
Despite what apple says, this doesn't make the system immediately explode.
Actually there's no difference at all, except being able to use Yabai

# Methodology
## Keybinding
Generally keybindings follow this scheme for `skhd`/`xremap`, bash, and vim's
insert mode. They roughly resemble Emac's default. Outliers are bolded. These
are written assuming Ctrl is mapped to CapsLock

When possible selecting is preferred to actually deleting the text

| Type | Start of line | Back word | Back character | Forward character | Forward word | End of line |
| ---- | ------------- | --------- | -------------- | ----------------- | ------------ | ----------- |
| Movement | `^a`     | **`^b`**  |    **`^j`**    |       `^f`        |   **`^w`**   |    `^e`     |
| Deletion |          | **`^u`**  |      `^h`      |       `^d`        |              |    `^k`     |

Window managers are bound to the Super/Command/Logo key. This conflicts with
MacOS's defaults at times

## Light and Dark Mode

### Graphical

Light mode remains somewhat spotty and probably will indefinitely. On Wayland
there's [wluma](https://github.com/maximbaz/wluma) which is a port of MacOS's
[Lumen](https://github.com/anishathalye/lumen). Both can somewhat help alleviate
rapid changes in on-screen content brightness

There's a UserStyle.css file, tested with
[Stylus](https://chrome.google.com/webstore/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne)
on Chromium which provides dark themes for many additional sites, such as the
ArchWiki

### Text mode

Alacritty, tmux, vim, vifm, vimiv are all synchronously colored through
`bin/colo.sh`. This script supports multiple color schemes and makes it easy to
add new ones.

Vifm has a "light" and "dark" mode which plays better with generally "lighter"
and "darker" color schemes. This can be manually changed with `:Light` and
`:Dark`

Vim similarly has shortcuts for the included color schemes. `:Dark[1-4]` and
`:Light[1-4]` change to some hand-picked good ones. Additionally `:Darkh`
changes to a higher-contrast version of the `:Dark` color scheme

## Todo
The only one done configing is you, Ricky

 - Maildir with aerc
 - [Himalaya](https://git.sr.ht/~soywod/himalaya-cli) instead of aerc?
 - Setup irc client?
 - Organize notes
