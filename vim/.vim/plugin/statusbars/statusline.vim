" Very minital statusline for vim
" Supports vim 8.0 and up and neovim 0.4 and likely earlier versions

    " Always show
set laststatus=2

" ========================================================
" # Statusline highlights
" ====================================================={{{
augroup statusbars_colorscheme_matching
    au!
    autocmd ColorScheme * call ReloadStatlnColors()
augroup END

" Function taken from vim airline
" https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/highlighter.vim#L17
function! GuiColors(rgb, fallback)
    if a:rgb[0] !~ '#'
        return a:fallback
    endif
    return a:rgb
endfunction

    " Also set as active tabline hue
let g:StatlnPrimaryColor = '#000000'
"    \ GuiColors(synIDattr(synIDtrans(hlID('String')), 'fg', 'gui'), '#000000')

" Updates statusline colors
function! ReloadStatlnColors()
    call SetGlobalPrimaryColor()

    let g:StatlnPrimaryFG = GuiColors(synIDattr(synIDtrans(hlID('Normal')), 'bg', 'gui'), '#222222')
        \ | let g:StatlnSubtle = GuiColors(synIDattr(synIDtrans(hlID('Normal')), 'fg', 'gui'), '#DAB997')
        \ | let g:StatlnSubtleBG = GuiColors(synIDattr(synIDtrans(hlID('Visual')), 'bg', 'gui'), '#4E4E4E')
        \ | let g:StatlnIdle = GuiColors(synIDattr(synIDtrans(hlID('Search')), 'bg', 'gui'), '#FFAF00')
        \ | let g:StatlnIdleBG = GuiColors(synIDattr(synIDtrans(hlID('Normal')), 'bg', 'gui'), '#222222')

    " Colored accent highlight changing based on the mode
        " Statusline: Left and right corners
        " TabLine: Active tab
    execute 'highlight StatlnPrimaryHL'
        \ . ' guifg=' . g:StatlnPrimaryFG
        \ . ' guibg=' . g:StatlnPrimaryColor
        \ . ' term=bold cterm=bold gui=bold'

    highlight! link TabLineActiveHL StatlnPrimaryHL

    " Primary highlight transitions for powerline seperators
        " Statusline: Left/right corners to adjacent
        " Tabline: Active <-> Idle tabs
    execute 'highlight StatlnPrimaryToSubtleHL guifg=' . g:StatlnSubtleBG . ' guibg=' . g:StatlnPrimaryColor
    highlight! link TabLineIdleToActiveHL StatlnPrimaryToSubtleHL

    execute 'highlight StatlnSubtleToPrimaryHL guifg=' . g:StatlnPrimaryColor . ' guibg=' . g:StatlnSubtleBG
    highlight! link TabLineActiveToIdleHL StatlnSubtleToPrimaryHL

        " Small Statusline: Center -> blank right side
        " TabLine: Active tab -> blank right side
    execute 'highlight TabLineActiveToBGHL guifg=' . g:StatlnPrimaryColor . ' guibg=' . g:StatlnIdleBG
    execute 'highlight StatlnPrimaryToIdleHL guifg=' . g:StatlnIdleBG . ' guibg=' . g:StatlnPrimaryColor

    " Secondary highlight
        " Statusline: Adjacent to corners
        " Tabline: Inactive (idle) tabs
    execute 'highlight StatlnSubtleHL guifg=' . g:StatlnSubtle . ' guibg=' . g:StatlnSubtleBG
    highlight! link TabLineIdleHL StatlnSubtleHL

    " Secondary highlight transitions for powerline seperators
        " StatusLine: Into/from the middle gap
        " Small StatusLine: Blank left side -> center
        " Tabline: Inactive tab -> blank right side
    execute 'highlight StatlnSubtleToIdleHL guifg=' . g:StatlnIdleBG . ' guibg=' . g:StatlnSubtleBG
    execute 'highlight StatlnIdleToPrimaryHL guifg=' . g:StatlnPrimaryColor . ' guibg=' . g:StatlnIdleBG

    execute 'highlight StatlnIdleToSubtleHL guifg=' . g:StatlnSubtleBG . ' guibg=' . g:StatlnIdleBG
    highlight! link TabLineIdleToBGHL StatlnIdleToSubtleHL

    " Tertiary highlight
        " StatusLine: Background of statusline and inactive buffers
    execute 'highlight StatlnIdleHL guifg=' . g:StatlnIdle ' guibg=' . g:StatlnIdleBG
    execute 'highlight StatlnIdleInverseHL guifg=' . g:StatlnIdleBG ' guibg=' . g:StatlnIdle

endfunction


" Sets primary color highlight for statusline and tabline, based on the mode
" Updates the name of the mode in the statusline
function! SetGlobalPrimaryColor()
    let l:mode = mode()  " Returns vim's current mode

    if l:mode ==# 'n'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('String')), 'fg', 'gui'), '#b8bb26')
        let g:mode_str = 'NORMAL'  " Light green
    elseif l:mode ==# 'i'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Function')), 'fg', 'gui'), '#83ADAD')
        let g:mode_str = 'INSERT'  " Light blue
    elseif l:mode ==# 'R'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Error')), 'bg', 'gui'), '#D75F5F')
        let g:mode_str = 'REPLACE'  " Light red
    elseif l:mode ==# 'v'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Keyword')), 'fg', 'gui'), '#D485AD')
        let g:mode_str = 'VISUAL'  " Pink/light purple
    elseif l:mode ==# 'V'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Keyword')), 'fg', 'gui'), '#D485AD')
        let g:mode_str = "V-LINE"  " Pink/light purple
    elseif l:mode ==# "\<C-v>"
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Keyword')), 'fg', 'gui'), '#D485AD')
        let g:mode_str = "V-BLOCK"  " Pink/light purple
    elseif l:mode ==# 's'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Special')), 'fg', 'gui'), '#85AD85')
        let g:mode_str = 'SELECT'  " Turquoise
    elseif l:mode ==# 'c'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Special')), 'fg', 'gui'), '#85AD85')
        let g:mode_str = 'COMMAND'  " Turquoise
    elseif l:mode ==# '!'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Special')), 'fg', 'gui'), '#85AD85')
        let g:mode_str = 'SHELL'  " Turquoise
    elseif l:mode ==# 't'
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Special')), 'fg', 'gui'), '#85AD85')
        let g:mode_str = 'TERM'  " Turquoise
    else
        let g:StatlnPrimaryColor = GuiColors(synIDattr(synIDtrans(hlID('Special')), 'fg', 'gui'), '#85AD85')
        let g:mode_str = 'UNKNOWN'  " Turquoise
    endif
endfunction

" }}}


" ========================================================
" # Statusline helper functions
" ====================================================={{{
" Returns the current git branch, or an empty string
function! StatlnGitBranch()
    let l:branch = system('git branch --show-current')

    if l:branch !~ ' '
        return '  '
    else
        return ''
    endif
endfunction


" Modified buffer indicator
function! StatlnModified()
    let l:is_modified = getbufinfo(bufnr('%'))[0].changed

    if l:is_modified && &readonly
        let l:modified_marker = '[!]'  " Ah! You modified a read-only buffer
    elseif l:is_modified
        let l:modified_marker = '[+]'
    elseif &readonly
        let l:modified_marker = '[-]'
    else
        let l:modified_marker = ''  " No indicator for unmodified normal buffer
    endif

    return l:modified_marker
endfunction


" Set the primary status/tabline color and the mode string
function! StatlnMode()
    call SetGlobalPrimaryColor()
    call ReloadStatlnColors()

        " Redraws tabline and updates the global mode color
        " Required to synchronize tabline and statusline properly
    set tabline=%!TabLine()

    return g:mode_str . ' '
endfunction


" Upper estimate for the length of the active stausline, not inluding the
" middle gap
function! EstStatlnLength()
    let l:mode_len = 11
    let l:buff_len = len(fnamemodify(bufname("%"), ':t')) + 7

    let l:file_type_len = len(&filetype) + 6
    let l:line_metrics_len = len(string(line('$'))) * 2 + 12

    return l:mode_len + l:buff_len + l:file_type_len + l:line_metrics_len
endfunction

" }}}


