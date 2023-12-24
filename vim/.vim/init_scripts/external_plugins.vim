" ========================================================
" External plugins
" ========================================================

" Disable syntax-breaking from polyglot
let g:polyglot_disabled = ['markdown', 'sh']

" Download vimplug, if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin('~/.vim/plugged')

" General vim improvements ==========================================
" Vim basics ====
    " fuzzy searching buffers/files
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
    " Disables hlsearch after search is done
Plug 'romainl/vim-cool'
    " File system bindings
Plug 'tpope/vim-eunuch'
    " Movement extension
"Plug 'justinmk/vim-sneak'
"Plug 'easymotion/vim-easymotion'

" Vim windows ====
    " Tmux-like zoom for windows
Plug 'dhruvasagar/vim-zoom'
    " Focus window
Plug 'junegunn/goyo.vim'
    " Quickfix markings
Plug 'https://gitlab.com/hauleth/qfx.vim'
    " Vim file manager binds
Plug 'vifm/vifm.vim'

" Git ====
    " Starts vim in root git directory
Plug 'airblade/vim-rooter'
    " Git diff in the left column
Plug 'airblade/vim-gitgutter'
    " Git command integration
"Plug 'tpope/vim-fugitive'

" Browser ====
"Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
"Plug 'subnut/nvim-ghost.nvim', {'do': ':call nvim_ghost#installer#install()'}
"Plug 'soywod/himalaya', {'rtp': 'vim'}

" REPL interaction ====
    " Interact with REPL through tmux
Plug 'jpalardy/vim-slime'
    " Cleaner REPL interactions
Plug 'hanschen/vim-ipython-cell'
    " Jupyter notebooks intergration
Plug 'jupyter-vim/jupyter-vim'
    " Live-editing notebooks in vim
Plug 'untitled-ai/jupyter_ascending.vim'

" Language specific =================================================
" Syntax support ====
Plug 'rust-lang/rust.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Plug 'arzg/vim-rust-syntax-ext'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'catppuccin/nvim', {'as': 'catppuccin'}
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'RRethy/nvim-base16'
Plug 'waycrate/swhkd-vim'

" Python ====
    " Shows line indent guides
Plug 'Yggdroot/indentLine'
    " More highlights
"Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }
Plug 'sheerun/vim-polyglot'
"Plug 'hdima/python-syntax'

" Latex ====
    " LaTeX support
Plug 'lervag/vimtex'
    " LaTex snippets. Requires python
Plug 'SirVer/ultisnips', { 'tag': '*3.2' }

call plug#end()

" Quickfix markings with window
nnoremap <leader>oo :cw<bar>QFxPlace<CR>
nnoremap <leader>oc :ccl<bar>QFxClear<CR>

" No prompt when vim-rooter causes a directory change
let g:rooter_silent_chdir = 1
let g:rooter_manual_only = 1

" Disables by default. See language specific section for when it's enabled
let g:indentLine_enabled = 0

" Use scss with svelt
let g:svelte_preprocessors = ['typescript', 'scss', 'sass']

" Vifm ===================================================
    " Disable netrw entirely
"let g:loaded_netrw = 1
"let g:loaded_netrwPlugin = 1

let g:vifm_replace_netrw = 1
let g:vifm_replace_netrw_cmd = "Vifm"
"let g:vifm_exec_args =
"let g:vifm_embed_split = 1

" TreeSitter =============================================
lua <<EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = "rust",
  hightlight = { enable = true },
  indent = { enable = true }
}
EOF

" Sneak ==================================================
"let g:sneak#s_next = 0

" 2-character Sneak instead of 1-character forwared
"omap s <Plug>Sneak_s
"omap S <Plug>Sneak_S
"
"map , <Plug>Sneak_;

" VimTex =================================================
let g:tex_flavor = 'latex'
"let g:vimtex_view_method = 'skim'  " Requires SkimPDF installed
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode = '0'

" UltiSnips ==============================================
    " Expand and jump only with tab
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
    " Only search for UltiSnips directory
