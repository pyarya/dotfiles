" Load init scripts shared with neovim
source ~/.vim/init_scripts/init.vim

" Convenience grepping
nnoremap <leader>gn :execute ":normal! :cnext\r"<CR>
nnoremap <leader>gN :execute ":normal! :cprevious\r"<CR>

" Remap python directory for MacOS
" Change this path if python isn't dynamicallly loading
if system("uname") =~ 'Darwin'
    set pythonthreedll=/usr/local/Frameworks/Python.framework/Python
endif
