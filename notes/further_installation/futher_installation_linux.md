# Linux

## Fonts

Many scripts assume you have access to [Meslo LGM
NerdFont](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo/M).
These can be replaced easily with any other nerd font. Other fonts may lack
support for the right character set

```
$ mv -i downloaded-fonts/* ~/.local/share/fonts
# mv -i downloaded-fonts/* /usr/local/share/fonts
```

See the [ArchWiki](https://wiki.archlinux.org/title/fonts#Manual_installation)
for more information. TexLive downloads a lot of additional fonts by default too

## xRemap

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
# cp ~/.configs_pointer/systemd/system/xremap.service /etc/systemd/system/xremap.service
# cp ~/.cargo/bin/xremap /usr/local/bin/xremap
# systemctl enable xremap.service
# systemctl start xremap.service
# switch_keyboards.sh pc
```

You can toggle between Mac-style keyboard and standard keyboard with
`switch_keyboards.sh` see the doc-comment `vi $(which switch_keyboards.sh)` for
more information

`sway/config` acts as a hotkey daemon and `wtype` can synthesize input

## Sway

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

## Multilingual input (fcitx)

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

## AV1 media

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

## Chromium

Chromium does not support screen sharing by default on wayland. To add support
go into `chrome://flags` and enable the "WebRTC PipeWire support" flag. Next
download the following a reboot to allow screen sharing

```bash
please pacman -S xdg-desktop-portal-wlr libpipewire02
```

Consider disabling "Continue running background apps when Chromium is closed" in
settings

Fix the default fonts in `chrome://settings/fonts`. These are the fallback fonts

For the really daring, change your download location to `/dev/shm`. This is a
ramdisk which clears all its content on reboot

## Firefox

Firefox will start on xorg by default, unless the `MOZ_ENABLE_WAYLAND=1`
environment variable is set. Incognito is enabled through the `--private-window`
flag

Firefox uses `about:config` stored in
`~/.mozilla/firefox/<random-hash>.default-release/prefs.js`. These are the
equivalent of Chromium flags. For these configs, simply switch
`ui.key.menuAccessKeyFocuses` to false, to avoid conflicts with xremap

## Backlights

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
