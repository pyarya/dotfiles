#!/usr/bin/env python3
import argparse
import csv
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from subprocess import PIPE

parser = argparse.ArgumentParser(
    prog=f"log_storage",
    description=f"Store storage info into a csv file",
)

parser.add_argument(
    "file",
    type=Path,
    help=f"Path to the csv, or - for stdout",
)

args = parser.parse_args()
if str(args.file) == "-":
    args.file = Path("/dev/stdout")


class Disk:
    columns = [
        "date",
        "uuid",
        "label",
        "device",
        "fstype",
        "partition_number",
        "parent_device",
        "used_space",  # In bytes
        "size",        # In bytes
    ]

    date = None  # This is set later

    def __init__(self):
        self.uuid = None
        self.fstype = None
        self.device = None
        self.label = None
        self.partition_number = None
        self.parent_device = None
        self.used_space = None
        self.size = None

    def as_csv(self):
        return [getattr(self, c) for c in self.columns]


def read_sysfs(p):
    with open(p, "r") as f:
        return f.read().strip()


def mount_line_info(p):
    with open("/proc/mounts", "r") as f:
        for line in [l.strip().split() for l in f]:
            if line[0] == str(p):
                du = shutil.disk_usage(line[1])

                return {
                    "total": du.total,
                    "used": du.used,
                    "fstype": line[2],
                }

    return None


def mount_info(p):
    # Check if partition is already in /proc/mounts
    info = mount_line_info(p)

    if info is not None:
        return info

    # Quickly mount and unmount a partition to populate /proc/mounts
    tmpd = tempfile.mkdtemp()

    mount = subprocess.run(["mount", p, tmpd], stderr=PIPE)

    if mount.returncode == 0:
        info = mount_line_info(p)

        subprocess.run(["umount", p], check=True)
        os.rmdir(tmpd)

        return info
    else:
        mount_stderr = mount.stderr.decode("utf-8")
        m = re.search("unknown filesystem type '([^' ]+)'\.", mount_stderr)

        if m is None:
            return None
        else:
            return {"fstype": m[1]}


sysfs = "/sys/class/block"

uuid_path = "/dev/disk/by-uuid"
disk_paths = [Path(f"{uuid_path}/{x}") for x in os.listdir(uuid_path)]
disk_paths = list(filter(lambda x: x.is_symlink(), disk_paths))

label_path = "/dev/disk/by-label"

try:
    label_paths = [Path(f"{label_path}/{x}") for x in os.listdir(label_path)]
except FileNotFoundError:
    label_paths = list()

# Get label paths
device_to_label = dict()

for p in label_paths:
    os.chdir(label_path)
    device_to_label[str(p.readlink().resolve())] = p.name

# Build disks
disks = list()

for p in disk_paths:
    disk = Disk()

    os.chdir(uuid_path)
    disk.device = p.readlink().resolve()

    sysfs_disk = Path(f"{sysfs}/{disk.device.name}")

    disk.uuid = p.name
    disk.parent_device = Path("/dev") / sysfs_disk.readlink().parent.resolve().name
    disk.partition_number = read_sysfs(sysfs_disk / "partition")
    disk.label = device_to_label.get(str(disk.device))

    info = mount_info(disk.device)

    if info is not None:
        disk.size = info.get("total")
        disk.used_space = info.get("used")
        disk.fstype = info.get("fstype")

    disks.append(disk)

# Write output to csv
Disk.date = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")

if str(args.file) == "/dev/stdout" or not os.path.exists(args.file):
    with open(args.file, "w") as csvf:
        writer = csv.writer(
            csvf, dialect="unix", delimiter=",", quoting=csv.QUOTE_MINIMAL
        )
        writer.writerow(Disk.columns)

with open(args.file, "a") as csvf:
    writer = csv.writer(csvf, dialect="unix", delimiter=",", quoting=csv.QUOTE_MINIMAL)
    for disk in disks:
        writer.writerow(disk.as_csv())
