#!/usr/bin/env python3
import argparse, sys

# Parse args
parser = argparse.ArgumentParser(prog="FitWidth v1.0.0",
    description='Fit text (stdin|file) to a given character width');
parser.add_argument('-t', '--truncate', action='store_true',
    help='Truncate longer lines with a "..."');
parser.add_argument('-w', '--wrap', action='store_true',
    help='Wrap longer lines across two lines with a ">" at the end');
parser.add_argument('width', type=int,
    help='Wrap longer lines across two lines with a ">" at the end');
parser.add_argument('file', type=argparse.FileType('r'), nargs='?',
    help="File to read from, instead of stdin");
args = parser.parse_args();

# Validate args
if not args.truncate and not args.wrap:
    args.truncate = True

if args.width < 10:
    print("Minimum width is 10")
    exit(1);

if args.file is not None:
    file = args.file
elif not sys.stdin.isatty():
    file = sys.stdin
else:
    print("Please provide a file or pipe in text to fit")
    exit(1)

# Print out file
w = args.width

for line in file:
    line = line.rstrip()

    if len(line) > w:
        if args.truncate:
            print(line[:w-3] + "...")
        else:
            i = w-1
            print(line[:i] + ">")
            while i < len(line):
                print(">" + line[i:i+w-1])
                i += w-1
    else:
        print(line)

file.close()
