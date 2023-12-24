    " Compile pdf
nnoremap <buffer> <leader>r :VimtexCompileSS<CR>
nnoremap <buffer> <leader>f :VimtexCompileSS<CR>

    " Fix unreadable highlight for matching environments
highlight MatchParen guibg=#000000
"highlight MatchParen guibg=#ff8700 guifg=#3a3a3a

    " Doesn't work. Fights with Vimtex plugin
hi! clear Conceal
"setlocal conceallevel=2

set textwidth=80

" vim: set ff=unix ft=vim:
