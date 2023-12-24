# Bash
###### Process priority
Since the processor must decide priority, it uses a scale from -20 through 20 to
rank what has priority, with -20 being the highest priority. By default,
processes launched by the user start with a niceness of 0

    # nice --10 ./start_qemu.sh
    # nice -n -10 ./start_qemu.sh
Starts the process, in this case `start_qemu.sh`, with a given niceness level,
in this case `-10`. The `-n` option increments from the base value, usually 0

    # renice -2 1244
    # renice -n -2 1244
Changes the niceness of a running process via process id, in this case 1244.
`-n` increments niceness from the current value, in this case by `-2`

    $ ps -fl -C 1244
Check the niceness of process with id 1244

###### Job Control in Bash
You should not use jobs if you can help it! Especially when it comes to
input/output jobs are terribly unclear. Only use them for tasks that will never
ask for input or give an output. Use a multiplexer (`tmux`) instead

    $ python -m SimpleHTTPServer 3000 &
Starts a process, in this case the python server, in the background. Just append
a `&` at the end

*Oh no, I didn't launch the process in the background*
    ^z
If you want to move suspend the current process, `^z` will suspend and stop it

    $ bg %2
    $ bg 2
    $ %2 &
Continues the stopped job in the background. In this case, we use job identifier
1, which will start that specific job. You can omit the `%` with `bg`

    $ fg %2
Bring a job back to the foreground. Uses identifiers much like `bg`

    $ jobs -l
List all background jobs running. `-l` shows their process id

    $ kill %2
Kills a background job, via identifiers. The `%` is not optional here!

    $ wait %2
Waits for job identifier `2` to finish. Passing no arguments waits for all
background jobs

    $ wlsunset -t 4000 -T 65000 -g 0.9 &
    $ disown %1
Launches `wlsunset` in the background. Then, assuming it's job 1 under `jobs`,
disowns the process. The shell can now close with the process still running

    $ wlsunset -t 4000 -T 65000 -g 0.9 & disown
Same as above. More compact

    $ { wlsunset -t 4000 -T 65000 -g 0.9 & } &
    $ ( wlsunset -t 4000 -T 65000 -g 0.9 & ) &
Same as above, background and disowns the subshell. `{}` execute the subshell in
the current shell's context, while `()` start a fresh shell. `{}` are also used
in brace expansion, so they need to be delimited by spaces


###### Vim editing for Bash
    $ set -o vi
Makes bash use vi key binds. Note, this uses `vi` not `vim` bindings. Generally
this isn't recommended, even for complete vim users

    $ export EDITOR='vim'
Bash will run the specified command when looking for an editor

    <C-x><C-r>
Open current shell line in editor. Really powerful for long lines

