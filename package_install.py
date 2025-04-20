#!/usr/bin/env python3
# A base package installer for many systems!
# Supported package managers:
#  - apt (debian/ubuntu)
#  - dnf (fedora/redhat)
#  - pacman (arch/endeavour)
import os
import shutil
import subprocess

PACKAGE_MANAGERS = {
    "apk": {
        "name": "apk",
        "install_cmd": ["apk", "add"],
        "check_installed": ["apk", "info", "--installed"],
    },
    "apt": {
        "name": "apt",
        "install_cmd": ["apt", "install"],
        "check_installed": ["dpkg", "-s"],  # Must return 0
    },
    "dnf": {
        "name": "dnf",
        "install_cmd": ["dnf", "install"],
        "check_installed": ["dnf", "list"],
    },
    "pacman": {
        "name": "pacman",
        "install_cmd": ["pacman", "-S"],
        "check_installed": ["pacman", "-Qi"],
    },
}

PACKAGES = [
    {
        "global_name": "alacritty",
        "executable_name": "alacritty",
        "apk": "alacritty",
        "apt": "alacritty",
        "dnf": "alacritty",
        "pacman": "alacritty",
    },
    {
        "global_name": "bat",
        "executable_name": "bat",
        "apk": "bat",
        "apt": "bat",
        "dnf": "bat",
        "pacman": "bat",
    },
    {
        "global_name": "bash",
        "executable_name": "bash",
        "apk": "bash",
        "apt": "bash",
        "dnf": "bash",
        "pacman": "bash",
    },
    {
        "global_name": "bash-completion",
        "apt": "bash-completion",
        "dnf": "bash-completion",
        "pacman": "bash-completion",
    },
    {
        "global_name": "calc",
        "executable_name": "calc",
        "apt": "calc",
        "dnf": "calc",
        "pacman": "calc",
    },
    {
        "global_name": "curl",
        "executable_name": "curl",
        "apk": "curl",
        "apt": "curl",
        "dnf": "curl",
        "pacman": "curl",
    },
    {
        "global_name": "dust",
        "executable_name": "dust",
        "apk": "dust",
        "pacman": "dust",
    },
    {
        "global_name": "exa -> eza",
        "executable_name": "exa",
        "apk": "exa",
        "apt": "exa",
        "dnf": "eza",
        "pacman": "eza",
    },
    {
        "global_name": "fd-find",
        "executable_name": "fd",
        "apk": "fd",
        "apt": "fd-find",
        "dnf": "fd-find",
        "pacman": "fd",
    },
    {
        "global_name": "foliate",
        "executable_name": "foliate",
        "apk": "foliate",
        "apt": "foliate",
        "dnf": "foliate",
        "pacman": "foliate",
    },
    {
        "global_name": "fuzzel",
        "executable_name": "fuzzel",
        "apk": "fuzzel",
        "apt": "fuzzel",
        "dnf": "fuzzel",
        "pacman": "fuzzel",
    },
    {
        "global_name": "fzf",
        "executable_name": "fzf",
        "apk": "fzf",
        "apt": "fzf",
        "dnf": "fzf",
        "pacman": "fzf",
    },
    {
        "global_name": "gawk",
        "executable_name": "gawk",
        "apk": "gawk",
        "apt": "gawk",
        "dnf": "gawk",
        "pacman": "gawk",
    },
    {
        "global_name": "git",
        "executable_name": "git",
        "apk": "git",
        "apt": "git",
        "dnf": "git",
        "pacman": "git",
    },
    {
        "global_name": "git-lfs",
        "executable_name": "git-lfs",
        "apk": "git-lfs",
        "apt": "git-lfs",
        "dnf": "git-lfs",
        "pacman": "git-lfs",
    },
    {
        "global_name": "pass",
        "executable_name": "pass",
        "apk": "pass",
        "apt": "pass",
        "dnf": "pass",
        "pacman": "pass",
    },
    {
        "global_name": "swappy",
        "executable_name": "swappy",
        "dnf": "swappy",
        "pacman": "swappy",
    },
    {
        "global_name": "imv",
        "executable_name": "imv",
        "apk": "imv",
        "apt": "imv",
        "dnf": "imv",
        "pacman": "imv",
    },
    {
        "global_name": "jq",
        "executable_name": "jq",
        "apk": "jq",
        "apt": "jq",
        "dnf": "jq",
        "pacman": "jq",
    },
    {
        "global_name": "Meslo Nerd font",
        "apk": "font-meslo-nerd",
        "pacman": "ttf-meslo-nerd",
    },
    {
        "global_name": "mmv",
        "executable_name": "mmv",
        "apt": "mmv",
        "dnf": "mmv",
    },
    {
        "global_name": "mpv",
        "executable_name": "mpv",
        "apk": "mpv",
        "apt": "mpv",
        "dnf": "mpv",
        "pacman": "mpv",
    },
    {
        "global_name": "fastfetch",
        "executable_name": "fastfetch",
        "apk": "fastfetch",
        "apt": "fastfetch",
        "dnf": "fastfetch",
        "pacman": "fastfetch",
    },
    {
        "global_name": "neovim",
        "executable_name": "nvim",
        "apk": "neovim",
        "apt": "neovim",
        "dnf": "neovim",
        "pacman": "neovim",
    },
    {
        "global_name": "pynvim",
        "apk": "py3-pynvim",
        "apt": "python3-pynvim",
        "dnf": "python3-neovim",
        "pacman": "python-pynvim",
    },
    {
        "global_name": "ripgrep",
        "executable_name": "rg",
        "apk": "ripgrep",
        "apt": "ripgrep",
        "dnf": "ripgrep",
        "pacman": "ripgrep",
    },
    {
        "global_name": "socat",
        "executable_name": "socat",
        "apk": "socat",
        "apt": "socat",
        "dnf": "socat",
        "pacman": "socat",
    },
    {
        "global_name": "waybar",
        "executable_name": "waybar",
        "apk": "waybar",
        "apt": "waybar",
        "dnf": "waybar",
        "pacman": "waybar",
    },
    {
        "global_name": "niri",
        "executable_name": "niri",
        "apk": "niri",
        "apt": "niri",
        "dnf": "niri",
        "pacman": "niri",
    },
    {
        "global_name": "swaybg",
        "executable_name": "swaybg",
        "apk": "swaybg",
        "apt": "swaybg",
        "dnf": "swaybg",
        "pacman": "swaybg",
    },
    {
        "global_name": "swaybg",
        "executable_name": "swaybg",
        "apk": "swaybg",
        "apt": "swaybg",
        "dnf": "swaybg",
        "pacman": "swaybg",
    },
    {
        "global_name": "swaync",
        "executable_name": "swaync",
        "apk": "swaync",
        "apt": "swaync",
        "dnf": "swaync",
        "pacman": "swaync",
    },
    {
        "global_name": "swaylock",
        "executable_name": "swaylock",
        "apk": "swaylock",
        "apt": "swaylock",
        "dnf": "swaylock",
        "pacman": "swaylock",
    },
    {
        "global_name": "tealdeer",
        "executable_name": "tldr",
        "apt": "tealdeer",
        "dnf": "tealdeer",
        "pacman": "tealdeer",
    },
    {
        "global_name": "tmux",
        "executable_name": "tmux",
        "apk": "tmux",
        "apt": "tmux",
        "dnf": "tmux",
        "pacman": "tmux",
    },
    {
        "global_name": "udisks2",
        "executable_name": "udisksctl",
        "apk": "udisks2",
        "apt": "udisks2",
        "dnf": "udisks2",
        "pacman": "udisks2",
    },
    {
        "global_name": "vifm",
        "executable_name": "vifm",
        "apk": "vifm",
        "apt": "vifm",
        "dnf": "vifm",
        "pacman": "vifm",
    },
    {
        "global_name": "viu",
        "executable_name": "viu",
        "apk": "viu",
        "pacman": "viu",
    },
    {
        "global_name": "wl-clipboard",
        "executable_name": "wl-copy",
        "apk": "wl-clipboard",
        "apt": "wl-clipboard",
        "dnf": "wl-clipboard",
        "pacman": "wl-clipboard",
    },
    {
        "global_name": "wlsunset",
        "executable_name": "wlsunset",
        "apk": "wlsunset",
        "apt": "wlsunset",
        "dnf": "wlsunset",
        "pacman": "wlsunset",
    },
    {
        "global_name": "wtype",
        "executable_name": "wtype",
        "apk": "wtype",
        "apt": "wtype",
        "dnf": "wtype",
        "pacman": "wtype",
    },
    {
        "global_name": "ydotool",
        "executable_name": "ydotool",
        "apt": "ydotool",
        "dnf": "ydotool",
        "pacman": "ydotool",
    },
    {
        "global_name": "zathura-pdf-mupdf",
        "apk": "zathura-pdf-mupdf",
        "dnf": "zathura-pdf-mupdf",
        "pacman": "zathura-pdf-mupdf",
    },
    {
        "global_name": "zathura",
        "executable_name": "zathura",
        "apk": "zathura",
        "apt": "zathura",
        "dnf": "zathura",
        "pacman": "zathura",
    },
]

