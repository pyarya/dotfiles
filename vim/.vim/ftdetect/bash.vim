augroup checkBash
    au!
    au BufRead,BufNewFile * if len(match(getline(1), '\v#![a-z/]* ?bash')) == 1 | set filetype=bash | endif
augroup END
