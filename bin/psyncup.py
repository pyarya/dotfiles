#!/usr/bin/env python3
import argparse
import datetime as dt
import json
import os
import subprocess

CONFIG_NAME = ".psyncup.json"

epilog = (
    """\
This program reads configuration from a file called """
    + CONFIG_NAME
    + """, which must be
in the same directory as the script runs in. For example:

{
    "ssh_remote": "emiliko@10.0.0.1",
    "remote_dir": "/home/emiliko/.configs_pointer",
    "update_date": "2023-12-01_01:01:01_UTC",
    "exclude": [
        ".git",
        "bin/rewritten_in_rust/target"
    ]
}"""
)

parser = argparse.ArgumentParser(
    prog="PySynchronize Up v1.0.0",
    formatter_class=argparse.RawTextHelpFormatter,
    description="Wrapper around rsync to easily develop on multiple remotes",
    epilog=epilog,
)
parser.add_argument(
    "--debug",
    action="store_true",
    help="Show rsync progress bar and additional debugging info",
)
parser.add_argument(
    "--dry-run",
    action="store_true",
    help="Runs the rsync, without writing any changes to local or remote",
)
parser.add_argument(
    "--no-compress",
    action="store_true",
    help="Don't use -z when rsyncing. ~5x faster over 1G LAN",
)
parser.add_argument(
    "--no-delete",
    action="store_true",
    help="Don't delete all non-matching files when rsyncing",
)

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument(
    "-c",
    "--check",
    action="store_true",
    help="Check if the latest sync has been pulled from remote",
)
group.add_argument(
    "-u",
    "--up",
    action="store_true",
    help="Overwrite remote with local changes",
)
group.add_argument(
    "-d",
    "--down",
    action="store_true",
    help="Overwrite local with remote changes",
)
group.add_argument(
    "--init",
    type=str,
    metavar="<remote-directory>",
    action="store",
    help="Initialized current directory by pulling from remote path",
)

args = parser.parse_args()


# ==== Read in config file ====
def get_config():
    global CONFIG_NAME

    try:
        with open(CONFIG_NAME, "r") as f:
            config = json.load(f)

        config["ssh_remote"]
        config["remote_dir"]

        # Standardize rsync's handling of tailing /
        if config["remote_dir"][-1] == "/" and config["remote_dir"] != "/":
            config["remote_dir"] = config["remote_dir"][:-1]
    except FileNotFoundError:
        print(f"ERROR: {CONFIG_NAME} file was not found in this directory")
        print(epilog)
        exit(1)
    except KeyError as e:
        print(f"ERROR: {CONFIG_NAME} is missing required key {e}")
        exit(1)

    return config


# ==== Construct an rsync command ====
def build_commands(args, config):
    rsync_cmd = [
        "rsync",
        "--archive",
        "--human-readable",
    ]

    if not args.no_compress:
        rsync_cmd.append("--compress")

    if not args.no_delete:
        rsync_cmd.append("--delete-during")

    if args.dry_run:
        rsync_cmd.append("--dry-run")

    if args.debug:
        rsync_cmd.append("--info=progress2")

    if config.get("exclude") is not None:
        for x in config["exclude"]:
            rsync_cmd.append(f"--exclude={x}")

    ssh_cmd = [
        "ssh",
        config["ssh_remote"],
        f"cat {config['remote_dir']}/{CONFIG_NAME}",
    ]

    remote_dir_str = config["ssh_remote"] + ":" + config["remote_dir"] + "/"

    if args.debug:
        print("DEBUG rsync command: ", rsync_cmd)
        print("DEBUG ssh copy command: ", ssh_cmd)
        print("DEBUG rsync remote directory path: ", remote_dir_str)

    return rsync_cmd, ssh_cmd, remote_dir_str


# ==== Perform command =====
def run_init(remote_dir, is_debug=False):
    rsync_cmd = [
        "rsync",
        f"{remote_dir}/{CONFIG_NAME}",
        ".",
    ]

    if is_debug:
        print("DEBUG rsync init cmd: ", rsync_cmd)

    rsync_code = subprocess.call(rsync_cmd)

    if rsync_code != 0:
        if is_debug:
            print(f"rsync exited with code {rsync_code}")
        print(f"Failed to get {CONFIG_NAME} from {remote_dir}")
        exit(1)


def run_check(ssh_cmd, config):
    check = subprocess.Popen(
        ssh_cmd,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )

    try:
        remote_config_str = check.communicate(timeout=6)[0].decode("utf-8")
    except subprocess.TimeoutExpired:
        print("Failed to connect to remote (timed out)")
        exit(1)

    try:
        remote_config = json.loads(remote_config_str)
    except json.JSONDecodeError:
        print(f"Failed to read remote {CONFIG_NAME}")
        exit(1)

    if not remote_config.get("update_date"):
        print("Remote has no last update_date (probably in sync)")
    elif not config.get("update_date"):
        print("Out of date with remote")
    elif config["update_date"] > remote_config["update_date"]:
        print("Ahead of remote")
    elif config["update_date"] < remote_config["update_date"]:
        print("Behind remote")
    else:
        print("Up to date with remote")


def run_up(rsync_cmd, remote_dir_str, config):
    rsync_cmd.append(os.getcwd() + "/")
    rsync_cmd.append(remote_dir_str)

    config["update_date"] = dt.datetime.now(dt.timezone.utc).strftime(
        "%Y-%m-%d_%H:%M:%S_UTC"
    )
    with open(CONFIG_NAME, "w") as f:
        json.dump(config, f, indent=4)

    rsync_code = subprocess.call(rsync_cmd)

    if rsync_code != 0:
        print(f"Rsync exited with code {rsync_code}")
        exit(1)


def run_down(rsync_cmd, remote_dir_str):
    rsync_cmd.append(remote_dir_str)
    rsync_cmd.append(os.getcwd())

    rsync_code = subprocess.call(rsync_cmd)

    if rsync_code != 0:
        print(f"Rsync exited with code {rsync_code}")
        exit(1)


if __name__ == "__main__":
    if args.init:
        run_init(args.init, args.debug)
        args.down = True

    config = get_config()

    if args.check:
        _, ssh_cmd, _ = build_commands(args, config)
        run_check(ssh_cmd, config)
    elif args.up:
        rsync_cmd, _, remote_dir_str = build_commands(args, config)
        run_up(rsync_cmd, remote_dir_str, config)
    elif args.down:
        rsync_cmd, _, remote_dir_str = build_commands(args, config)
        run_down(rsync_cmd, remote_dir_str)
    else:
        print("Unexpected error")
        exit(2)
