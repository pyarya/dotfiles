" Julia ==================================================
iabbrev <buffer> #! #!/usr/bin/env julia
iabbrev <buffer> initmodeline # vim: set ft=julia ff=unix:

" Set REPL commands ====
let g:ipython_cell_run_command = 'Base.run(`clear`); include("{filepath}")'
let g:ipython_cell_cell_command = 'include_string(Main, clipboard())'

" vim: set ff=unix ft=vim:
