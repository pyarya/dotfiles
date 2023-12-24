#!/usr/bin/env python3
import argparse
import re
import sys
from subprocess import Popen

SSH_RE = re.compile(r"(ssh://)?git@([^/]+):([^/]+)/([^/]+)(/[^/]+)?.*")
HTTP_RE = re.compile(r"https://([^/]+)/([^/]+)/([^/]+).*")

parser = argparse.ArgumentParser(
    prog="Clone with SSH v1.0.0",
    description="Git-clone an http link as ssh instead",
)

parser.add_argument(
    "url",
    type=str,
    help="HTTP or ssh url to use",
)

args = parser.parse_args()

if m := HTTP_RE.fullmatch(args.url):
    ssh_url = f"ssh://git@{m[1]}:22/{m[2]}/{m[3]}"
elif m := SSH_RE.fullmatch(args.url):
    ssh_url = f"ssh://git@{m[2]}:22/{m[3]}/{m[4]}"
else:
    print(f"Failed to parse URL `{args.url}`", file=sys.stderr)
    exit(1)

if "git.sr.ht" not in args.url and not ssh_url.endswith('.git'):
    ssh_url += ".git"

Popen(["git", "clone", ssh_url]).wait()
