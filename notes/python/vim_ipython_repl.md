# REPL interaction

Vim can take advantage of read evaluate print loops (REPL) to run code 'cells'.
This is similar to the experience in Jupyter notebooks, Colab, and RStudio

# IPython

This is for the IPython interpreter. The normal python REPL isn't as easy to use

```vim
Plug 'jpalardy/vim-slime'
```

Necessary for any sort of REPL interaction through vim. Lets vim send text to
other terminals or tmux panes

```vim
Plug 'hanschen/vim-ipython-cell'
```

Plugin provides many conveniences for interacting with REPLs, such as one-line
execution, highlighted cell delimiters, and navigation between cells

# Julia

Use the same setup as the IPython REPL, except modify the evaluation string

```vim
let g:ipython_cell_run_command = 'Base.run(`clear`); include("{filepath}")'
let g:ipython_cell_cell_command = 'include_string(Main, clipboard())'
```

Julia equivalents for pasting the clipboard and executing a file
