#!/usr/bin/env python3
# The all-in-one solution to taking and modifying screenshots on sWayland
#
# Additional dependencies:
#  - Python's pillow library
#  - pip install --user pillow-avif-plugin  # For avif support (recommended)
#  - grim
#  - swappy
import argparse, os, time, re, shutil
from subprocess import run, Popen, PIPE, DEVNULL
from PIL import Image
from PIL.ImageFilter import GaussianBlur
from pathlib import Path
from typing import *

DIR = Path(f"{os.environ['HOME']}/Desktop/screenshots_tmp") # Default

# Returns the path of the latest screenshot
def get_latest_sceenshot_path() -> Path:
    pics = [f for f in os.listdir(DIR) if os.path.isfile(DIR / f)]
    pngs = [p for p in pics if re.fullmatch("[0-9_]+\.png", p)]
    pngs.sort()
    return Path(pngs[-1])
    return pngs[-1]

# Returns a path to an unused screenshot in DIR
def get_sceenshot_path() -> Path:
    t = time.time()
    p = DIR / f"{round(t)}.png"

    if os.path.isfile(p):
        return DIR / f"{str(t).replace('.', '_')}.png"
    else:
        return p

# Copies the image to the wayland clipboard
def copy_to_clipboard(pic: Path):
    with open(pic, 'r') as img:
        run(["wl-copy"], stdin=img, timeout=4)

# Interactively gets user to select an area of the screen
# String matches regex /[0-9]+,[0-9]+ [0-9]+x[0-9]+/
# Example: 287,526 474x369
def select_area() -> str:
    slurp = run(["slurp"], text=True, stdout=PIPE)
    slurp.check_returncode()
    return slurp.stdout.strip()

# Adds drop-shadow to an image. If `img` and `save` are the same path, the image
# is overwritten
def add_drop_shadow(img: Path, save: Path, back_color: str, shadow_color: str):
    with Image.open(img) as img:
        mode = img.mode

        border_width = max(img.size) // 20  # 5% of larger dim
        width = img.size[0] + border_width*2
        height = img.size[1] + border_width*2

        shadow = Image.new(mode, img.size, color=shadow_color)
        canvas = Image.new(mode, (width, height), color=back_color)

        canvas.paste(shadow, box=(border_width, int(border_width*1.16)))
        canvas = canvas.filter(GaussianBlur(border_width // 4))

        canvas.paste(img, box=(border_width, border_width))

    canvas.save(save)

# Uses grim for wayland to take a screenshot. Default to full screen without
# dims. exact_dims must match a slurp regex
def take_screenshot(path, exact_dims=None):
    if exact_dims is not None:
        run(["grim", "-g", exact_dims, path]).check_returncode()
    else:
        run(["grim", path]).check_returncode()

# Takes a screenshot as specified by args
def take_subcommand(args):
    save_path = get_sceenshot_path()

    match args.region:
        case "full":
            take_screenshot(save_path, None)
        case "exact":
            take_screenshot(save_path, args.dimensions)
        case "select":
            take_screenshot(save_path, select_area())
        case _:
            raise Exception(f"Region '{args.region}' not recognized")

    match args.drop_shadow:
        case "light":
            add_drop_shadow(save_path, save_path, 'white', 'black')
        case "dark":
            add_drop_shadow(save_path, save_path, '#515e6e', 'black')

    if args.clipboard:
        copy_to_clipboard(save_path)

    if args.file is not None and not os.path.isfile(args.file):
        shutil.copyfile(save_path, args.file)
    elif args.file is not None:
        raise Exception(f"Refusing to overwrite {args.file}")

# Provides a drawing editor for the latest image
def markup_latest(args):
    img = get_latest_sceenshot_path()

    if args.gimp:
        print("TODO gimp")
    else:
        run(["swappy", img]).check_returncode()

    if args.clipboard:
        copy_to_clipboard(img)

# ===================================================================
# Parse args
# ===================================================================
def parser_dir(s: str):
    if os.path.isdir(s):
        return Path(s)
    else:
        raise NotADirectoryError(f"`{s}` is not a directory")

def slurp_regex(s: str) -> str:
    s = s.strip()

    if re.fullmatch('[0-9]+,[0-9]+ [0-9]+x[0-9]+', s):
        return s
    else:
        raise Exception(
            f"`{s}` does not match pattern /[0-9]+,[0-9]+ [0-9]+x[0-9]+/")

parser = argparse.ArgumentParser(
    prog="Screenshot Wayland v1.0.0",
    description='Take a screenshot on Sway'
);
parser.add_argument(
    '-s', '--screenshot-dir',
    type=parser_dir,
    metavar="<dir>",
    help='Save and edit directory. Default: ~/Desktop/screenshots_tmp',
);

# Subcommands ====
subcommands = parser.add_subparsers(dest='subcommand', required=True);
# Take ====
take_subcmd = subcommands.add_parser(
    "take", help="Takes a screenshot. (Default is full screen)");
take_subcmd.add_argument(
    '-c', '--clipboard',
    action='store_true',
    help='Save the screenshot to your clipboard',
);
take_subcmd.add_argument(
    '-d', '--drop-shadow',
    action='store',
    choices=['light', 'dark'],
    help='Apply a drop shadow to the final image with a light/dark background',
);

# Different possible screenshot regions
region = take_subcmd.add_subparsers(dest='region', required=True);
region.add_parser(
    'full', help='Take a screenshot of the entire screen');
exact = region.add_parser(
    'exact', help="Exact dimensions of screenshot: 'x,y width,height'");
region.add_parser(
    'select', help="Use `slurp` to select a region with your mouse");
exact.add_argument(
    'dimensions',
    type=slurp_regex,
    metavar="'N,N NxN'",
    help="Exact dimensions of screenshot: 'x,y width,height'"
);

take_subcmd.add_argument(
    "file", nargs='?',
    type=Path,
    help="Save the screenshot to this file name"
);
# Edit ====
edit_subcmd = subcommands.add_parser(
    "edit", help="Apply an edit to the latest screenshot");
edit_subcmd.add_argument(
    '-r', '--resize',
    type=int,
    metavar="<pixels>",
    help='Resize the latest screenshot instead of taking a new one',
);
edit_subcmd.add_argument(
    '-s', '--size',
    type=int,
    metavar="<dims>",
    help='Exact dimensions of screenshot',
);
edit_subcmd.add_argument(
    '-d', '--drop-shadow',
    type=int,
    metavar="<pixels>",
    help='Save the screenshot with a drop shadow of x pixels',
);
edit_subcmd.add_argument(
    '-e', '--extension',
    type=int,
    metavar="<ext>",
    help='Change image extension saved',
);
# Markup ====
markup_subcmd = subcommands.add_parser(
    "markup", help="Markup the latest screenshot in swappy");
markup_subcmd.add_argument(
    '-c', '--clipboard',
    action='store_true',
    help='Save the screenshot to your clipboard',
);
markup_subcmd.add_argument(
    '--gimp',
    action='store_true',
    help='Edit via gimp, instead of swappy',
);
args = parser.parse_args();

# Second layer of parser checks
if args.screenshot_dir is not None:
    DIR = args.screenshot_dir

if not os.path.isdir(DIR) and os.path.exists(DIR):
    print(f"Path `{DIR}` already exists and is not a directory")
    exit(1)
elif not os.path.exists(DIR):
    os.makedirs(DIR)

match args.subcommand:
    case "take":
        take_subcommand(args)
        pass
    case "edit":
        print("Edit is not yet ready for use")
        pass
    case "markup":
        markup_latest(args)
