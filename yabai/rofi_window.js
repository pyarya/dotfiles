#!/usr/bin/env node
// Creates a rofi menu for all windows and switches to selected window
// Very buggy for some reason...
const sh = require('child_process');

let windows = sh.spawnSync("yabai", ["-m", "query", "--windows"]);

if (windows.status !== 0) {
    console.error(`Yabai window query failed with exit code ${windows.status}`);
    console.error(windows.stderr.toString());
    process.exit(1);
}

windows = JSON.parse(windows.stdout);

if (windows.length === 0)
    process.exit(0);

// Create list entries for rofi menu ===
const rofi_list = windows.map(function(win) { return {
        msg: `${win.space}. ${win.app} >>> ${win.title}`,
        space: win.space,
        id: win.id,
}});

if (rofi_list.length === 0)
    process.exit(0);

let msg = rofi_list.map(win_obj => win_obj.msg)
            .join('\n')
            .replaceAll(`'`, "")
            .replaceAll("\\", "\\\\");

let choice =
    sh.spawnSync("bash", ["-c", `printf '${msg}' | choose -i -c FABD2F -b 416A33 -f "noto sans bold" -s 30`]);

if (choice.status !== 0)
    process.exit(0);

// Focus selected space and window
let window = rofi_list[parseInt(choice.stdout.toString())];

let space = sh.spawnSync("yabai", ["-m", "query", "--spaces", "--space"]);

if (space.status !== 0) {
    console.error(`Querying space exited with code: ${space.status}`)
    console.error(space.stderr.toString());
    process.exit(1);
}

space = JSON.parse(space.stdout);

if (!space.windows.includes(window.id))
    sh.spawnSync("yabai", ["-m", "space", "--focus", window.space]);

sh.spawnSync("yabai", ["-m", "window", "--focus", window.id]);
