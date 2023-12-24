// Copy the current subtitles to the clipboard
//
// You may select the copied subtitles with `qwer` by default or just
// `<TAB><TAB>` to copy all of them
//
// Make sure to edit g.afterCopyAction[Mac|Linux] below. This command will be
// run by bash after the subtitles are copied to clipboard. For example to
// search them up in an online dictionary


// Rebind keys here
var key_binds = {
    // Keys to move selection. Letters mean `move<Left/Right><Plus/Minus>`.
    // moveLP increases the selection size by 1 character to the left
    moveLP: "q",
    moveLM: "w",
    moveRM: "e",
    moveRP: "r",

    // Start and stop copying
    copyKey: "TAB",
};


// Global
var g = {
    osd: mp.create_osd_overlay("ass-events"),
    has_moved_selection: false,
    sub_chars: undefined,
    sub_len: function () { return this.sub_chars.length },
    start: 0,
    end: 0,

    // Shell script to run after copying. Both examples below assume chrome
    // with a dictionary is open on workspace 3 and the "seach box focus"
    // Chrome extension is installed
    // MacOS version ======
    // Uses skhd, not preinstalled
    afterCopyActionMac: "/usr/bin/env -S bash -c '"
           + 'skhd -k "cmd + shift - a"'  // Move to left desktop
           + ' && sleep .6'
           + ' && skhd -k "ctrl - l"'     // Focus search bar
           + ' && sleep .1'
           + ' && skhd -k "cmd - a"'  // Select entire search bar
           + ' && skhd -k "cmd - v"'  // Paste clipboard
           + ' && skhd -k "return"'   // Search
           + "'",
    // Linux version ======
    // Uses wtype, intended for swayland
    afterCopyActionLinux: "/usr/bin/env -S bash -c '"
           + 'wtype -M logo -k 3'      // Move to workspace 3
           + ' && sleep .2'
           + ' && wtype -M alt  -k l'  // Focus jisho.org searchbar
           + ' && sleep .2'
           + ' && wtype -M ctrl -k v'  // Paste
           + ' && wtype -k return'     // Search
           + "'",
};


mp.add_key_binding(key_binds.copyKey, "startCopySubs", main);


function main() {
    if (!initSelection()) {
        mp.osd_message('No subtitles found', 1);
    }

    mp.add_forced_key_binding(key_binds.moveLP, "moveLP", function () { moveSelection(true, 'left') });
    mp.add_forced_key_binding(key_binds.moveLM, "moveLM", function () { moveSelection(false, 'left') });
    mp.add_forced_key_binding(key_binds.moveRM, "moveRM", function () { moveSelection(false, 'right') });
    mp.add_forced_key_binding(key_binds.moveRP, "moveRP", function () { moveSelection(true, 'right') });

    mp.add_forced_key_binding(key_binds.copyKey, "copySubs", function () {
        copySelection();
        mp.add_forced_key_binding(key_binds.copyKey, "startCopySubs", main);
    });

    g.has_moved_selection = false;
}


// Create a new selection printing on OSD
// Returns true when a new selection has been created
function initSelection() {
    g.sub_chars = [];
    var chars = mp.get_property('sub-text')
                  .replace('\n', '\\N')
                  .replace(/\u202A/g, '')   // Left to right embed
                  .replace(/\u202C/g, '')   // Right to left embed
                  .split('');

    if (chars.length === 0) return false;

    // Combine \N with previous character
    for (var i = 0; i < chars.length; i++) {
        if (chars[i+1] + chars[i+2] === '\\N')
            g.sub_chars.push(chars[i] + chars[++i] + chars[++i])
        else
            g.sub_chars.push(chars[i]);
    }

    // Select middle half of subs, the [1/4, 3/4] range
    g.start = Math.floor(g.sub_len() / 4);
    g.end   = Math.floor(g.sub_len() * 3 / 4);

    renderSelection();
    return true
}


// Write updated selection to osd
function renderSelection() {
    var ass_str = "";

    // Color selected characters in gruvbox yellow
    for (var i = 0; i < g.sub_len(); i++) {
        if (i === g.start) ass_str += "{\\c&H1476B7&}";
        ass_str += g.sub_chars[i];
        if (i === g.end)   ass_str += "{\\c&HFFFFFF&}";
    }

    g.osd.data = "{\\an2}" + ass_str;
    g.osd.update();
}


// Increase or decrease the selection. At least one character must be selected
function moveSelection(is_additive, side) {
    if (is_additive && side === 'left')
        g.start -= (g.start !== 0);
    else if (side === 'left')
        g.start += (g.start < g.end);
    else if (is_additive)
        g.end += (g.end !== g.sub_len());
    else
        g.end -= g.start < g.end;

    g.has_moved_selection = true;
    renderSelection();
}


// Remove selection from OSD and reset it to as before
function clearSelection() {
    for (var bind in key_binds)
        mp.remove_key_binding(key_binds[bind]);
    g.osd.remove();
    g.sub_chars = [];
}


// Copy the current selection to the clipboard
function copySelection() {
    var selected = g.sub_chars.join('').replace(/\\N/g, '');  // Removes linebreaks

    if (g.has_moved_selection) {
        selected = selected.slice(g.start, g.end + 1);
    }
    clearSelection();

    kernel_name = mp.command_native({
        name: "subprocess",
        capture_stdout: true,
        args: ["uname", "-s"],
    }).stdout;

    if (kernel_name.match("Darwin")) {
        mp.command("run bash -c \"echo '" + selected +  "' | pbcopy\"");
        mp.osd_message('Copied to clipboard', 1);

        if (g.afterCopyActionMac)
            mp.command("run " + g.afterCopyActionMac);
    } else if (kernel_name.match("Linux")) {
        mp.command("run bash -c \"echo '" + selected +  "' | wl-copy\"");
        mp.osd_message('Copied to clipboard', 1);

        if (g.afterCopyActionLinux)
            mp.command("run " + g.afterCopyActionLinux);
    } else {
        mp.msg.log("error", "Unrecognized kernel name: '" + kernel_name + "'");
    }
}


// Depreciated
function copySubs() {
    var subs = mp.get_property('sub-text').replace(/\u202a/g, '');

    mp.command("run bash -c \"echo '" + subs +  "' | pbcopy\"");

    mp.osd_message('Copied to clipboard', 1);

    //var is_windows = mp.get_property_native('options/vo-mmcss-profile', o).match(/o/);
    //var is_mac     = mp.get_property_native('options/cocoa-force-dedicated-gpu', o).match(/o/);

    //mp.msg.info(is_windows ? "Is windows" : "Not windows?");
    //mp.msg.info(is_mac ? "Is mac" : "Not a mac?");

    //if (is_windows) {
    //    mp.osd_message('Windows is not supported at this time\nClipboard unchanged', 4);
    //    return
    //} else if (is_mac) {
    //    mp.command("run /usr/bin/env -S bash -c 'echo \"" + subs + "\" | pbcopy'");
    //} else {
    //    mp.command("run /usr/bin/env -S bash -c 'echo \"" + subs + "\" | xclip'");
    //}
}

