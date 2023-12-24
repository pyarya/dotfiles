" Python =================================================
iabbrev <buffer> #! #!/usr/bin/env python3
iabbrev <buffer> initmodeline # ex: set ft=python ff=unix:

    " Bug fix for python interpreter seeing #!.../python3^M
set fileformat=unix

    " Indent guides for python
IndentLinesEnable

" Linting ====
setlocal makeprg=pylint\ --reports=n\ --output-format=parseable\ %:p
setlocal errorformat=%f:%l:\ %m

" Set REPL commands ====
"highlight IPythonCell guifg='#85AD85' guibg='#85AD85'
"hi IPythonCell cterm=bold gui=bold guibg=#222222 guifg=#85ad85
"hi IPythonCell guifg=#222222 guibg=#dab997
"hi! link IPythonCell Comment

    " Fix for extended syntax plugin
highlight Error NONE

    " Python: function and class names
onoremap ih :execute ":normal! ?def [A-z]\\+(\\\|class [A-z]*\\(:\\\|(\\)\r:noh\rwve"<CR>

" IPython cell ===========================================
    " For true REPL-supporting languages
let g:ipython_cell_delimit_cells_by = 'tags'
let g:ipython_cell_tag = ['##', '# %%', '#%%', '# <codecell>']
let g:ipython_cell_highlight_cells = 1

    " Use Makefile for REPL-like experience for most languages
let g:ipython_cell_cell_command = '%paste -q'
let g:ipython_cell_run_command = '%run {options} "{filepath}"'


hi! link IPythonCell Todo

" Command hotkeys
    " Connect to running Jupyter kernel
nnoremap <leader>q :JupyterConnect<CR>
    " Run entire file from top to bottom
nnoremap <leader>f :JupyterRunFile<CR>
    " Run current cell
nnoremap <leader>r :JupyterSendCell<CR>
nnoremap <leader>e :JupyterSendCell<CR>
    " Insert block seperator above
nnoremap <leader>b O<ESC>S## Block<ESC>vb<C-g>

" vim: set ff=unix ft=vim:
