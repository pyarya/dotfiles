#!/usr/bin/env node
// Creates a new space on the right and moves the current window into it
const sh = require('child_process');

let win = sh.spawnSync("yabai", ["-m", "query", "--windows", "--window"]);

if (win.status !== 0) {
    console.error(`Yabai space query failed with exit code ${win.status}`);
    console.error(win.stderr.toString());
    process.exit(1);
}

win = JSON.parse(win.stdout);

sh.spawnSync("yabai", ["-m", "space", "--create"]);
sh.spawnSync("yabai", ["-m", "window", "--space", "last"]);
sh.spawnSync("yabai", ["-m", "space", "--focus", "last"]);
sh.spawnSync("yabai", ["-m", "space", "--move", win.space + 1]);
sh.spawnSync("yabai", ["-m", "window", "--focus", win.id]);
