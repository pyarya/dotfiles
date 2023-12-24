" Creates a simple lightweight tabline intended for vanilla vim

" Always display tabline
set showtabline=2

" ========================================================
" # TODO Weather notification TODO
" ====================================================={{{
function! Weather()
    let l:forecasts = GetForecast()

    if l:forecasts[0]
        " First index is to unwrap tuple returned by GetForecast()
        " Forecast in 3 hours
        let l:next_forecast = l:forecasts[1][0]['weather'][0]

        " TODO: Change tabsline instead of just echoing
        echom WeatherCondition(l:next_forecast)
    else
        " TODO: Better error reporting in tabline
        echom 'Error: `' . l:forecasts[1] . '`'
    endif
endfunction

" Tries to grab the weather off OpenWeather
"
" Returns:
"   First item indicates the api call was successful. Second item contains
"   relevent data returned by the api
"
"   [1, list]: List of forecasts in 3h intervals
"   [0, str]: String is the error message from the server
function! GetForecast()
    " Makes request for json
    let l:response = system('curl --silent ''http://api.openweathermap.org/data/2.5/forecast?q=edmonton&appid=317f9cc8efd9ce81736994c0497eb7b2''')
    let l:json = json_decode(l:response)
    " let l:unix_epoch = str2nr(system('date +"%s"'))

    " Success case is code 200
    if l:json['cod'] ==# '200'
        " List of forecasts in 3h intervals
        return [1, l:json['list']]
    else
        return [0, l:json['message']]
    endif
endfunction


" Returns a simple string for the general idea of the weather conditions
" Arg:
"   forecast (dict): one time's forecast dictionary, parsed from json
"
" Return:
"   str: General idea of the weather
function! WeatherCondition(forecast)
    " Numerical identification for weather conditions
    " See id codes here: https://openweathermap.org/weather-conditions
    let l:forecast_id = a:forecast['id']

    if l:forecast_id[:0] ==# '2'
        " Thunderstorm
        return 'Thunderstorm'
    elseif l:forecast_id[:0] ==# '5' || l:forecast_id[:0] ==# '3'
        " Rain or `drizzle`
        return 'Rain'
    elseif l:forecast_id[:0] ==# '6'
        " Snow
        return 'Snow'
    elseif l:forecast_id[:0] ==# '8'
        " Cloudly or clear. Nothing exciting
        return 'Normal'
    elseif l:forecast_id[:0] ==# '7'
        " Atmospheric abnormality ex: Dust, Smoke, Sand, Tornado
        if l:forecast_id ==# '781'
            " Tornado!
            return 'Tornado'
        elseif l:forecast_id ==# '711'
            " Smoke
            return 'Smoke'
        elseif l:forecast_id ==# '741'
            " Fog
            return 'Fog'
        elseif l:forecast_id ==# '761'
            " Dust
            return 'Dust'
        else
            return 'Atomspheric abnormality'
        endif
    else
        " Error: should have matched above
        return 'Error: Failed to find weather condition code `' . l:forecast_id . '`'
    endif
endfunction

" }}}

" ========================================================
" # Build TabLine
" ====================================================={{{

