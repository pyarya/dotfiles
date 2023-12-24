#!/usr/bin/env node
// "Pins" a window id to a number and saves it in
// ~/.config/yabai/pinnned_windows.json
//
// Args:
//   --set <pin> <id> : Overwrites <pin> with <id>
//   --focus <pin>    : Focuses window with id <pin>, if it's still around
//   --rofi           : Pulls up a rofi menu to select from pinned windows
//   --clear          : Removes all current pins
//
// Examples:
//   ./pin_window.js --set 1 120
//   ./pin_window.js --set 4 130
//   ./pin_window.js --focus 4
//   ./pin_window.js --focus 8
//   ./pin_window.js --rofi    # Pulls up gui rofi menu
//   ./pin_window.js --clear   # Removes ~/.config/yabai/pinned_windows.json
//
const sh = require('child_process');
const fs = require('fs');
const file_path = process.env.HOME + '/.config/yabai/pinned_windows.json';

const mode = process.argv[2];
const pin = process.argv[3];
const id = process.argv[4];


// Parse flags
if (mode === "--set") updatePins(pin, id);
else if (mode === "--focus") focusPin(pin);
else if (mode === "--clear") fs.unlinkSync(file_path);
else if (mode === "--rofi")  rofiMenu();
else console.error(`Mode ${mode} is invalid`);


// Changes space and focuses on the window at specified pin
function focusPin(pin) {
    const pins = updatePins();

    const id = parseInt(pins[pin]["id"]);
    const space_index = parseInt(pins[pin]["space"]);

    let space = sh.spawnSync("yabai", ["-m", "query", "--spaces", "--space"]);

    if (space.status !== 0) {
        console.error(`Querying space exited with code: ${space.status}`)
        console.error(space.stderr.toString());
        process.exit(1);
    }

    space = JSON.parse(space.stdout);

    if (!space.windows.includes(id))
        sh.spawnSync("yabai", ["-m", "space", "--focus", space_index]);

    sh.spawnSync("yabai", ["-m", "window", "--focus", id]);
}


// Queries and updates ~/.config/yabai/pinned_windows.json by making sure all
// windows specified are still running and updates titles. Passing in argument
// adds a new window
//
// Args:
//   new_pin (string | number) : Hotkey for pin
//   new_id (string | number)  : Id of newly pinned window
//
// Returns:
//   obj: Latest pins. Same as those saved to the file
function updatePins(new_pin, new_id) {
    if (global.pins && !new_pin && !new_id)
        return global.pins;   // Prevent double updates

    // Specifies the format of a pin object for each window
    function pinObject(pin, id) {
        let query = sh.spawnSync("yabai", ["-m", "query", "--windows", "--window", id]);

        if (query.status === 0) {
            let info = JSON.parse(query.stdout);

            return {
                pin: pin,
                id: id,
                app: info.app,
                title: info.title,
                space: info.space,
            }
        } else {
            return null
        }
    }

    let old_pins;
    try {
        old_pins = JSON.parse(fs.readFileSync(file_path));
    } catch {
        old_pins = {};
    }

    // Upate old pins
    let new_pins = {};

    for (const [pin, data] of Object.entries(old_pins)) {
        let pin_obj = pinObject(pin, data.id);

        if (pin_obj !== null)
            new_pins[pin] = pin_obj;
    }

    // Seed new pin
    if (new_pin && new_id) {
        let pin_obj = pinObject(new_pin, new_id);

        if (pin_obj !== null)
            new_pins[pin] = pin_obj;
    }


    // Save updated
    fs.writeFileSync(file_path, JSON.stringify(new_pins));
    global.pins = new_pins;  // Prevent double updates

    return new_pins
}


// Creates a rofi menu and switches to that window
function rofiMenu() {
    const pins = updatePins();

    // Create list entries for rofi menu
    const rofi_list = Object.entries(pins).map(([_, info]) =>
        [info.pin, `${info.pin}. ${info.app} >>> ${info.title}`]);


    if (rofi_list.length) {
        let msg = rofi_list.map(([_, s]) => s).join('\n')
                    .replaceAll(`'`, "")
                    .replaceAll("\\", "\\\\");

        let choice = sh.spawnSync("bash", ["-c", `printf '${msg}' | choose -i -c FABD2F -b 416A33 -f "noto sans bold" -s 30`]);

        if (choice.status === 0) {
            let pin = rofi_list[parseInt(choice.stdout.toString())][0];

            focusPin(pin);
        }
    }
}
