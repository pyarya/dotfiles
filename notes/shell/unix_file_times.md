# Unix file times
Unix files store 3 time stamps: Modified, Accessed, Changed. These can be seen
with `ls -l`. The `stat` command can list these times as well, particularly with
something like `--format='%y'`

`touch` can change times directly. To use the times of another file, provide it
via the `-r` option, then constrain the times you want to change. For example
the `-m` flag will only copy over the modified time
