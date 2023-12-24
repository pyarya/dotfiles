# Vifm: Moving files

There are a few ways to move files in vifm, all of which hinge on using a
selection paired with some sort of command

### Selections

These selections and filters get cleared once you change directories

 1. Not selecting anything implicitly selects anything under your cursor
 2. `za` toggles dotfile visibility
 3. `t` adds a single file to the selection from the directory
 4. `V` visual mode selects files in a range
 5. `=` quick filter that is case-sensitive

These filters are permanent, in that they're retained between directory
switches and apply to all directories

 1. `zf` adds the current selection to the permanent filter
 2. `:filter <regex>` hides all matching files in all directories
 3. `:filter! <regex>` inverse of above filter, only shows these files

These are then controlled with

 - `zO` Unset the permanent filter
 - `zR` Stash the permanent filter
 - `zM` Pop the stashed permanent filters

These are best paired with visual mode to quickly select a bunch of files

### Moving files

A simple `:m` will move all selected files to the location in the other pane.
Using `:sync %d` can set the opposing pane to the current one

Alternatively you can yank into a register, say `"ay`, then move all files in
the register to your current location with `:put a`

Also, don't forget there are other tools that can be better for the job. For
example batch renaming should be done through `mmv`

```
:!mmv './*_EP*.srt' './Documents/subtitles/kaguya_S1_#1.srt'
```

Bash for-loops paired with `fd` or `rg -l` can be used for fine-tuning too
