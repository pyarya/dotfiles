" Removes trailing white space across the entire file
function! RemoveTailingWhitespace()
    let l:prev_search = @/       " Search register
    let l:cur_pos = getcurpos()  " Cursor position

    silent! %s/\V\s\+\$//

    let @/ = l:prev_search  " Restore search register
    call setpos('.', l:cur_pos)  " Move cursor back to starting place
endfunction


    " Always remove tailing whitespace on write
autocmd BufWrite * call RemoveTailingWhitespace()

command! Trim call RemoveTailingWhitespace()