See the (Ex section)[#Batch-editing-with-ex] for batch editing with vim
in `ex` mode

###### Stop yourself from deleting files
    $ chmod a-w safe_directory
Prevents writing to the directory. Writing, in the sense of editing files is
still controlled by file permissions, you just can't remove or make new ones

    # chown other_user safe_directory; chmod 755 safe_directory
Makes another user own the directory. All others uses cannot make/remove files.
Same as above, if ownership is given to root, though a bit more explicit

    # touch safe_directory/file
    # rm safe_directory/file
You can still create and delete files in this directory with root

###### Reusing commands
See HISTORY EXPANSION in `man bash` for more information

    $ sudo !!
    $ sudo !-1
Recalls the last command and runs it as root. Notice the `-1` can be any number
to recall older commands

    $ !man
Rerun the last command starting with the string `man`

    $ !?diff?:p
Print the last command that contained the string `diff`

    $ mv !:2 ../!:2
Substitutes `!:2` with the second argument of the previous command. The command
itself is `!:0`, so it's the second argument. Here it moves a directory up

    $ mv !^ !^'_name'
    $ mv !$ !$'_name'
`$` and `^` are aliases for the first and last arguments. Here it changes a file
or directory name by adding `_name` at the end

    $ vim -p !touch:*
    $ vim -p !touch:2-4
    $ vim -p !:2*
Expands argument ranges from the last `touch` command. `*`, `1-*` and `1*` are
synonymous. If no string is specified, like `!:*`, the last command is used

    $ vim -o !touch:1*
Open a new window for every argument in the most recent command starting with
`touch`

    $ ^touch^vim -o^
    $ !!:s/touch/vim -o
    $ !!:&
Replay the last command replacing the first instance of `touch` with `vim -o`.
The third line replaces `&` with the last substitution

    $ vim -o !touch:*:gs/html/md
Recall all the arguments of the last `touch` command. Replace all instances of
`html` with `md` then pass those to `vim -o`

    $ cat !!:$:s/machine/human
Substitute in the last argument from the previous command with `human`

    <C-r>
    <C-s>
Search backward or forward for input string. Use multiple times to scroll

    awk '{a[NR] = $0} END { for (i = NR; i > 0; i--) print a[i] }' # rev lines
    <C-r># rev lines
Replays the tagged command. Use trailing comments to act as a tag

    diff ~/Downloads/{before,after}.txt
Checks if `before.txt` and `after.txt` are different. Braces are duplicated

    $ !if:gs/$c/$a
Replace all the variables $c with $a in the previous command starting with if

So the general structure of recall is
```
!<cmd-identifier>[:<arg-range>][:<operator>]
```

###### Automated interactive input
    $ yes | rm -ir /deep_dir
Bypasses interactive y/N prompt given by the `rm` command for every thing in that
directory. `yes` prints an infinite number of 'y\n' to any program

    $ printf 'y\nn\ny\n' | rm -ir /small_dir
Will remove the first and third file automatically, then ask you for further
input

    $ rm -ir /deep_dir < pre_made_input.txt
Enters the file contexts to the interactive prompt. Line breaks are like '\n'.
Very helpful if you're using this order of input over and over

###### Bash scripting
Bash is an awful scripting language in every sense except portability. Always
install and use `shellcheck` after writing a script

    bash_script.sh
    #!/bin/bash
    #!/usr/bin/env bash
    #!/usr/bin/env -S awk -f ${SOMEFILE}
Use shebang at the top to declare an interpreter. Using `env` is considered more
portable, though the `-S` option is required for anything longer than one word

    $ echo ${myvar:-not here}
    $ echo ${myvar:-"not here"}
Expands to `$myvar` if it's set, otherwise expands to string "not here"

    $ for i in $(seq 0 9); do python -c "print(ord('$1'))" & done
Asynchronously print the ASCII codes for range `[0, 9]`

###### Other Bash uses

    $ compgen -c git
See the possible completion for the given word. This is what tab uses

    $ time bash -c "make && ./a.out; rm ./a.out"
Times multiple separate bash commands

## Ed for terminal file editing
Ed is the original text editor for Unix systems, which still is useful for batch
editing scripts. Ranges are very similar to vim's

    $ ed -p '> :' file1
Open `file1` with ed. Useful for writing a script

    :n      Print the current line enumerated
    :100    Moves to line 100 and prints it
    :ka     Set a mark `a`
    :'a     Move to mark `a`
    :i      Open line above current line in insert mode. Like vim's `o`
    :a      Open line below current line in insert mode. Like vim's `O`
    .       Exit insert mode. Should be the only character on the line
Various basic commands. Most commands accept ranges, like vim's. Unlike vim, all
commands operate on entire lines at once

    :g/Style/p\
    a\
    Style line is above ^^^^\
    .\
    n
For all lines matching the regex, run the command sequence. `\` separate lines

See vim_batch_editing.md for practical application of this

## Awk the programming language
AWK is an old, though surprisingly useable stream-editing language. It's a POSIX
compliant tool to bundle `grep`, `sed`, `printf`, `cut`, `xargs`, and more all
into one scripting language. Most its use comes in bash scripts or one-liners to
quickly extract information from a text stream. The man pages are really good!

Much of the standard control flow is the same as C. Variables don't need to be
initialized before use, ex: `i+=1`. Many functions will perform on `$0` if no
argument is given

    #!/usr/bin/env -S awk -f
    #!/usr/bin/env -S awk -F: -f
Use the string option on `env` to be able to specify the necessary `-f` option


    substr(str, start_pos, chars_cut)   // Cut out part of a string
    length([str])               // Length of str, or $0 if no argument is given
    index(str, search_str)      // Find starting index of match in str
    match(str, /reg/)           // Return index. Set RSTART and RLENGTH
    split(str, array, fs)       // Split str into array elements on FieldSeperator
    sub(/reg/, new_str, str)    // Subs new_str for first /reg/ match in str
    sub("match", new_str, str)  // Subs new_str for first string "match" in str
    gsub(/reg/, new_str, str)   // Above just global
The core awk functions with odd argument order

    printf, sprintf, system, tolower, toupper, exp, log...
Core awk functions without odd argument order

### Built in variables
    NR  Current line's number. Literally "number of reads". Starts at 1
    NF  Number of fields in this line. `$NR` expands to the last field's value
    RSTART  Field number of last `match()`
    RLENGTH  How many characters long the last `match()` was
    $0  The entire line of text
    $1  Where `1` is the `1th` field in the line

### Regular expression
Regular expressions are supported. They're a separate type from strings. Unlike
most modern regex interpreters, escape sequences such as `\s` and `\d` aren't
supported. Instead use POSIX compliant versions `[:space:]` and `[:digit:]`

Inverting a regex is done by defining a `!` in front. For example
    $0 !~ /hello/
    $0 ~ !/hello/
    $0 ~ /[^(hello)]/

If you want to store a regex in a variable for later use, DO NOT store an actual
regex type. Store the regex as a string instead, effectively replacing the
encapsulating `/` with `"`

    my_regex = "hello[:space:]+you"
    $0 ~ my_regex
Notably, using a regex instead of a string in this situation results in odd
silent errors that mostly work. These can be hard to debug, so watch out

### Recipes
    $ cat file.txt | awk 'tolower($0) ~ /word/ { print $0 }'
    $ cat file.txt | awk 'tolower($0) ~ /word/'
    $ cat file.txt | grep -i 'word'
Searches through given piped text for 'word' in any casing

    $ cat file.txt | awk -F ',' '
            { commas += NF - 1 }
        END { print "Commas counted:", commas }'
Counts the number of commas in a file.

    $ awk -F '\t' '{ print $0 }' demo.txt
    $ awk -F '\t' demo.txt
Uses tabs are a files separator between "lines"

    $ current_window_id=$(chrome-cli list windows | awk -F ' ' \
            'NR == 1 { gsub(/[\[\]]/, "", $1); print $1 }')
Parses the window id from `[999] Some Title` to `999`

    $ ls -la | awk 'match($NF, /[0-9]+/) { print substr($NF, RSTART, RLENGTH) }' >
    coffees.nh
Checks if the last argument is a string of consecutive numbers. Notice how `$NF`
uses that `NF` is the last number to index the last field like `$3`

### Advanced examples
    END {
        arr["hello"] = 2; arr["other"]++; arr["some"] += 10;

        printf "Hello: %d, Other: %d, Some: %d, None: %d\n",
            arr["hello"], arr["other"], arr["some"], arr["none"];
    }
    >>> Output: Hello: 2, Other: 1, Some: 10, None: 0
Arrays can be indexed by strings! This allows for counting words or lines

    $ awk '!($0 in uniq) { uniq[$0]; print }' duplicates.txt > uniques.txt
Removes duplicate lines. This uses the relational operator `(expr, expr... arr)`
to check if an element with the string's index has been initialized in the array

    $ awk '!unique[$0]++' duplicates.txt > uniques.txt
Removes duplicate lines. This exploits awk's automatic initialization of
variables with falsey values, 0 here, then turns that index truthy with `++`


<!-- ex: set ft=markdown tw=80: -->
