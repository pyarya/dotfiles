# Executing special keys

Vim's `:exe[cute]` will read special keys when they're escaped in double quotes:

```vim
exe "normal! i\<C-v>u049c\<C-v>u03b1\<C-v>u03c4\<C-v>u212f!\<ESC>"
" Writes Ҝατℯ
```

You can use this to quickly script difficult macros, like the one above

```
:exe "normal! i\<C-v>u049c\<C-v>u03b1\<C-v>u03c4\<C-v>u212f!\<ESC>"<CR>
```

# Effective Unicode in vim

```
Demo unicodes: │┌┴─┐
```

Use `ga` in vim to display encoding information about the character under the
cursor. We'll use the hex value. In insert mode use `<C-v>u` followed by the hex
number to type in Unicode literally. The above can be written with

```
:normal! i<C-v>u2502<C-v>u250c<C-v>u2500<C-v>u2510<ESC>
```
