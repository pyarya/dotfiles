" Clang ==================================================
iabbrev <buffer> initmodeline // vim: set ft=c ff=unix:

    " Increase indent to match linux guidelines
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4


match Type /\v[ ^]([A-Z][A-Za-z_]+[ $])|([uif]((8)|([1-8]{2})))/

" vim: set ff=unix ft=vim:
