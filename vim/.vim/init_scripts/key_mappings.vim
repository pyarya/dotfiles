" ========================================================
" # Keyboard shortcuts
" ========================================================
let mapleader = "\<Space>"

" Ctrl+k as Esc
nnoremap <C-k> <ESC>
inoremap <C-k> <ESC>
vnoremap <C-k> <ESC>
snoremap <C-k> <ESC>
xnoremap <C-k> <ESC>
cnoremap <C-k> <C-c>
onoremap <C-k> <ESC>
lnoremap <C-k> <ESC>
" Works in neovim not in vanilla vim
tnoremap <C-k> <ESC>

" Stop accidentally pulling up manpages
nnoremap <S-k> <NOP>

" Suspend with Ctrl+f
inoremap <C-f> <esc>:sus<CR>
vnoremap <C-f> :sus<CR>
nnoremap <C-f> :sus<CR>

" Navigation =========================================
" Jump to line start/end using homerow
noremap H ^
noremap L $

" Move by lines
nnoremap j gj
nnoremap k gk
nnoremap <C-E> 5<C-E>
nnoremap <C-Y> 5<C-Y>

" Repeat last f/F/t/T motion forward
nnoremap , ;
vnoremap , ;
onoremap , ;

" Case insensitive search
nnoremap <leader>/ /\c

" Jump to grep matches
nnoremap <leader>gn :cnext<CR>
nnoremap <leader>gN :cprev<CR>

" Emacs-like movements
"inoremap <C-f> <right>
"inoremap <C-j> <left>
inoremap <C-h> <BS>
inoremap <C-d> <Del>
inoremap <C-u> <C-w>

    " Jump to end of line
inoremap <C-a> <home>
inoremap <C-e> <end>


" Command prompt =========================================
" ; as : for commands
nnoremap ; :
vnoremap ; :

" Emacs-like movements
    " Move by character
cnoremap <C-f> <right>
cnoremap <C-j> <left>
    " Delete by character
cnoremap <C-d> <del>
cnoremap <C-h> <bs>
    " Move by word
cnoremap <C-b> <C-left>
cnoremap <C-w> <C-right>
    " Delete left word
cnoremap <C-u> <C-w>
    " Jump to end of line
cnoremap <C-a> <home>
cnoremap <C-e> <end>

" Open cmdline history
cnoremap <C-g> <C-f>i

" Open cmdline history from Normal
nnoremap ; :
nnoremap : q:i

" Windows and buffers ====================================
" Move to mark
nnoremap ' `
"nnoremap ` '

" Switch buffers
nnoremap <leader>n :bnext<CR>
nnoremap <leader>N :bprevious<CR>

" Window control with leader
nnoremap <leader>w <C-w>

    " Quick window switching
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

    " Window movement
nnoremap <leader><leader>h <C-w>H
nnoremap <leader><leader>j <C-w>J
nnoremap <leader><leader>k <C-w>K
nnoremap <leader><leader>l <C-w>L

" Window resizing
    " < increases, > decreases
nnoremap <leader>, 10<C-w>>
nnoremap <leader>. 10<C-w><

    " Vertical resizing
nnoremap <leader><leader>, 10<C-w>+
nnoremap <leader><leader>. 10<C-w>-

    " Set interior window width to 80 columns
nnoremap <leader><leader>= :vertical resize 84<CR>

    " Show full file path
nnoremap <C-g> 1<C-g>

    " Change cwd to current buffer's
nnoremap gf :cd %:p:h<CR>

" Editing remaps ========================================
" Uppercase previous word from Insert mode
inoremap <C-y> <ESC>vbU`>a

    " Autocompletion - word and line
inoremap <C-l> <C-n>
"inoremap <C-l> <C-x><C-n>


    " Yank to clipboard
nnoremap Y "+y
vnoremap Y "+y

    " Convenient macro replays
nnoremap @ q
nnoremap q @

" Extended options ======================================
" These use <leader>o as a prefix

    " Enable spellcheck
nnoremap <leader>ospell :set spell!<CR>
command! Spell :set spell!

    " Copy current visual selection to ix.io
vnoremap <silent> <leader>oix :w !ix.sh &<CR>
command! Ix :w !ix.sh &

    " Open first URL on line
nnoremap <silent> <leader>ourl :silent call OpenURL()<CR>
command! Url :silent call OpenURL()

    " Create a pretty block comment. Supports 3 types of comments
command! Prettypy :call PrettySectionComment('#')
command! Prettyhtml :call PrettySectionComment("<!--")
command! Prettyrs :call PrettySectionComment('//')
command! Prettycss :call PrettySectionComment('/*')
nnoremap <leader>opretty :echom "use :Pretty{rs,py,css}"<cr>

    " Open with vifm
nnoremap <leader>onet :EditVifm getcwd()<CR>
nnoremap <leader>otnet :exe 'TabVifm' getcwd()<CR>
