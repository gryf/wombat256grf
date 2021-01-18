" Vim color file
" Maintainer: Roman 'gryf' Dobosz
" Last Change: 2021-01-18
"
" wombat256grf.vim - a modified version of Wombat by Lars Nielsen (at al) that
" also works on xterms with 88 or 256 colors. Instead of hard coding colors
" for the terminal, algorithm for approximating the GUI colors with the xterm
" palette was used. Approximation function was taken from desert256.vim by
" Henry So Jr.

set background=dark

if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let g:colors_name = "wombat256grf"

if !has("gui_running") && &t_Co != 88 && &t_Co != 256
    finish
endif

" functions {{{
" helper function for numerical sorting.
function s:sort_ints(a, b)
    let l:a = str2nr(a:a)
    let l:b = str2nr(a:b)
    return l:a == l:b ? 0 : l:a > l:b ? 1 : -1
endfunction

" returns an approximate grey index for the given grey level
fun s:get_approximate_grey_idx(x)
    if &t_Co == 88
        let l:grey_map = {23: 0, 69: 1, 103: 2, 127: 3, 150: 4, 173: 5, 196: 6,
                    \219: 7, 243: 8}
        for i in sort(keys(l:grey_map), "s:sort_ints")
            if a:x < i
                return l:grey_map[i]
            endif
        endfor
        return 9
    else
        if a:x < 14
            return 0
        endif
        let l:n = (a:x - 8) / 10
        let l:m = (a:x - 8) % 10
        if l:m < 5
            return l:n
        else
            return l:n + 1
        endif
    endif
endfun

" returns the actual grey level represented by the grey index
fun s:get_grey_level(n)
    if &t_Co == 88
        let l:grey_map = {0: 0, 1: 46, 2: 92, 3: 115, 4: 139, 5: 162, 6: 185,
                    \7: 208, 8: 231, 9: 255}
        return get(l:grey_map, a:n)
    endif
    return a:n == 0 ? 0 : 8 + (a:n * 10)
endfun

" returns the palette index for the given grey index
fun <SID>grey_color(n)
    if &t_Co == 88
        if a:n == 0
            return 16
        elseif a:n == 9
            return 79
        else
            return 79 + a:n
        endif
    else
        if a:n == 0
            return 16
        elseif a:n == 25
            return 231
        else
            return 231 + a:n
        endif
    endif
endfun

" returns an approximate color index for the given color level
fun <SID>rgb_number(x)
    if &t_Co == 88
        if a:x < 69
            return 0
        elseif a:x < 172
            return 1
        elseif a:x < 230
            return 2
        else
            return 3
        endif
    else
        if a:x < 75
            return 0
        else
            let l:n = (a:x - 55) / 40
            let l:m = (a:x - 55) % 40
            if l:m < 20
                return l:n
            else
                return l:n + 1
            endif
        endif
    endif
endfun

