"Creates a Pretty Comment Box:
"╔─────────────────╗
"│ Like this one!  │
"╚─────────────────╝

function! PrettySectionComment(type)
    let content = getline('.')
    let text_width = strwidth(content)
    let total_width = text_width + 3 " 3 line after text for neatness

    if a:type ==# '/*'
        let top_border = '/*' . repeat('─', total_width) . '╗'
        let bottom_border = '╚' . repeat('─', total_width) . '*/'
        let content_line = '│ ' . content . repeat(' ', total_width - text_width - 1) . ' │'
    elseif a:type ==# '<!--'
        let top_border = '<!--' . repeat('─', total_width) . '╗'
        let bottom_border = '╚' . repeat('─', total_width + 1) . '-->'
        let content_line = '│ ' . content . repeat(' ', total_width - text_width + 1) . ' │'
    elseif a:type ==# '//'
        let top_border = '//╔' . repeat('─', total_width) . '╗'
        let bottom_border = '//╚' . repeat('─', total_width) . '╝'
        let content_line = '//│ ' . content . repeat(' ', total_width - text_width - 2) . ' │'
    else
        let top_border = '#╔' . repeat('─', total_width) . '╗'
        let bottom_border = '#╚' . repeat('─', total_width) . '╝'
        let content_line = '#│ ' . content . repeat(' ', total_width - text_width - 2) . ' │'
    endif

    " Replace the original line with the top of box
    call setline('.', top_border)
    call append(line('.'), content_line)
    call append(line('.') + 1, bottom_border)

    normal! j j j
endfunction