WEB_INSTALLS = [
    {
        "name": "git prompt for bash",
        "dest": f"{os.environ['HOME']}/.git-prompt.bash",
        "url": "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh",
    },
    {
        "name": "Git completion for bash",
        "dest": f"{os.environ['HOME']}/.git-completion.bash",
        "url": "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash",
    },
    {
        "name": "Fzf completion for bash",
        "dest": f"{os.environ['HOME']}/.fzf.bash",
        "url": "https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.bash",
    },
]


def extra_installs():
    rustup_cmd = [
        "bash",
        "-c",
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
    ]

    tmp_cmds = [
        [
            "git",
            "clone",
            "--depth",
            "1",
            "https://github.com/tmux-plugins/tpm",
            f"{os.environ['HOME']}/.config/tmux/plugins/tpm",
        ],
        [f"{os.environ['HOME']}/.config/tmux/plugins/tpm/tpm"],
        [f"{os.environ['HOME']}/.config/tmux/plugins/tpm/bin/install_plugins"],
        [f"{os.environ['HOME']}/.config/tmux/plugins/tpm/tpm"],
    ]

    if not shutil.which("rustc") and prompt_user("rustup"):
        subprocess.call(rustup_cmd)

    has_tmp = os.path.exists(f"{os.environ['HOME']}/.config/tmux/plugins/tpm/tpm")

    if not has_tmp and prompt_user("tmp, tmux's package manager"):
        success = subprocess.call(tmp_cmds[0]) == 0

        if success:
            success = subprocess.call(tmp_cmds[1]) == 0
        if success:
            success = subprocess.call(tmp_cmds[2]) == 0
        if success:
            success = subprocess.call(tmp_cmds[3]) == 0


