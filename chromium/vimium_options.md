# Vimium's options backup
This is a markdown render of vimium's options version 1.67. Copy/pasting them
into vimium should work with future versions too. Storing them as a markdown
file is better for version control (git and codeberg)

## Excluded URLs and keys
```
Patterns                         Excluded keys
https?://mail.google.com/*    ::
https?://discord.com/*        ::
https?://cplayground.com/*    ::
https?://play.rust-lang.org/* ::
chrome-extension://*          ::
https?://docs.google.com/*    ::
https?://www.youtube.com/*    ::jtklF1234567890
about:blank*                  ::
https://flowchart.fun/*       ::
```

## Custom key mappings
Quotes are comments, just like in vimscript

```
unmapAll

map i enterInsertMode
map v enterVisualMode

" Navigation
map k scrollUp
map j scrollDown
map h scrollLeft
map l scrollRight
map <delete> scrollPageDown
map <c-s-left> scrollPageUp

map gg scrollToTop
map G scrollToBottom

" Changing pages
map H goBack
map J previousTab
map K nextTab
map L goForward
    " Creates an AB loop
map <c-o> visitPreviousTab

map x removeTab
map U restoreTab

" Moving tabs
map [ moveTabLeft
map ] moveTabRight

" Link hints
map f LinkHints.activateMode
map F LinkHints.activateModeToOpenInNewTab
"map <right> LinkHints.activateModeToOpenIncognito

" Copying
map yy copyCurrentUrl
map p openCopiedUrlInCurrentTab
map P openCopiedUrlInNewTab
map yu LinkHints.activateModeToCopyLinkUrl

" Searching
map / enterFindMode
map n performFind
map N performBackwardsFind

map <c-g> focusInput
map M toggleMuteTab

" Marks - Use lowercase for global
map m Marks.activateCreateMode swap
map ' Marks.activateGotoMode swap

" Omnibar Go-Open  Get-Url
map o Vomnibar.activate
map O Vomnibar.activateInNewTab
map <space>; Vomnibar.activateTabSelection
map gu Vomnibar.activateEditUrlInNewTab

" Escaping
mapkey <s-end> <c-[>
```

## Custom search engines
These get activated through "o". Hashes are comments

```
w: https://www.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia
r: https://www.reddit.com/r/%s
rs: https://docs.rs/%s
j: https://jisho.org/search/%s
s: https://www.startpage.com/do/search?query=%s&t=nite&lui=english&prfe=9b38632e38c508d3c566a3c3eeaf83b6723ec4f6a2dd947415e52195fcc15553f87a883baaae83e95a92fd5c511c18eb8eb42984ea796dfb5f0e63173af2eeeabe8c6b84cfefba542e3c1bc5ea47&cat=web&sc=z6ftNvCID1YN00
q: https://www.qwant.com?theme=1&hc=0&vt=1&s=0&b=0&l=en&locale=en_CA&q=%s
a: https://anilist.co/search/anime?search=%s

# More examples.
#
# (Vimium supports search completion Wikipedia, as
# above, and for these.)
#
# g: https://www.google.com/search?q=%s Google
# l: https://www.google.com/search?q=%s&btnI I'm feeling lucky...
# y: https://www.youtube.com/results?search_query=%s Youtube
# gm: https://www.google.com/maps?q=%s Google maps
# b: https://www.bing.com/search?q=%s Bing
# d: https://duckduckgo.com/?q=%s DuckDuckGo
# az: https://www.amazon.com/s/?field-keywords=%s Amazon
# qw: https://www.qwant.com/?q=%s Qwant
```

# Advanced options

## Miscellaneous options
```
Blank :: Use smooth scrolling
Blank :: Use link characters for link-hint filtering
Blank :: Don't let pages steal focus on load
Blank :: Hide Heads Up Display in insert mode
Blank :: Treat queries are JS regex expressions
Blank :: Ignore keyboard layout
```


## More advanced options
```
              Scroll step size: 60px
Characters used for link hints: weruioasdghkl
             Previous patterns: prev,previous,back,older,<,‹,←,«,≪,<<
                 Next patterns: next,more,newer,>,›,→,»,≫,>>
                   New tab URL: about:newtab
         Default search engine: https://www.google.com/search?q=
```

