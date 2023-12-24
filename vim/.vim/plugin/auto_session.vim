" Always use sessions on entry and exit:
"
" Examples:
"   Assuming [[ $(pwd) == ~/.vim/colors ]]
"   Actions vary based on if command line arguments were passed.
"
"   Plugin doesn't load for:
"    - When vim is entered in exmode
"    - When vim is entered as a GUI
"
"   $ vim
"   Called with no args:
"   // On entry:
"   //   Source ~/.vim/colors/Session.vim if available
"   // On exit:
"   //   If only one window and tab is open, DELETE the Session.vim file
"   //   If multiple windows and/or tabs are open, OVERWRITE Session.vim
"
"   $ vim ~/.vimrc
"   Called with args:
"   // On entry:
"   //   Doesn't source any Session.vim
"   // On exit:
"   //   If only one window and tab is open, DOES NOT DELETE Session.vim
"   //   If multiple windows and/or tabs are open, OVERWRITE Session.vim
"
"   $ ex
"   $ vim -e
"   // Won't run this plugin
"
" https://stackoverflow.com/questions/5142099/how-to-auto-save-vim-session-on-quit-and-auto-reload-on-start-including-split-wi

" Save argc before Session.vim overwrites it
let s:init_argc_len = argc()

fu! SaveSess()
    " Don't delete or source Session.vim when explicit files were called.
    " Still overwrites old Session.vim if multiple windows are open on exit
    if (tabpagenr('$') == 1) && (winnr('$') == 1) && (s:init_argc_len == 0)
        execute 'silent! call delete("' . getcwd() . '/Session.vim")'
    elseif (tabpagenr('$') > 1) || (winnr('$') > 1)
        execute 'mksession! ' . getcwd() . '/Session.vim'
    endif
endfunction

fu! RestoreSess()
    if filereadable(getcwd() . '/Session.vim')
        execute 'source ' . getcwd() . '/Session.vim'
    endif
endfunction


" Don't run plugin if vim started in ex-mode or gui
let s:is_no_run = (mode() =~# '^c') || has("gui_running")

if !s:is_no_run
    " Only restore sessions without explict files being opened
    if s:init_argc_len == 0
        autocmd VimEnter * nested call RestoreSess()
    endif
    autocmd VimLeave * call SaveSess()
endif


" Testing from within vim
fu! Testsavesess()
    if s:is_no_run
        echom 'Exmode or GUI detected: this plugin won''t effect any Session.vim files'
    elseif (tabpagenr('$') == 1) && (winnr('$') == 1) && (s:init_argc_len == 0)
        echom 'Deletes ' . getcwd() . '/Session.vim on exit'
    elseif (tabpagenr('$') > 1) || (winnr('$') > 1)
        echom 'Overwrites ' . getcwd() . '/Session.vim on exit'
    else
        echom 'Won''t touch anything'
    endif
endfunction
