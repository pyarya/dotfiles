" Fix highlights when switching color schemes
function! FixHighlights()
    hi! link IPythonCell Todo
    call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")
endfunction
