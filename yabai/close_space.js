#!/usr/bin/env node
// Closes the current space and moves all this space's windows to the left
// window. Focuses the left space after closing. If the space closed is
// left-most, the window on the right is used instead
const sh = require('child_process');

function shellCall(cmd, args, name) {
    let output = sh.spawnSync(cmd, args);

    if (output.status !== 0) {
        console.error(`${name} failed with exit code ${output.status}`);
        console.error(output.stderr.toString());
        return null
    }

    return output
}


let space = shellCall("yabai", ["-m", "query", "--spaces", "--space"], "Yabai space query");

if (space === null)
    process.exit(1);

space = JSON.parse(space.stdout);

move_to = space.index === 1 ? 2 : space.index - 1;

if (space.index === 1) {
    let spaces = shellCall("yabai", ["-m", "query", "--spaces"]) || process.exit(1);
    spaces = JSON.parse(spaces.stdout);

    if (spaces.length === 1)
        process.exit(0);

}

for (win_id of space.windows.reverse()) {
    shellCall("yabai", ["-m", "window", "--focus", win_id]);
    shellCall("yabai", ["-m", "window", "--space", move_to]);
}

shellCall("yabai", ["-m", "space", "--destroy"], "Yabai space destroy");
shellCall("yabai", ["-m", "space", "--focus", space.index === 1 ? 1 : move_to], "Yabai space focus");
