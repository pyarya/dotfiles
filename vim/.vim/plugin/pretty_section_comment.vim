" Creates a pretty comment box
"╔─────────────────────────────────────────────────────────────────────────────╗
"│ L𝓲kε τh𝓲s bεαμτy!                                                           |
"╚─────────────────────────────────────────────────────────────────────────────╝
function! PrettySectionComment(type)
    " Fancy unicode
    silent! s/A/Λ/g
    silent! s/a/α/g
    silent! s/e/ε/g
    silent! s/n/η/g
    silent! s/o/δ/g
    silent! s/p/ρ/g
    silent! s/t/τ/g
    silent! s/u/μ/g
    silent! s/v/ν/g
    silent! s/w/ω/g
    silent! s/x/χ/g

    if a:type ==# '/*'
        call append(line(".") - 1,
    \ "/*─────────────────────────────────────────────────────────────────────────────╗")
        call append(line("."),
    \ "╚─────────────────────────────────────────────────────────────────────────────*/")
    elseif a:type ==# '//'
        call append(line(".") - 1,
    \ "//╔────────────────────────────────────────────────────────────────────────────╗")
        call append(line("."),
    \ "//╚────────────────────────────────────────────────────────────────────────────╝")
    else
        call append(line(".") - 1,
    \ "#╔─────────────────────────────────────────────────────────────────────────────╗")
        call append(line("."),
    \ "#╚─────────────────────────────────────────────────────────────────────────────╝")
    endif

        " Delete text
    exe "normal! ^D0"
        " Insert 80 spaces
    exe "normal! 80i \<esc>"

        " Paste back in commented text
    if a:type ==# '/*'
        exe "normal! 0i│ \<C-r>\"\<esc>"
    elseif a:type ==# '//'
        exe "normal! 0i//│ \<C-r>\"\<esc>"
    else
        exe "normal! 0i#│ \<C-r>\"\<esc>"
    endif

        " Add closing bar on right
    exe "normal! 079li|\<esc>"
endfunction