let g:UltiSnipsSnippetDirectories = ['UltiSnips']
    " No warning message when UltiSnips is skipped
let g:UltiSnipsNoPythonWarning = 1

command! Texsnips :split ~/.vim/UltiSnips/tex.snippets
command! Texpreamble :split ~/.vim/UltiSnips/math_preamble.tex

" Vim-zoom ===============================================
nmap <leader>wz <Plug>(zoom-toggle)

" Catppuccin
let g:catppuccin_flavour = "mocha"

" Slime ==================================================
let g:slime_target = "tmux"
let g:slime_paste_file = "$HOME/.slime_paste"
let g:slime_python_ipython = 1
let g:slime_default_config = {
            \ 'socket_name': get(split($TMUX, ','), 0),
            \ 'target_pane': '{last}' }

" Slime Studio ===========================================
" Using slime to quickly create dynamic terminal REPLs
" <leader> once to run the current command
" <leader><leader> to change the command
let g:slime_studio_command1 = 'echo "make"'
let g:slime_studio_command2 = 'echo "make run"'
let g:slime_studio_command3 = 'echo "make submit"'

nnoremap <leader>r :exe "SlimeSend1 " . g:slime_studio_command1<CR>
nnoremap <leader><leader>r
    \ :let g:slime_studio_command1 =
    \ input("Slime Studio (1): ", g:slime_studio_command1)<CR>

nnoremap <leader>e :exe "SlimeSend1 " . g:slime_studio_command2<CR>
nnoremap <leader><leader>e
    \ :let g:slime_studio_command2 =
    \ input("Slime Studio (2): ", g:slime_studio_command2)<CR>

nnoremap <leader>f :exe "SlimeSend1 " . g:slime_studio_command3<CR>
nnoremap <leader><leader>f
    \ :let g:slime_studio_command3 =
    \ input("Slime Studio (3): ", g:slime_studio_command3)<CR>

" Gitgutter ==============================================
    " Disables git diff by default
let g:gitgutter_enabled = 0

    " Remove key bindings from gitgutter
let g:gitgutter_map_keys = 0

    " Toggle gitgutter
nnoremap <leader>ogit :GitGutterToggle<CR>

" FZF setup ==============================================
    " Open hotkeys for fzf
nnoremap <C-p> :Files<CR>
nnoremap <leader>; :Buffers<CR>

    " Edit config files
command! -bang Config call fzf#vim#files('~/.vim/init_scripts', <bang>0)

    " Window at the bottom with no preview
let g:fzf_layout = { 'down': '~20%' }
let g:fzf_preview_window = []

    " Files for fzf to search
let RG_TEMPLATE = 'rg --hidden --no-ignore --follow '
            \ . '-g ''!.git'' -g ''!target'' '
            \ . '-g ''!*node_modules'' -g ''!*build_kite'' '
            \ . '-g ''!site-packages'' -g ''!__pycache__'' '
            \ . '-g ''!Cargo.lock'' -g ''!bazel-*'' '
            \ . '-g ''!.DS_Store'' -g ''!*.swp'' '
            \ . '-g ''!*.fls'' -g ''!*.log'' -g ''!*.aux'' -g ''!*.mp3'' '
            \ . '-g ''!*.fdb_latexmk'' -g ''!*.synctex.gz'' '
            \ . '-g ''!*.pdf'' -g ''!*.o'' '
            \ . '-g ''!*.iso'' -g ''!*.qcow2'' -g ''!*.img'' '
            \ . '-g ''!*.mp4'' -g ''!*.mkv'' '
            \ . '-g ''!*.jpg'' -g ''!*.png'' '

let $FZF_DEFAULT_COMMAND = RG_TEMPLATE . '--files '

    " Use ripgrep with fzf (from Jonhoo)
noremap <leader>s :Rg<CR>
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   RG_TEMPLATE
  \   . '--column --ignore --line-number --no-heading --color=always '
  \   . shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

    " FZF colors match vim colorscheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" vim: set ff=unix ft=vim:
