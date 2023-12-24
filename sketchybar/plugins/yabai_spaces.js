#!/usr/bin/env node
// Tmux-line inspired yabai spaces on sketchybar
const sh = require('child_process');

const mode = process.argv[2];
const curr_space_id = process.env.YABAI_SPACE_ID;
const prev_space_id = process.env.YABAI_RECENT_SPACE_ID;

if (mode === "--update" )
    updateSketchybar();
else if (mode === "--refresh")
    refreshOnly(prev_space_id, curr_space_id);
else
    console.error(`Mode ${mode} is invalid\nUse one of --refresh or --update`);

// Wrapper around child process spawn
function spawn(cmd, args, name) {
    let output = sh.spawnSync(cmd, args);

    if (output.status !== 0) {
        console.error(`${name} failed with exit code ${output.status}`);

        if (output.stderr) console.error(output.stderr.toString());
        else console.log("No stderr");

        process.exit(1);
    }

    return output
}


// Refreshes "focus" colors between previous and current space
// Args: ID of current and previous spaces
function refreshOnly(prev, curr) {
    prev = `yabai_space_${prev}`;
    curr = `yabai_space_${curr}`;

    spawn(
        "sketchybar",
        [
            "--set", prev,
            `label.background.color=0xFF4E4E4E`,
            `label.color=0xFFEBDBB2`,

            "--set", curr,
            `label.background.color=0xFFC8CB36`,
            `label.color=0xFF000000`,
        ],
        `Refreshing ${prev} and ${curr}`
    );
}


// Removes all current yabai spaces from sketchybar. Then creates new spaces
// from current data
function updateSketchybar() {
    let spaces = spawn("yabai", ["-m", "query", "--spaces"], "Yabai query");

    spaces = JSON.parse(spaces.stdout);

    removeSketchybarSpaces();

    // Reorder spaces based on index. Yabai does not guarantee order
    let ordered_spaces = new Array(spaces.length);

    spaces.forEach(s => {
        ordered_spaces[s.index - 1] = {
            id: s.id,
            is_focused: s.focused === 1,
        };
    });

    // Construct sketchybar shell call
    let sketchy_args = new Array();

    ordered_spaces.forEach((s, i) => {
        sketchy_args.push(
            "--add", "space", `yabai_space_${s.id}`, "left",
            "--set", `yabai_space_${s.id}`,
            `label=E${i + 1}`,  // Works best with crashnumberingserif font
            "label.font=crashnumberingserif:Normal:28.0",
            `label.color=0xFF${s.is_focused ? "000000" : "EBDBB2"}`,
            "label.background.height=30",
            "label.background.corner_radius=20",
            `label.background.color=0xFF${s.is_focused ? "C8CB36" : "4E4E4E"}`,
            "label.padding_left=6",
            "label.padding_right=20",
            `click_script=yabai -m space --focus ${i + 1}`
        );
    });

    spawn("sketchybar", sketchy_args, "Sketchybar add all spaces");
}


// Remove all yabai spaces from sketchybar
function removeSketchybarSpaces() {
    let bar = spawn("sketchybar", ["--query", "bar"], "Sketchybar query");

    let tag, sketchy_args = new Array();

    JSON.parse(bar.stdout).items.forEach(item => {
        tag = item.match(/yabai_space_[0-9]+/);

        if (tag) sketchy_args.push("--remove", tag);
    });

    if (sketchy_args.length) spawn("sketchybar", sketchy_args, "Remove all");
}
