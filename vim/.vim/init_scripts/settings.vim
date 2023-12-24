set runtimepath^=~/.vim runtimepath+=~/.vim/after
set shell=/bin/bash

" ===================================================================
" File settings
" ===================================================================
set fileformat=unix  " Proper EOL

" Tabs to spaces
set expandtab       " tabs are space
set tabstop=4       " 4 spaces per TAB
set softtabstop=4   " 4 spaces in tab when editing
set shiftwidth=4    " 4 spaces to use for autoindent
set copyindent      " copy indents from the previous line
set autoindent
filetype plugin indent on  " Vim's auto-indenting is broken without this

" Allow buffers to be hidden
set hidden

" Prevent accidental writes
au BufWritePre [:;']* throw 'Forbidden file name: ' . expand('<afile>')

" Embedded code in markdown
let g:markdown_fenced_languages = ['bash', 'rust', 'javascript', 'c', 'toml', 'css', 'sshconfig']

" ===================================================================
" Human-facing settings
" ===================================================================
" Relative line numbering
set number relativenumber

" Line cursor in Insert. Neovim ignores this
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

set hlsearch incsearch  " Live incremental searches

" Shows uncompleted mapping keystokes in the bottom right
set showcmd

" Scroll before hitting top or bottom of window
set scrolloff=2

" Mouse support
set mouse=a  " In all modes
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" Fast bracket matches
set showmatch
set matchtime=0  " Set to 0 for no latency

" More natural window splitting
set splitbelow
set splitright

set colorcolumn=80  " 80 character column marker

" Highlight active line except in Insert
au InsertEnter,InsertLeave * set cul!
set cursorline

" Wrap h l movements across lines
set whichwrap+=>,l
set whichwrap+=<,h

set backspace=eol,start,indent  " Movement of deletion keys

" Wider spaced Menlo font with Nerd Font glyphs
set guifont=MesloLGM\ Nerd\ Font:h16

" Mark trailing whitespace with • ====
set list  " Toggle with :set invlist
set listchars=tab:•\ ,trail:•,extends:•,precedes:•,nbsp:␣

    " Hide whitespace markers in Insert
augroup trailing_whitespace
    au!
    au InsertEnter * set nolist
    au InsertLeave * set list
augroup END

" Fold .vim files on triple '{' marks
augroup vimrc_folds
    au Filetype vim setlocal foldmethod=marker
    au Filetype vim,BufReadPre setlocal foldlevelstart=0
augroup END


" ===================================================================
" Syntax colors
" ===================================================================
" Use base16 colors:
"   https://github.com/chriskempson/base16-vim
"   Previews: https://base16.netlify.app/

syntax on
set termguicolors    " Actual colors
set background=dark  " Colorscheme overrides this option
let base16colorspace=256

if !has('gui_running')
    set t_Co=256
endif

" Brighten comment highlight, when switching color schemes
function! FixHighlights()
    hi! link IPythonCell Todo
    call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")
endfunction

command! FH :call FixHighlights()

" Color schemes ====
    " Switch to common themes quickly
command! Light :colo base16-gruvbox-light-medium | FH
command! Lighth  :colo base16-gruvbox-light-hard | FH
command! Darkb  :colo base16-gruvbox-dark-bright | FH
command! Dark     :colo base16-gruvbox-dark-pale | FH
command! Darkh  :colo base16-gruvbox-dark-medium | FH

" 1: Foreground = medium, Background = very dark   -- Blackboard-like
" 2: Foreground = high,   Background = low
" 3: Foreground = medium, Background = medium      -- purple-ish
" 4: Foreground = medium-high, Background = medium -- Nord blue
command! Dark1  :colo base16-dracula   | FH
command! Dark2  :colo base16-monokai | FH
command! Dark3  :colo base16-material-palenight | FH
command! Dark4  :colo base16-nord | FH

" 1: Foreground = dark,    Background = very bright   -- Paper like
" 2: Foreground = dark,    Background = maximum white -- Paper like
" 3: Foreground = dark,    Background = low bright    -- Low contrast
" 4: Foreground = dark,    Background = low bright    -- Low contrast
command! Light1  :colo base16-github   | FH
command! Light2  :colo base16-tomorrow   | FH
command! Light3  :colo base16-atelier-estuary-light | FH
command! Light4  :colo base16-atelier-plateau-light | FH

" Switch theme to match terminal  ====
if !has('termguicolors') || system("ps -e | awk '$4 ~ /Xorg|alacritty|sway/ {has_gui = 1} END {printf \"%d\", has_gui + 0}'") == "0"
    colo default
elseif executable('colo.sh')
    exec 'colo ' . system('colo.sh --colorscheme')
    call FixHighlights()
elseif executable(expand('~/.configs_pointer/bin/colo.sh'))
    exec 'colo ' . system('~/.configs_pointer/bin/colo.sh --colorscheme')
    call FixHighlights()
else
    echom "Using fallback color scheme"
    Dark
    call FixHighlights()
endif
