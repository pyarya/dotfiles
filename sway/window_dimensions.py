#!/usr/bin/env python3
# Return the dimensions of the current window[s] as selected in sway.
#
# Non-zero exitcode if something unexpected comes up.
#
# The printed dimensions will match the slup regex below:
#   /[0-9]+,[0-9]+ [0-9]+x[0-9]+/
import json
from subprocess import run, PIPE
from typing import Optional

def get_sway_tree() -> dict:
    swaymsg = run(["swaymsg", "-t", "get_tree"], stdout=PIPE)
    swaymsg.check_returncode()
    return json.loads(swaymsg.stdout)

def format_window_coords(window: dict, rect: dict) -> str:
    if sum(window.values()) == 0:  # Multiple windows selected
        x = rect['x']
        y = rect['y']
        w = rect['width']
        h = rect['height']
    elif window['y'] + window['height'] == rect['height']:  # Account for border
        x = rect['x'] + window['x']
        y = rect['y']
        w = window['width']
        h = window['height'] - window['y']
    else:
        x = rect['x'] + window['x']
        y = rect['y'] + window['y']
        w = window['width']
        h = window['height']

    return f"{x},{y} {w}x{h}"

# Return dict indexing path to the first entry with "key" matching "val"
# For example, it may return
#   ['nodes', 1, 'nodes', 1, 'nodes', 0, 'nodes', 0]
# Which can then be used to index the original js:
#   js['nodes'][1]['nodes'][1]['nodes'][0]['nodes'][0][find_key] == find_val
def trace_json_path(js, find_key, find_val) -> Optional[list]:
    if isinstance(js, dict):
        for key, val in js.items():
            if key == find_key and val == find_val:
                return []  # Base case

            elif isinstance(val, list):
                trace = trace_json_path(val, find_key, find_val)
                if trace is not None:
                    return [key] + trace

    elif isinstance(js, list):
        for i, item in enumerate(js):
            trace = trace_json_path(item, find_key, find_val)
            if trace is not None:
                return [i] + trace

    return None

def focused_sway_area():
    tree = get_sway_tree()
    trace = trace_json_path(tree, 'focused', True)

    if trace is None:
        print('No focused window was found')
        exit(1)

    for i in trace:
        tree = tree[i]
    return format_window_coords(tree['window_rect'], tree['rect'])

if __name__ == '__main__':
    print(focused_sway_area())
