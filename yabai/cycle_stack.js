#!/usr/bin/env node
// Find the top windows of each stack in the current space. Returns the window
// id of the next window at the top of a stack. If only one stack is present,
// that stack will be returned
//
// The interpretation of "next" here is in terms of window id order, not
// anything to do with the layout
//
// This script must be used in a pipe, for example:
// yabai -m query --windows --space | cycle_stack.js
process.stdin.on('data', function(data) {
    let windows = JSON.parse(data.toString());

    let stacks_top = {};
    let ordered_ids = [];
    let focused;

    // Find all the windows at the top of a stack
    for (win of windows) {
        let key1 = [win.frame.x, win.frame.y].toString();  // Top left corner
        let key2 =  // Bottom right corner
            [win.frame.x + win.frame.w, win.frame.y + win.frame.h].toString();

        let win_obj = { id: win.id, app: win.app };
        ordered_ids.push(win.id);

        if (!(key1 in stacks_top || key2 in stacks_top) && win.visible) {
            stacks_top[key1] = stacks_top[key2] = win_obj;
        }

        if (win.focused == 1)
            focused = win.id;
    }

    let ids = [];

    for (const top of Object.values(stacks_top))
        if (!ids.includes(top.id))
            ids.push(top.id);

    ids.sort();  // By window id

    let next_stack = ids.indexOf(focused) + 1;

    if (next_stack == ids.length)
        process.stdout.write(ids[0].toString());
    else
        process.stdout.write(ids[next_stack].toString());
});