# Vimium CSS
```css
/*****************************************************************************/
/*                                   THEMES                                  */
/*****************************************************************************/

:root {
--font-size: max(2.4vh, 12px);
--font-weight: normal;
--font: sans-serif, tewi, Source Code Pro, sans;
--padding: 2px;
--shadow: 0 2px 4px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);

/***********************************/
/*    Uncomment Theme to Select    */
/***********************************/

/* ---------- Tomorrow Night ---------- */
/* -- DELETE LINE TO ENABLE THEME
--fg: #C5C8C6;
--bg: #282A2E;
--border: #373B41;
--main-fg: #81A2BE;
--accent-fg: #52C196;
-- DELETE LINE TO ENABLE THEME */

/* Unused Alternate Colors */
/* --bg-dark: #1D1F21; */
/* --cyan: #4CB3BC; */
/* --purple: #AC7BBA; */
/* --red: #CC6666; */
/* --yellow: #CBCA77; */

/* ---------- NORD ---------- */
/* -- DELETE LINE TO ENABLE THEME
--fg: #E5E9F0;
--bg: #2E3440;
--border: #3B4252;
--main-fg: #88C0D0;
--accent-fg: #A3BE8C;
-- DELETE LINE TO ENABLE THEME */

/* Unused Alternate Colors */
/* --bg-dark: #4C566A; */
/* --main-fg-alt: #5E81AC; */
/* --orange: #D08770; */
/* --red: #BF616A; */
/* --yellow: #EBCB8B; */

/* ---------- DOOM ONE ---------- */
/* -- DELETE LINE TO ENABLE THEME
--fg: #51AFEF;
--bg: #2E3440;
--border: #282C34;
--main-fg: #51AFEF;
--accent-fg: #98be65;
-- DELETE LINE TO ENABLE THEME */

/* Unused Alternate Colors */
/* --bg-dark: #21242B; */
/* --main-fg-alt: #2257A0; */
/* --cyan: #46D9FF; */
/* --orange: #DA8548; */
/* --purple: #C678DD; */
/* --red: #FF6C6B; */
/* --yellow: #ECBE7B; */

/* ---------- MONOKAI ---------- */
/* -- DELETE LINE TO ENABLE THEME
--fg: #F8F8F2;
--bg: #272822;
--bg-dark: #1D1E19;
--border: #2D2E2E;
--main-fg: #F92660;
--accent-fg: #E6DB74;
-- DELETE LINE TO ENABLE THEME */

/* Unused Alternate Colors */
/* --red: #E74C3C; */
/* --orange: #FD971F; */
/* --blue: #268BD2; */
/* --violet: #9C91E4; */
/* --cyan: #66D9EF; */

/* ---------- Edge Dark ---------- */
/* -- DELETE LINE TO ENABLE THEME
--fg: #c5cdd9;
--bg: #2c2e34;
--border: #828a98;
--main-fg: #6cb6eb;
--accent-fg: #a0c980;
-- DELETE LINE TO ENABLE THEME */

/* Unused Alternate Colors */
/* --bg-dark: #21242f; */
/* --cyan: #5dbbc1; */
/* --purple: #d38aea; */
/* --red: #ec7279; */
/* --yellow: #deb974; */

/* ---------- Gruvbox Dark ---------- */
--fg: #ebdbb2;
--bg: #282828;
--border: #3c3836;
--main-fg: #83a598;
/*--accent-fg: #b8bb26;*/
--accent-fg: var(--yellow);

/* Unused Alternate Colors */
--bg-pale-dark: #1d2021;
--bg-dark: black;
/*--cyan: #076678;*/
--cyan: #8EC07C;
/*--purple: #8f3f71;*/
--purple: #D3869B;
/*--red: #fb4934;*/
--yellow: #FABD2F;
}

/*****************************************************************************/
/*                                    CSS                                    */
/*****************************************************************************/

/* -------- HINTS -------- */
#vimiumHintMarkerContainer div.internalVimiumHintMarker, #vimiumHintMarkerContainer div.vimiumHintMarker {
background: var(--fg) !important;
border: 1px solid var(--bg-dark);
box-shadow: var(--shadow);
padding: 3px 4px;
border-width: .3vh;
}

#vimiumHintMarkerContainer div span {
color: var(--bg-dark);
font-family: var(--font);
font-weight: bold;
text-shadow: none;
font-size: max(1.8vh, 12px);  /* Consistent hint box sizes between zoom levels */
text-transform: lowercase;
}

#vimiumHintMarkerContainer div > .matchingCharacter {
opacity: 0.4;
}

#vimiumHintMarkerContainer div > .matchingCharacter ~ span {
/*color: var(--main-fg);*/
opacity: 1.0;
}

/* -------- VOMNIBAR -------- */
#vomnibar {
background: var(--bg);
border: .3vh solid var(--accent-fg);
font-size: 2.4vh;
box-shadow: var(--shadow);
width: max(100vh, 80%);
margin: 0 calc((100% - max(100vh, 80%)) / 2);
top: 0;
left: 0;
}

#vomnibar .vomnibarSearchArea,
#vomnibar input {
background: transparent;
border: none;
box-shadow: none;
color: var(--fg);
font-family: var(--font);
font-size: var(--font-size);
font-weight: var(--font-weight);
}

#vomnibar input {
padding: var(--padding);
font-size: 2.6vh;
}

#vomnibar .vomnibarSearchArea {
padding: var(--padding) 30px;
padding: 10px 30px;
border: none;
}

#vomnibar ul {
margin: 0;
padding: var(--padding);
background: var(--bg);
border-top: 1px solid var(--border);
}

#vomnibar li {
border-bottom: .1vh solid var(--border);
font-size: 2.4vh;
/*padding: var(--padding);*/
padding: 2px 3px;
}

#vomnibar li .vomnibarTopHalf,
#vomnibar li .vomnibarBottomHalf {
/*padding: var(--padding) 0;*/
padding: 3px 0;
font-size: 2.4vh;
}

#vomnibar li .vomnibarSource {
color: var(--purple);
font-family: var(--font);
font-size: var(--font-size);
font-weight: var(--font-weight);
}

#vomnibar li em,
#vomnibar li .vomnibarTitle {
color: var(--accent-fg);
font-family: var(--font);
font-size: var(--font-size);
font-weight: var(--font-weight);
}


#vomnibar li .vomnibarUrl {
color: var(--fg);
font-family: var(--font);
font-size: var(--font-size);
font-weight: var(--font-weight);
}

#vomnibar li .vomnibarMatch {
color: var(--accent-fg);
font-weight: normal;
}

#vomnibar li .vomnibarTitle .vomnibarMatch {
color: var(--cyan);
}

#vomnibar li.vomnibarSelected {
background-color: var(--border);
}

/* ==== Custom additions ==== */
#vomnibar > ul > li > div.vimiumReset.vomnibarBottomHalf,
#vomnibar > ul > li > div.vimiumReset.vomnibarTopHalf,
#vomnibar > ul > li > span.vimiumReset.vomnibarTopHalf {
white-space: nowrap;
padding-left: 20px;
display: flex;
}

#vomnibar > ul > li > div.vimiumReset.vomnibarBottomHalf > span.vimiumReset.vomnibarSource.vomnibarNoInsertText,
#vomnibar > ul > li > div.vimiumReset.vomnibarTopHalf > span.vimiumReset.vomnibarSource.vomnibarNoInsertText {
display: none;
}

#vomnibar > ul > li > div.vimiumReset.vomnibarTopHalf > span.vimiumReset.vomnibarTitle {
white-space: nowrap;
}

#vomnibar > ul > li > div.vimiumReset.vomnibarTopHalf > span:nth-child(2) {
flex-shrink: 0;
}



/* -------- HUD -------- */
div.vimiumHUD {
background: var(--bg);
border: 1px solid var(--border);
box-shadow: var(--shadow);
}

div.vimiumHUD span#hud-find-input,
div.vimiumHUD .vimiumHUDSearchAreaInner {
color: var(--fg);
font-family: var(--font);
font-weight: var(--font-weight);
}

div.vimiumHUD .hud-find {
background-color: transparent;
border: none;
}

div.vimiumHUD .vimiumHUDSearchArea {
background-color: transparent;
}


/* ==== Custom additions ==== */
#hud-find-input {
font-size: 20px;
}

```