def find_package_manager():
    global PACKAGE_MANAGERS

    if shutil.which("apk"):
        return PACKAGE_MANAGERS["apk"]
    elif shutil.which("apt"):
        return PACKAGE_MANAGERS["apt"]
    elif shutil.which("dnf"):
        return PACKAGE_MANAGERS["dnf"]
    elif shutil.which("pacman"):
        return PACKAGE_MANAGERS["pacman"]
    else:
        raise Exception("Supported package manager not found")


def check_installed(pkg, apt):
    if pkg.get("executable_name") and shutil.which(pkg["executable_name"]):
        return "true"
    elif not pkg.get(apt["name"]):
        return "unavailable"

    check_cmd = list(apt["check_installed"])
    check_cmd.append(pkg[apt["name"]])

    check = subprocess.Popen(
        check_cmd,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    check.wait()
    if check.returncode == 0:
        return "true"
    else:
        return "false"


def prompt_user(pkg_name):
    while True:
        user_in = input(f"Install {pkg_name}? (Y/n) ")

        if user_in == "" or user_in[0].lower() == "y":
            return True
        elif user_in[0].lower() == "n":
            return False


def install_package(apt, package):
    install_cmd = list(apt["install_cmd"])
    install_cmd.append(package[apt["name"]])

    install = subprocess.call(install_cmd)

    return install == 0


def install_packages(apt):
    global PACKAGES

    for package in PACKAGES:
        pkg_name = package["global_name"]
        installed = check_installed(package, apt)

        if installed == "unavailable":
            print(f"≠ Cannot install {pkg_name} with {apt['name']}")
        elif installed == "true":
            print(f"✓ Already installed {pkg_name}")
        elif prompt_user(pkg_name):
            if install_package(apt, package):
                print(f"★ Newly installed {pkg_name}")
            else:
                print(f"✗ Failed to install {pkg_name}")
        else:
            print(f"φ Not installing {pkg_name}")


def web_installs():
    global WEB_INSTALLS

    for package in WEB_INSTALLS:
        if not os.path.exists(package["dest"]) and prompt_user(package["name"]):
            subprocess.call([
                "curl",
                "--output",
                package["dest"],
                package["url"],
            ])


if __name__ == "__main__":
    try:
        apt = find_package_manager()
        print(f"Identified `{apt['name']}` as system package manager")

        install_packages(apt)

        if shutil.which("curl"):
            web_installs()
            extra_installs()
    except KeyboardInterrupt:
        print("\nExiting installation. Feel free to restart where you left off")
