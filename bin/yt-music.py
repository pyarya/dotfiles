#!/usr/bin/env python3
import argparse
import os
import shutil
import sys
import tempfile
from subprocess import Popen

parser = argparse.ArgumentParser(
    prog="yt-dlp wrapper v1.0.0",
    description="Download an mp3 from youtube",
)

parser.add_argument(
    "url",
    type=str,
    help="URL to youtube video to download",
)

parser.add_argument(
    "name",
    type=str,
    help="File name for the mp3",
)

args = parser.parse_args()

if shutil.which("yt-dlp") is None:
    print("Required command `yt-dlp` not found", file=sys.stderr)
    exit(1)
elif shutil.which("ffmpeg") is None:
    print("Required command `ffmpeg` not found", file=sys.stderr)
    exit(1)

init_dir = os.getcwd()

with tempfile.TemporaryDirectory() as tmpdirname:
    os.chdir(tmpdirname)

    exit_code = Popen(["yt-dlp", args.url]).wait()

    if exit_code != 0:
        print(f"yt-dlp failed with exit code {exit_code}", file=sys.stderr)
        exit(1)

    if len(os.listdir()) != 1:
        for f in os.listdir():
            print(f)
        print(f"Incorrect number of files downloaded", file=sys.stderr)
        exit(1)

    downloaded = os.listdir()[0]
    save_name = init_dir + "/" + args.name

    if not save_name.endswith(".mp3"):
        save_name += ".mp3"

    Popen(["ffmpeg", "-i", downloaded, save_name]).wait()
    print(f"Done: music saved as `{save_name}`")
