Hit the ground flying with dotfiles for Unix-like systems including MacOS. These
contain all sorts of goodies for bash, vim, shell scripts, unix notes, and much
more!

# Installation

```bash
git clone --depth=1 'ssh://git@codeberg.org:22/akemi/dotfiles.git' dotfiles
cd dotfiles
bash ./install.sh --help
```

`install.sh status` tells you which files can be linked and which ones are
already on your system. Move the ones on your system out of the way before
continuing

```bash
bash install.sh install
bash install_packages.sh install
```

If you're running ArchLinux or EndeavourOS, `post_install.sh` will help guide
you through additional installation steps you can take. See
`./notes/futher_installation/` for a description of these steps

## Support

Official support is for the latest version of bash and EndeavourOS only. The
MacOS dotfiles were working on Catalina (10.15) and likely mostly work on newer
versions as well

As of writing, [EndeavourOS](
https://endeavouros.com/) is on Linux **6.0.11** and bash is version **5.1.16**

For Linux, these dotfiles setup [Sway](https://github.com/swaywm/sway) on
[Wayland](https://wayland.freedesktop.org/), a completely different display
server from Xorg. [I3](https://i3wm.org/) is similar to Sway for Xorg

Increasingly, I've been migrating my scripts away from bash, for better control
flow, libraries, and error handling. Several are written in python. **Python
version 3.10** (match statements) is the minimum supported version.

Some scripts are being __rewritten in :rocket: Rust :rocket:__! Building them
them will require a [rust compiler](https://rustup.rs). If one of your machines
isn't powerful enough to compile these, consider compiling them on another
system, then simply copy them over:

```bash
cargo build --release --target=x86_64-unknown-linux-musl
```

# Keybinding

Generally keybindings follow this scheme for `skhd`/`xremap`, bash, and vim's
insert mode. They roughly resemble Emac's default. Outliers are bolded. These
are written assuming Ctrl is mapped to CapsLock

When possible selecting is preferred to actually deleting the text

| Type | Start of line | Back word | Back character | Forward character | Forward word | End of line |
| ---- | ------------- | --------- | -------------- | ----------------- | ------------ | ----------- |
| Movement | `^a`      | **`^b`**  |    **`^j`**    |       `^f`        |   **`^w`**   |    `^e`     |
| Deletion |           | **`^u`**  |      `^h`      |       `^d`        |              |    `^k`     |

Window managers are bound to the Super/Command/Logo key. This is the key
adjacent to the spacebar

# Light and Dark Mode

Alacritty, tmux, vim, vifm, vimiv are all synchronously colored through
`bin/colo.sh`. This script supports multiple color schemes and makes it easy to
add new ones.

In running instances of vim and vifm, use `:Light` or `:Dark` to update their
color scheme to match Alacritty. New instances are automatically updated
