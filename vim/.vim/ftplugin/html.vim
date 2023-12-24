" HTML ===================================================
" By default, vim loads this for markdown files too
if (&filetype !=# "markdown") && (&filetype !=# "javascript")

iabbrev <buffer> #! <!DOCTYPE html>
iabbrev <buffer> initmodeline # vim: set ft=html ff=unix:

    " Indents of 2 instead of default 4
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

endif
" vim: set ft=vim ff=unix:
