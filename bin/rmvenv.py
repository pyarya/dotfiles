#!/usr/bin/env python3
import argparse
import shlex
import shutil
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser(
    prog="Remove venv v1.0.0",
    formatter_class=argparse.RawTextHelpFormatter,
    description="Remove all the venv-created files",
)
parser.add_argument(
    "--freeze",
    action="store_true",
    help="Runs a venv freeze before deleting",
)
parser.add_argument(
    "--dir",
    type=Path,
    help="Choose directory to remove venv inside",
)
args = parser.parse_args()

VENV_BASENAMES = [
    "1",
    "bin",
    "include",
    "lib",
    "lib64",
    "pyvenv.cfg",
]


def check_for_venv(directory):
    global VENV_BASENAMES

    for file in VENV_BASENAMES:
        if not (directory / file).exists():
            print(f"Missing file {file}")
            return False

    return True


def rm_venv(directory):
    for file in VENV_BASENAMES:
        p = directory / file

        if p.is_dir():
            shutil.rmtree(p)
        else:
            p.unlink()


if __name__ == "__main__":
    p = Path().cwd() if args.dir == None else args.dir

    if not check_for_venv(p):
        print("Not a venv")
        exit(1)

    if args.freeze:
        subprocess.run(
            shlex.split("bash -c '. bin/activate && pip freeze > requirements.txt'")
        )

    rm_venv(p)
