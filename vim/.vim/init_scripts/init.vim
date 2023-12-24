" Source startup scripts
source ~/.vim/init_scripts/key_mappings.vim

source ~/.vim/init_scripts/settings.vim

source ~/.vim/init_scripts/external_plugins.vim

" Extra ===========================================
let $BASH_ENV = '~/.bash_aliases'

" From Jonhoo, sets ripgrep as grep
if executable('rg')
    set grepprg=$FZF_DEFAULT_COMMAND
    set grepformat=%f:%l:%c:%m
endif

" Quickly take a note
command! Note :split ~/.vim/vim_notepad.md