" ========================================================
" # Build and reload Statusline
" ====================================================={{{
" Statusline for active window
"
" Switches to a compact version for narrow windows
function! ActiveStatusline()
    " Update statusline on all events
    let l:track_mode='%{strpart(StatlnMode(), 0, 0)}'

    " Compact statusline ============================================
    " Current buffer's name centered with mode-specific background color
    let l:left='%#StatlnIdleHL#' . '%{StatlnSmall("margin_left")}'
           \ . '%#StatlnIdleToPrimaryHL#' . '%{StatlnSmall("seperator")}'
    let l:buff='%#StatlnPrimaryHL#' . '%{StatlnSmall("file_name")}'
           \ . '%#StatlnPrimaryToIdleHL#' . '%{StatlnSmall("seperator")}'
    let l:right='%#StatlnIdleHL#' . '%{StatlnSmall("margin_right")}'

    let l:small_line = l:left . l:buff . l:right

    " Left side =====================================================
    " Current mode bold and with a mode-specific background color
    let l:mode='%#StatlnPrimaryHL#' . '%{StatlnFull("mode")}'
           \ . '%#StatlnPrimaryToSubtleHL#' . '%{StatlnFull("seperator")}'
    " Current buffer's name and an indicator if it was modified
    let l:buff='%#StatlnSubtleHL#' . '%{StatlnFull("file_name")}'
           \ . '%#StatlnSubtleToIdleHL#' . '%{StatlnFull("seperator")}'

    let l:left_side = l:mode . l:buff . '%#StatlnIdleHL#'

    " Right side ====================================================
    let l:trans_from_gap='%#StatlnIdleToSubtleHL#' . '%{StatlnFull("seperator")}'
    " File type in []
    let l:file_type='%#StatlnSubtleHL#' .  '%{StatlnFull("file_type")}'
                \ . '%#StatlnSubtleToPrimaryHL#' .  '%{StatlnFull("seperator")}'
    " Scroll percentage, column, line / total lines, with mode-background color
    let l:line_metrics='%#StatlnPrimaryHL#%{StatlnFull("line_metrics")}'

    let l:right_side='%=' . l:trans_from_gap . l:file_type . l:line_metrics

    let l:full_line =  l:left_side . l:right_side

    " Return all. Only one line with render at a time
    return l:track_mode . l:small_line . l:full_line
endfunction


" Returns component for the compact statusline
"
" Returns empty strings if the window is wide enough for a full sized
" statusline
function! StatlnFull(part)
    let l:is_small_window = winwidth(0) <= EstStatlnLength() - 18

    if !l:is_small_window
        if 'mode' ==# a:part
            return '  ' . StatlnMode()

        elseif 'seperator' ==# a:part
            return ' '

        elseif 'file_name' ==# a:part
            let l:file_name = fnamemodify(bufname('%'), ':t')
            " Blank buffer
            if len(l:file_name) == 0
                let l:file_name = '[No Name]'
            endif
            return '  ' . l:file_name . ' ' . StatlnModified()

        elseif 'file_type' ==# a:part
            " Blank buffer
            if len(&filetype) == 0
                return ''
            endif
            return '[' . &filetype . ']'

        elseif 'line_metrics' ==# a:part
            let l:total = line('$')
            let l:current = line('.')
            let l:frac = ' ' . l:current . '/' . l:total . ' '

            let l:col = printf('%2S', col('.'))

            let l:percent = float2nr(l:current * 100 / l:total) . '% ☰ '

            return l:percent . l:col . l:frac

        else
            echom 'Error: a:part for the full statusline doesn''t match any part'
            return ''
        endif
    else
        " Part indicated shouldn't render, since the compact statusline should
        " be rendering instead
        return ''
    endif
endfunction


" Returns component for full sized statusline
"
" Returns empty strings if the window is too narrow for a full sized
" statusline
function! StatlnSmall(part)
    let l:is_small_window = winwidth(0) <= EstStatlnLength() - 18

    if l:is_small_window
        if 'margin_left' ==# a:part
            return repeat('—', 7) . ' '

        elseif 'margin_right' ==# a:part
            let l:len = winwidth(0)
                \ - strchars(StatlnSmall('margin_left'))
                \ - strchars(StatlnSmall('file_name'))
                \ - 3  "Unclear where this magical constant appears

            return '  ' . repeat('—', l:len - 1)

        elseif 'seperator' ==# a:part
            return ' '

        elseif 'file_name' ==# a:part
            return '  ' . fnamemodify(bufname("%"), ':t') . ' ' . StatlnModified()

        else
            echom 'Error: a:part for the compact statusline doesn''t match any part'
            return ''
        endif
    else
        " Part shouldn't render since the window is wide enough for the full
        " statusline to render instead
        return ''
    endif
endfunction


" Status line for all windows except the focused window
"
" Transparent background with em-dash margins around the buffer's name
function! IdleStatusline()
    call ReloadStatlnColors()
    set fillchars=stlnc:— " All empty space filled with em-dashes

    " Left padding to align file name with active stl.
    " Same background as editor makes it very minimalist
    return '%#StatlnIdleHL#—————————— %t %{StatlnModified()} '
endfunction


augroup SetStatusLine
    autocmd!
    au BufEnter,WinEnter * let &l:stl = ActiveStatusline()
    au BufLeave,WinLeave * let &l:stl = IdleStatusline()

    " Updates status/tabline when entering command prompt
    au CmdlineEnter * redraw
augroup end

" }}}


" Further reading:
    " https://shapeshed.com/vim-statuslines/
    " https://www.reddit.com/r/vim/comments/ld8h2j/i_made_a_status_line_from_scratch_no_plugins_used/