" returns the actual color level for the given color index
fun <SID>rgb_level(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 139
        elseif a:n == 2
            return 205
        else
            return 255
        endif
    else
        if a:n == 0
            return 0
        else
            return 55 + (a:n * 40)
        endif
    endif
endfun

" returns the palette index for the given R/G/B color indices
fun <SID>rgb_color(x, y, z)
    if &t_Co == 88
        return 16 + (a:x * 16) + (a:y * 4) + a:z
    else
        return 16 + (a:x * 36) + (a:y * 6) + a:z
    endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun <SID>color(r, g, b)
    " get the closest grey
    let l:gx = s:get_approximate_grey_idx(a:r)
    let l:gy = s:get_approximate_grey_idx(a:g)
    let l:gz = s:get_approximate_grey_idx(a:b)

    " get the closest color
    let l:x = <SID>rgb_number(a:r)
    let l:y = <SID>rgb_number(a:g)
    let l:z = <SID>rgb_number(a:b)

    if l:gx == l:gy && l:gy == l:gz
        " there are two possibilities
        let l:dgr = s:get_grey_level(l:gx) - a:r
        let l:dgg = s:get_grey_level(l:gy) - a:g
        let l:dgb = s:get_grey_level(l:gz) - a:b
        let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
        let l:dr = <SID>rgb_level(l:gx) - a:r
        let l:dg = <SID>rgb_level(l:gy) - a:g
        let l:db = <SID>rgb_level(l:gz) - a:b
        let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
        if l:dgrey < l:drgb
            " use the grey
            return <SID>grey_color(l:gx)
        else
            " use the color
            return <SID>rgb_color(l:x, l:y, l:z)
        endif
    else
        " only one possibility
        return <SID>rgb_color(l:x, l:y, l:z)
    endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun <SID>rgb(rgb)
    let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
    let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
    let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
    return <SID>color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun <SID>X(group, fg, bg, attr)
    if a:fg != ""
        exec "hi ".a:group." guifg=#".a:fg." ctermfg=".<SID>rgb(a:fg)
    endif
    if a:bg != ""
        exec "hi ".a:group." guibg=#".a:bg." ctermbg=".<SID>rgb(a:bg)
    endif
    if a:attr != ""
        if a:attr == 'italic'
            exec "hi ".a:group." gui=".a:attr." cterm=none"
        else
            exec "hi ".a:group." gui=".a:attr." cterm=".a:attr
        endif
    endif
endfun

" same as above, but makes it for the spell-like things
fun <SID>Y(group, bg)
    if ! has('gui_running')
        if a:bg != ""
            exec "hi ".a:group." ctermbg=".<SID>rgb(a:bg)
        endif
    else
        if a:bg != ""
            exec "hi ".a:group." guisp=#".a:bg." gui=undercurl"
        endif
    endif
endfun
" }}}

" italic only in gui and only where font is not fixed-misc!
if has("gui_running") && &guifont !~ "Fixed"
    let s:italic = "italic"
else
    let s:italic = "none"
endif


" X(fg, bg, attr)
" non-syntax items, interface, etc
call <SID>X("Normal",       "dddddd",   "242424",   "none")
call <SID>X("NonText",      "4c4c36",   "",         "none")
call <SID>X("Cursor",       "222222",   "ecee90",   "none")

if version > 700
    call <SID>X("CursorLine",   "", "32322e",   "none")
    hi link CursorColumn CursorLine
    if version > 703
        call <SID>X("ColorColumn", "", "2d2d2d", "")
    endif
endif

call <SID>X("Search",       "444444",   "ffab4b",   "")
call <SID>X("MatchParen",   "ecee90",   "857b6f",   "bold")
call <SID>X("SpecialKey",   "6c6c6c",   "2d2d2d",   "none")
call <SID>X("Visual",       "", "26512D",   "none")
call <SID>X("LineNr",       "857b6f",   "121212",   "none")
call <SID>X("SignColumn",   "", "121212",   "none")
call <SID>X("Folded",       "a0a8b0",   "404048",   "none")
call <SID>X("Title",        "f6f3e8",   "",         "bold")
call <SID>X("VertSplit",    "444444",   "444444",   "none")
call <SID>X("StatusLine",   "f6f3e8",   "444444",   s:italic)
call <SID>X("StatusLineNC", "857b6f",   "444444",   "none")
call <SID>X("Pmenu",        "f6f3e8",   "444444",   "")
call <SID>X("PmenuSel",     "121212",   "caeb82",   "")
call <SID>X("WarningMsg",   "ff0000",   "",         "")

hi! link VisualNOS  Visual
hi! link FoldColumn Folded
hi! link TabLineSel StatusLine
hi! link TabLineFill StatusLineNC
hi! link TabLine StatusLineNC
call <SID>X("TabLineSel", "f6f3e8", "", "none")

" syntax highlighting
call <SID>X("Comment",      "99968b",   "",         s:italic)

call <SID>X("Constant",     "e5786d",   "",         "none")
call <SID>X("String",       "95e454",   "",         s:italic)
"Character
"Number
"Boolean
"Float

call <SID>X("Identifier",   "caeb82",   "",         "none")
call <SID>X("Function",     "caeb82",   "",         "none")

call <SID>X("Statement",    "87afff",   "",         "none")
"Conditional
"Repeat
"Label
"Operator
call <SID>X("Keyword",      "87afff",   "",         "none")
"Exception

call <SID>X("PreProc",      "e5786d",   "",         "none")
"Include
"Define
"Macro
"PreCondit

call <SID>X("Type",         "caeb82",   "",         "none")
"StorageClass
"Structure
"Typedef

call <SID>X("Special",      "ffdead",   "",         "none")
"SpecialChar
"Tag
"Delimiter
"SpecialComment
"Debug

"Underlined

"Ignore

call <SID>X("Error", "bbbbbb", "aa0000", s:italic)

call <SID>X("Todo", "666666", "aaaa00", s:italic)

" Diff
call <SID>X("DiffAdd", "", "505450", "bold")
call <SID>X("DiffText", "", "673400", "bold")
call <SID>X("DiffDelete", "343434", "101010", "bold")
call <SID>X("DiffChange", "", "53402d", "bold")

" Spellchek
if  version > 700
    " spell, make it underline, and less bright colors. only for terminal
    call <SID>Y("SpellBad", "881000")
    call <SID>Y("SpellCap", "003288")
    call <SID>Y("SpellRare", "73009F")
    call <SID>Y("SpellLocal", "A0CC00")
endif

" Plugins:
" ShowMarks
call <SID>X("ShowMarksHLl", "ab8042", "121212", "bold")
call <SID>X("ShowMarksHLu", "aaab42", "121212", "bold")
call <SID>X("ShowMarksHLo", "42ab47", "121212", "bold")
call <SID>X("ShowMarksHLm", "aaab42", "121212", "bold")

" Syntastic
call <SID>Y("SyntasticError ", "880000")
call <SID>Y("SyntasticWarning", "886600")
call <SID>Y("SyntasticStyleError", "ff6600")
call <SID>Y("SyntasticStyleWarning", "ffaa00")
call <SID>X("SyntasticErrorSign", "", "880000", "")
call <SID>X("SyntasticWarningSign", "", "886600", "")
call <SID>X("SyntasticStyleErrorSign", "", "ff6600", "")
call <SID>X("SyntasticStyleWarningSign", "", "ffaa00", "")

" delete functions {{{
delf <SID>Y
delf <SID>X
delf <SID>rgb
delf <SID>color
delf <SID>rgb_color
delf <SID>rgb_level
delf <SID>rgb_number
delf <SID>get_grey_color_idx
delf s:get_grey_level
delf s:get_approximate_grey_idx
" }}}

" vim:set ts=4 sw=4 sts=4 fdm=marker:
