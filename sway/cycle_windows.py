#!/usr/bin/env python3
# From https://gist.github.com/SidharthArya/f4d80c246793eb61be0ae928c9184406
import sys
import json
import subprocess

direction=bool(sys.argv[1] == 'next')
swaymsg = subprocess.run(['swaymsg', '-t', 'get_tree'], stdout=subprocess.PIPE)
data = json.loads(swaymsg.stdout)
current = data["nodes"][1]["current_workspace"]
workspace = int(data["nodes"][1]["current_workspace"])-1
roi = data["nodes"][1]["nodes"][workspace]
temp = roi
windows = list()

def getNextWindow():
    if focus < len(windows) - 1:
        return focus+1
    else:
        return 0

def getPrevWindow():
    if focus > 0:
        return focus-1
    else:
        return len(windows)-1

def makelist(temp):
    for nodes in "floating_nodes", "nodes":
        for i in range(len(temp[nodes])):
            if temp[nodes][i]["name"] is None:
               makelist(temp[nodes][i])
            else:
               windows.append(temp[nodes][i])

def focused(temp_win):
    for i in range(len(temp_win)):
        if temp_win[i]["focused"] == True:
           return i

makelist(temp)
focus = focused(windows)

if direction:
    attr = f"[con_id={windows[getNextWindow()]['id']}]"
else:
    attr = f"[con_id={windows[getPrevWindow()]['id']}]"

sway = subprocess.run(['swaymsg', attr, 'focus'])
sys.exit(sway.returncode)
