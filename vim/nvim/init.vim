" Sync vim configs to neovim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vim/init_scripts/init.vim

" Astolfo-inspired welcome prompt
echom "UwU"

" Open nvim/init.vim for quick editing
command! Nim :normal! :vsplit $MYVIMRC<CR><C-w>H
command! Nims :normal! :w<CR>:source $MYVIMRC<CR>:x<CR>

" Reset cursor to vertical bar when leaving
"au VimLeave * set guicursor=a:ver0-blinkon0
"au VimLeave * call nvim_cursor_set_shape("vertical-bar")

set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
set inccommand=nosplit

if !has('python3')
    echom 'Warning: No python 3 support. UltiSnips won''t be available'
    echom 'Run: $ python3 -m pip install --user --upgrade pynvim'
endif
