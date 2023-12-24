" Rust ===================================================
iabbrev <buffer> initmodeline // vim: set ft=rust ff=unix:

    " Rust's longer line standard
setlocal colorcolumn=100

    " Folds open by default
let g:rust_fold = 1

    " Jump to naming of rust fn, struct, and enum names
onoremap ih :execute ":normal! ?fn [a-z]\\+\\\|\\(struct\\\|enum\\) [A-Z]\r:noh\rwve"<CR>

    " Set interior window width to 100 columns
nnoremap <leader><leader>= :vertical resize 104<CR>

" vim: set ff=unix ft=vim:
