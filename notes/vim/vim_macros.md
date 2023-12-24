# Vim Power Macros

### Recording

When recording macros, best practice is to start with a `0` motion and try to
use absolute motions to the line like `A` not `w`

Macros are a register, so they can be edited the same way as one. In fact `@` is
just a shortcut for `:normal <paste-register-here>`. They can be viewed with
`:reg`

Modifying macros:
 - `"lp` paste register `l`
 - `<C-v><C-k>` literally inserts `<C-k>` as a key motion. Useful for pseudo-esc

Saving macros:
 - `"lyy` copy line into register `l`
 - `:'<,'>y l` copy selected line into register `l`
 - `{Visual}"ly` copy selection into register `l`. Doesn't have `<C-j>` at the end

On the line:
 - `<C-r>l` pastes the `l` register in insert mode
 - `:let @l = "<rec>"` sets the `l` register as `<rec>`
 - `:let @L = "<rec>"` appends `<rec>` to register `l`
 - `"i\<esc>"` in a string escapes to literal key strokes, like `<C-v>` inserts

Escaping keystrokes, from the last example, only works with double quoted
strings. You can check in `:reg` to see the literal expansion

### Replaying macros
The older convention for batch macros was adding `j` at the end of the macro,
and using absolute motions:
 - `4@l` replay the macro 4 times

A newer solution is to execute registers over command line through `:normal`.
Macros executed this way always starts in the left-most column, so prepend `0`
to your macro for consistency

Command style:
 - `:norm[al][!] @l` can be used to replay macros. Keep the `!` to not use maps
 - `:'<,'>norm! @l` replays the macro over every select line
 - `:g/re/norm! @l` replays the macro over lines with a matching regex

Oddly, while `:norm! @l` doesn't see maps for `@l`, it will see mapping in the
register internally. So

```
:nnoremap <C-k> <esc>
:let @l = "Ihello\<C-k>"
:norm! @l
```

will still read `<C-k>` as `<esc>` when executing
