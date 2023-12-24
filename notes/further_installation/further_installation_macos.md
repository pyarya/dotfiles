Further recommendations to set your system, after having already run the
`install.sh` script. A package manager is the cleanest way to install any of the
apps listed here. Unless specified, these are all open source

# Mac OS

## Shell

Non-graphic open source applications. Use `brew install --formula` unless
otherwise specified

`pbpaste` except for images. Redirect output to file with `pngpaste - > img.png`

```
pngpaste
```

GNU's `coreutils`. Apple has most by default, though they're very outdated

```
coreutils
```

File manager for quickly jumping around directories. Not essential

```
vifm
```

Quickly search stackoverflow for answers to any query

```
so
```

Checks your shell scripts and suggests fixes to potential errors

```
shellcheck
```

Non-graphic image manipulator. Very useful in scripts and often a dependency

```
imagemagick
```

A much better python REPL and integrates nicely with vim's IPython plugin

```
ipython
```

The largest support converting documents types, such as markdown to pdf

```
pandoc
```

`ctags` with a lot more language support

```
universal-ctags
```

`cut`, `sed`, `grep`, `xargs`, `printf`, etc, for all your stream editing needs

```
gawk
```

Foreign filesystems on mac. `sshfs` from `brew install gromgit/fuse/sshfs-mac`

```
sshfs macfuse
```

A javascript runtime for servers. It's also useful for shell scripts

```
node
```

### Applications
Applications that should be considered for installation on any mac. Everything
listed here is open source. Use `brew install --cask` unless otherwise specified

Hotkey daemon for MacOS. Config files can be set up with the install script.
Either `brew services` or launchd can be used to start `skhd` automatically

```
skhd ✔️
```

The most widely used media player capable of decoding almost any format

```
vlc ✔️
```

Pairs with `vlc` to watch videos with others remotely

```
syncplay
```

Really powerful flashcard memorization software

```
anki
```

Pdf reader with contents lists and double display

```
skim
```

Installs both a gui version of vim and a more featured non-graphic version too

```
[nvchad]
[VapourNvim]
macvim
```

Best torrent client. No-nonsense and a nice interface

```
qbittorrent
```

Output or capture system-audio by providing a virtual output device

```
blackhole-2ch
```

### Power tools
Heavier applications that should be installed only on capable systems. Use `brew
install --cask` unless otherwise specified. These are all open source

Full video editor that puts iMovie to shame. Exports require a lot of cpu power

```
shotcut
```

Emulator for any operating system. Configuration is complicated. See examples in
`shell/qemu/`

```
qemu ✔️
```

Linux subsystem for mac. Essentially qemu + sshfs automated

```
lima
```

Image editing similar to Photoshop, except free and with wider platform support

```
gimp
```

Full latex support. Vim configuration and snippets are already setup. Takes
almost 10G for a base installation and runs hot

```
mactex ✔️
```

### Proprietary

Screenshot tool to fill the gap between Mac OS's screenshots and gimp

```
brew install --cask skitch
```

Alternative screenshot tool, with a few more markup options

```
brew install --cask flameshot
```


### Extra nonsense

Make banners for titles

```
figlet
```

## Mapping from linux

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

For Xorg users, `yabai` is to `skhd` what `bspwm` is to `sxhkd`. Also `launchd`
is wayyy less capable than `systemd` and rarely gets used. The `launchd` script
in `./bin` wraps around all the commands you'll ever need

To use open source apps, run `sudo spctl --master-disable`, then head to System
Preferences -> Security & Privacy -> General and select Anywhere at the bottom.
You can check it's working with `spctl --status`

While you're here, you can go under Software Updates and uncheck everything

## Window managers

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
