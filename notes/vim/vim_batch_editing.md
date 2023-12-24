# Quick help
```bash
for f in *.html; do nvim -Nes "$f" < ex_commands; done
for f in "$(rg -l homu)"; do nvim -Nes "$f" < ex_commands; done

for f in $(fd -tf -e html); do
  nvim -Nes <<'EX'
g/^Stl/exe "norm! cStyle: new\<CR>\<esc>"
$ | a
# ex: ff=unix:
.
wq
EX
done
```

# Batch editing with ex
Ever needed to apply the same edit to several files? Well ex-mode is the only
generalized solution for this

Ex-mode is vim's equivalent of `ed` and `ex` is symlinked as `vim -e` on many
systems. Use the `-N` flag for a more familiar experience. Enter this mode while
in vim with `gQ`. Using the `ex` executable is slightly different from neovim's
implementation, notably neovim doesn't echo back with `nu` and `p`

```bash
ex file
vim -Nes file
```

Ex-mode uses vim's command-mode syntax, which is similar though different from
visual mode

```
:21             Goes to line 21. ^ and $ are for the first and last line
:10,20d         Deletes lines 10 through 20, inclusive on both ends
:u[ndo]         Undoes the last action
:mark a         Makes a mark at a. From vim
:ka             Also makes a mark at a. From ex
:'a             Go to mark a
:g/re/p         Globally exectute a command on lines with /re/
:v/re/p         Inverse of :g. Executes on all lines without /re/
:3,6co$         Copy lines [3,6] to the end of the document
:3m6            Move line 3 to line 6
:z=3            Pretty print lines in [-2,+2]
:norm! @l       Execute keystrokes, if all else fails
```

Several commands can be chained with `|`, similar to `;` in bash

```
:g/bash/exe "normal! cfish\<esc>" | undo | nu
```

Changes every line with "bash" to "fish", undoes that, then prints the line

    :g/string/nu | g/num/nu
Does NOT print all the lines with `string` or `num`. This prints all the lines
with `string` then reprints them if they also have `num`. `:g` only uses a new
line to delimit its commands from the next set!

## Batch editing styles:
 1. Here-string: For only one command, here-strings are a quick and easy choice
```bash
for f in $(find ~/); do nvim -Nes <<<"%s/re/p | wq"; done
```

 2. Here-ansi-c-string: Allows including c-style escape sequences
```bash
for f in $(find ~/); do vim -Nes <<< $'%s/re/nu\nwq'; done
```

 3. Here-documents: The best choice for quick batch edits
```bash
for file in $(fd -at type subs_); do
  nvim -Nes $file <<'DOC'
g/^Stl/exe "norm! cStyle: new\<CR>\<esc>"
$ | a
# ex: ff=unix:
.
wq
DOC
done
```

```bash
for file in ~/.bash*; do vim -Nes $file <<EOF
a
# ex: set syntax=bash:ff=unix:
.
wq
EOF
done
```

 4. Sourced documents: Better for recurring batch edits. Similar to `nvim -S`
```bash
fd -a subs_ -x ex < change_font
fd -a subs_ -x nvim -Nes < change_font

for f in *.html; do nvim -Nes "$f" < ex_commands; done
for f in "$(rg -l homu)"; do nvim -Nes "$f" < ex_commands; done
```

## Best practices
Use `-t file` in `fd`, otherwise `ex` may stop when it hits a directory

Unless you're really confident, always use files to store commands, then first
try them out on copies of files you'd like to edit. It's often hard to debug an
edit in advance and there's no undo

## Batch editing manually
This isn't really a batch edit... though it's worth mentioning

```bash
fd -t file . -X rg --files-with-matches 'ex:' | xargs -o vim
```
