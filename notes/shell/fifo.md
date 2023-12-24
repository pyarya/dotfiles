# Shell pipes and fifo
Most bash "blocks" accept a redirection parameter at the end of their
declaration. This can replace where the output and errors are going

```bash
fn () {
  echo "error" >&3
} 3>&2 2>file
# Prints "error" to the standard error. The real stderr is stored in ./file
```

 - Functions, as above
 - Sub-shells: `(echo "one"; echo "two") > file`
 - Loops: `while (1); do echo "loop"; done > file`

Remember that redirection syntax looks like `[fd][< | >][&fd | file_path]`,
where `fd` is the index in the process' file descriptors. This works for `<` as
well. `|&` is identical to using `2>&1 |`

The order of IO redirection matters. Redirection will go to wherever the
redirected destination currently goes. Redeclaring a redirection doesn't work

```
            ┌3 writes to stdout
            │    ┌stdout writes to stderr
            │    │    ┌stderr writes to where 3 writes, so stdout
            │    │    │
echo "one" 3>&1 1>&2 2>&3
```

To do this for the entire shell or script, use `exec`

```bash
exec 4>&1          # Holds onto reference to stdout
exec 1>/dev/null   # Silences stdout and loses track of it
exec 1>&4 4>&1     # Restore stdout through reference in 4 and close 4
# Everything back to normal
```

`mkfifo` creates a named pipe, which can be easier to interact with between
scripts. Make sure it's being held open at use

```bash
mkfifo fifo
cat fifo >ofif &   # Holds open fifo pipe and copies anything in there to ofif
exec 3>fifo        # fd 3 reffers to pipe fifo
echo "double" >&3  # Writes to fifo. >fifo would close the pipe right after
exec 3>&-          # Manually close the open pipe
```

The example above works similar to `tee` in logging everything in the pipe

