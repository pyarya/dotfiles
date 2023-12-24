" Julia ==================================================
iabbrev <buffer> #! #!/usr/bin/env julia
iabbrev <buffer> initmodeline # vim: set ft=julia ff=unix:

" IPython cell ===========================================
" Enables iPython Cell to copy commands into a julia REPL via tmux
let g:ipython_cell_delimit_cells_by = 'tags'
let g:ipython_cell_tag = ['##', '# %%', '#%%', '# <codecell>']
let g:ipython_cell_highlight_cells = 1

let g:ipython_cell_run_command = 'Base.run(`clear`); include("{filepath}")'
let g:ipython_cell_cell_command = 'include_string(Main, clipboard())'

" REPL hotkeys. Overwrites default slime studio stuff
    " Run entire file from top to bottom
nnoremap <buffer> <leader>f :IPythonCellRun<CR>
    " Run current cell
nnoremap <buffer> <leader>r :IPythonCellExecuteCell<CR>
nnoremap <buffer> <leader>e :IPythonCellExecuteCellJump<CR>
    " Insert block seperator above
nnoremap <buffer> <leader>b O<ESC>S## Block<ESC>vb<C-g>

" vim: set ff=unix ft=vim:
