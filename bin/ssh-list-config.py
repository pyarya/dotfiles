#!/usr/bin/env python3
import os
import re

def bold(s):
    return "\033[1m" + s + "\033[0m"

RE_HOST = re.compile('Host (.*)')
RE_HOSTNAME = re.compile('Hostname (.*)')

with open(f"{os.environ['HOME']}/.ssh/config", 'r') as f:
    lines = [l.strip() for l in f.readlines()]

lines = list(filter(lambda x: not x.startswith('#'), lines))

l = list()

for line in lines:
    m = RE_HOST.match(line)
    n = RE_HOSTNAME.match(line)

    if m is not None:
        l.append([bold(m[1]) + ":", None])
    elif n is not None:
        l[-1][1] = n[1]

mlength = max(len(s[0]) for s in l )

l.sort(key=lambda x: x[0])

for line in l:
    print(f"{line[0]:{mlength}} {line[1]}")
