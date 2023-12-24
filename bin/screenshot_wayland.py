#!/usr/bin/env python3
# The all-in-one solution to taking and modifying screenshots on sWayland
#
# Additional dependencies:
#  - Python's pillow library
#  - pip install --user pillow-avif-plugin  # Until PIL merges avif support
#  - grim
#  - swappy
import argparse, os, time, re, shutil, pillow_avif
from subprocess import run, Popen, PIPE, DEVNULL
from PIL import Image
from PIL.ImageFilter import GaussianBlur
from pathlib import Path
from typing import *

# Global constants
DIR = Path(f"{os.environ['HOME']}/Desktop/screenshots_tmp") # Default

DIMENSIONS_REGEX = "([0-9]+),([0-9]+) ([0-9]+)x([0-9]+)"
EXTENSION_REGEX = "\.([A-z0-9]+)$"
ORIGINAL_REGEX = "([0-9]+(_[0-9]{0,3})?)\.png"
EDIT_REGEX = "([0-9]+(_[0-9]{0,3})?)_edit_([0-9]+)" + EXTENSION_REGEX

DS_BG_LIGHT = 'white'
DS_SHADOW_LIGHT = 'black'
DS_BG_DARK = '#d3869b'
DS_SHADOW_DARK = 'black'

EDIT_QUALITY = 50

# Returns the path of the latest screenshot
def get_latest_sceenshot_path() -> Path:
    pics = [f for f in os.listdir(DIR) if os.path.isfile(DIR / f)]
    pngs = [p for p in pics if re.fullmatch("[0-9_]+\.png", p)]
    pngs.sort()
    return DIR / pngs[-1]

# Returns a path to an unused screenshot in DIR
def get_sceenshot_path() -> Path:
    t = time.time()
    p = DIR / f"{round(t)}.png"

    if os.path.isfile(p):
        return DIR / f"{str(t).replace('.', '_')}.png"
    else:
        return p

# Returns a free path to the last screenshot in DIR
#
# Example:
#   To edit the screenshot `1669235949.png` it'll return `1669235949_edit_0.png`
#   If `1669235949_edit_0.png` exists it returns `1669235949_edit_1.png`...
#   Raises IndexError if no screenshot was found in DIR
def get_edit_path(ext: str) -> (Path, Path):
    pics = [f for f in os.listdir(DIR) if os.path.isfile(DIR / f)]
    originals = [p for p in pics if re.fullmatch(ORIGINAL_REGEX, p)]
    originals.sort()

    latest = re.split(EXTENSION_REGEX, originals[-1])[0]
    edits = [p for p in pics if re.fullmatch(f"{latest}_edit_[0-9]+\.[A-z0-9]+", p)]
    edits_nums = [re.fullmatch(EDIT_REGEX, e)[3] for e in edits]
    new_index = max([int(n) for n in edits_nums] + [0]) + 1

    return DIR / originals[-1], DIR / f"{latest}_edit_{new_index}.{ext}"

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

    if args.clipboard:
        copy_to_clipboard(save_path)

    if args.file is not None:
        shutil.copyfile(save_path, args.file)

# Applies an edit to the latest screenshot
def edit_subcommand(args):
    ext = args.extension if args.extension else 'avif'
    og_path, edit_path = get_edit_path(ext)

    if args.overwrite:
        edit_path = og_path

    # Drop shadow
    match args.drop_shadow:
        case "light":
            add_drop_shadow(og_path, edit_path, DS_BG_LIGHT, DS_SHADOW_LIGHT)
        case "dark":
            add_drop_shadow(og_path, edit_path, DS_BG_DARK, DS_SHADOW_DARK)

    # Resize
    with Image.open(edit_path if args.drop_shadow else og_path) as img:
        if args.size:
            img = img.resize(args.size)
        elif args.rescale:
            img = img.reduce(int(1 / (args.rescale / 100)))
        img.save(edit_path, quality=EDIT_QUALITY, method=6)

    if args.clipboard:
        copy_to_clipboard(edit_path)

    if args.file is not None:
        shutil.copyfile(edit_path, args.file)

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

def parse_dimensions(s: str) -> str:
    s = s.strip()

    if re.fullmatch(DIMENSIONS_REGEX, s):
        return s
    raise Exception(f"`{s}` does not match pattern {DIMENSIONS_REGEX}")

def parse_percent(s: str) -> int:
    s = s.strip()
    try:
        return int(re.fullmatch('([0-9]+)%?', s)[1])
    except IndexError:
        raise Exception(f"{s} is not a valid percent. Does not match /[0-9]+%?/")

def parse_size(s: str) -> (int, int):
    s = s.strip()
    try:
        m = re.fullmatch("([0-9]+)[x ]([0-9]+)", s)
        return int(m[1]), int(m[2])
    except:
        raise Exception(f"{s} does not match size regex /[0-9]+[x ][0-9]+/")

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

take_common = argparse.ArgumentParser(add_help=False);
take_common.add_argument(
    '-c', '--clipboard',
    action='store_true',
    help='Save the screenshot to your clipboard',
);

take_common.add_argument(
    "file", nargs='?', type=Path,
    help="Save the screenshot to this file name"
);

# Different possible screenshot regions
region = take_subcmd.add_subparsers(dest='region', required=True);
full = region.add_parser(
    'full', parents=[take_common],
    help='Take a screenshot of the entire screen'
);
exact = region.add_parser(
    'exact', parents=[take_common],
    help="Exact dimensions of screenshot: 'x,y width,height'"
);
select = region.add_parser(
    'select', parents=[take_common],
    help="Use `slurp` to select a region with your mouse"
);
exact.add_argument(
    'dimensions',
    type=parse_dimensions,
    metavar="'N,N NxN'",
    help="Exact dimensions of screenshot: 'x,y width,height'"
);

# Edit ====
edit_subcmd = subcommands.add_parser(
    "edit", help="Apply an edit to the latest screenshot");
edit_subcmd.add_argument(
    '-r', '--rescale',
    type=parse_percent,
    metavar="<percent>",
    help='Rescale the latest screenshot to <precent> of the original',
);
edit_subcmd.add_argument(
    '-s', '--size',
    type=parse_size,
    metavar="<dims>",
    help='Set the dimensions of the latest screenshot',
);
edit_subcmd.add_argument(
    '-c', '--clipboard',
    action='store_true',
    help='Save the edited screenshot to your clipboard',
);
edit_subcmd.add_argument(
    '-d', '--drop-shadow',
    action='store',
    choices=['light', 'dark'],
    help='Apply a drop shadow with a light/dark background',
);
edit_subcmd.add_argument(
    '-e', '--extension',
    type=str,
    metavar="<ext>",
    help='Change image extension and image type saved',
);
edit_subcmd.add_argument(
    '--overwrite',
    action='store_true',
    help='Overwrite original image with the edited image',
);
edit_subcmd.add_argument(
    "file", nargs='?', type=Path,
    help="Save the screenshot to this file name"
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
    case "edit":
        edit_subcommand(args)
    case "markup":
        markup_latest(args)
