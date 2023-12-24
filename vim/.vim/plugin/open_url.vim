" Opens the first URL on the current line. On macs, the tab is opened in
" incongito
" Note: `gx` can do something very similar by default in vim
function! OpenURL()
    let s:open_url = matchstr(getline("."), '\vhttps?://[A-z0-9-\._~/?\[\]@!\$&\(\)*+,;=#%]+')
    let l:kernel_name = matchstr(system('uname'), '\v(Darwin)|(Linux)')

    if s:open_url == ''
        echom 'No URL found on this line'
    elseif l:kernel_name == 'Darwin'
        call system("open -n -a 'Google Chrome' --args --incognito '" . s:open_url . "'")
    elseif executable('chromium')
          call system("chromium --incognito '" . s:open_url . "'")
    elseif executable('chromium-browser')
          call system("chromium-browser --incognito '" . s:open_url . "'")
    elseif executable('google-chrome')
          call system("google-chrome --incognito '" . s:open_url . "'")
    elseif executable('chrome-browser')
          call system("chrome-browser --incognito '" . s:open_url . "'")
    elseif executable('firefox')
          call system("firefox '" . s:open_url . "'")
    else
        echom 'No browser found'
    endif
endfunction