" Creates visual label/title for a tab
function! TabLabel(tab_num)
    let l:tab_label = ''

    " Different highlight for active tab =================
    if a:tab_num ==# tabpagenr()
            " Is active tab
        let l:tab_HL = '%#TabLineActiveHL#'

        if a:tab_num ==# tabpagenr('$')
                " Active tab is last tab
            let l:tab_trans_HL = '%#TabLineActiveToBGHL#'
        else
            let l:tab_trans_HL = '%#TabLineActiveToIdleHL#'
        endif

        let l:tab_seperator = ''
    elseif a:tab_num ==# tabpagenr() - 1
            " Tab right before active tab
        let l:tab_HL = '%#TabLineIdleHL#'
        let l:tab_trans_HL = '%#TabLineIdleToActiveHL#'
        let l:tab_seperator = ''
    elseif a:tab_num ==# tabpagenr('$')
            " Last tab and it's idle
        let l:tab_HL = '%#TabLineIdleHL#'
        let l:tab_trans_HL = '%#TabLineIdleToBGHL#'
        let l:tab_seperator = ''
    else
            " Inactive tab not adjacent to active tab
        let l:tab_HL = '%#TabLineIdleHL#'
        let l:tab_trans_HL = '%#TabLineIdleHL#'
        let l:tab_seperator = ''
    endif

    let l:tab_label .= l:tab_HL

    " Ordered list of buffer ids open in the tab =========
    let l:buff_list = tabpagebuflist(a:tab_num)

        " Path to first buffer in the tab
    let l:curr_buff_path = bufname(l:buff_list[0])

        " Truncate file path to tail only
    let l:tab_title = fnamemodify(l:curr_buff_path, ':t')

    let l:click_mark = '%' . a:tab_num . 'T'  " Support for mouse clicks

    " Tab number, file name, powerline seperator =========
    let l:tab_label .=
    \ l:click_mark . '  ' . a:tab_num . ' ' . l:tab_title . ' ' . l:tab_trans_HL . l:tab_seperator

    let s:columns_used += strchars(a:tab_num . l:tab_title . l:tab_seperator) + 4

        " If tabline is not full
    if &columns - s:columns_used > 0
        return l:tab_label
    else
        return ''
endfunction


" Tab count on the left
" Clicking it moves jumps to the last tab, except from the last tab, where it
" jumps to the first tab
function! TabLineLabel()
    " Edge case for
    if tabpagenr() == 1
        let l:trans_HL = '%#TabLineActiveHL#'
        let l:tab_seperator = ''
    else
        let l:trans_HL = '%#TabLineActiveToIdleHL#'
        let l:tab_seperator = ''
    endif

        "TODO: If rapidly clicked, creates new blank
    if tabpagenr() == tabpagenr('$')
        let l:click_mark = '%' . 1 . 'T'  " Jump to first tab, when on last tab
    else
        let l:click_mark = '%' . tabpagenr('$') . 'T'  " Jump to last tab
    endif


    let l:tab_counter_str = ' Tabs: ' . tabpagenr('$') . ' '

    let l:tab_counter =
    \ l:click_mark . '%#TabLineActiveHL# Tabs: ' . tabpagenr('$') . ' ' . l:trans_HL . l:tab_seperator

    let s:columns_used += strchars(l:tab_counter_str)

    return l:tab_counter
endfunction


" Build and return tabline, with the same hues as the statusline
function! TabLine()
    call ReloadStatlnColors()

    let s:columns_used = 0  " Count to prevent overflow
    "TODO: implement hidden markers
    "let s:is_hidden_left = 0   " Tabs hidden on the right
    "let s:is_hidden_right = 0  " Tabs hidden on the left

    let l:tabline_tab_count = TabLineLabel()

        " Tries adding the previous, active, and next tabs before any others
        " In case of overflow, active tab will be shown
    if tabpagenr('$') < 3 || tabpagenr() < 3
        let l:start_iter = 1
    else
        let l:start_iter = tabpagenr() - 1  " Tab before active tab
    endif

        " All tabs after and including the tab before the active tab
    let l:active_onwards = ''
    for i in range(l:start_iter, tabpagenr('$'))
        let l:active_onwards .= TabLabel(i)  " Visible tab label
    endfor

        " All tabs preceeding the tab before the active tab
    let l:preceeding_active = ''
    for i in range(l:start_iter - 1, 1, -1)
        let l:preceeding_active = TabLabel(i) . l:preceeding_active " Visible tab label
    endfor

    return l:tabline_tab_count . l:preceeding_active . l:active_onwards
endfunction

au BufEnter,BufLeave,WinEnter,WinLeave * set tabline=%!TabLine()

" }}}
