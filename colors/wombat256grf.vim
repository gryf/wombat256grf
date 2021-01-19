" Vim color file
" Maintainer: Roman 'gryf' Dobosz
" Last Change: 2021-01-19
"
" wombat256grf.vim - a heavily modified version of Wombat by Lars Nielsen (at 
" al) that also works on xterms with 256 colors. Instead of hard coding colors 
" for the terminal, algorithm for approximating the GUI colors with the xterm 
" palette was used.
" Approximation function was taken from desert256.vim by Henry So Jr.

set background=dark

if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let g:colors_name = "wombat256grf"

" Run this colorscheme only for Gvim or vim in terminal which support 256 
" colors.
if !has("gui_running") && &t_Co != 256
    finish
endif

" Italic only in gui and only where font is not fixed-misc.
let s:italic = "none"
if has("gui_running") && &guifont !~ "Fixed"
    let s:italic = "italic"
endif

" functions {{{
" Returns an approximate grey index for the given grey level.
fun s:get_approximate_grey_idx(x)
    if a:x < 14
        return 0
    endif
    let l:n = (a:x - 8) / 10
    let l:m = (a:x - 8) % 10
    if l:m < 5
        return l:n
    endif
    return l:n + 1
endfun

" Returns the actual grey level represented by the grey index.
fun s:get_grey_level(n)
    return a:n == 0 ? 0 : 8 + (a:n * 10)
endfun

" Returns the palette index for the given grey index.
fun s:get_grey_color_idx(n)
    let l:grey_map = {0: 16, 25: 231}
    let l:default = 231 + a:n

    return get(l:grey_map, a:n, l:default)
endfun

" Returns an approximate color index for the given color level.
fun s:get_approximate_rgb_idx(x)
    if a:x < 75
        return 0
    endif

    let l:n = (a:x - 55) / 40
    let l:m = (a:x - 55) % 40
    if l:m < 20
        return l:n
    endif
    return l:n + 1
endfun

" Returns the actual color level for the given color index.
fun s:get_rgb_level(n)
    return a:n == 0 ? 0 : 55 + (a:n * 40)
endfun

" Returns the palette index for the given R/G/B color indices.
fun s:get_rgb_idx(x, y, z)
    return 16 + (a:x * 36) + (a:y * 6) + a:z
endfun

" Returns the palette index to approximate the given R/G/B color levels.
fun s:get_color(r, g, b)
    " get the closest grey
    let l:gx = s:get_approximate_grey_idx(a:r)
    let l:gy = s:get_approximate_grey_idx(a:g)
    let l:gz = s:get_approximate_grey_idx(a:b)

    " get the closest color
    let l:x = s:get_approximate_rgb_idx(a:r)
    let l:y = s:get_approximate_rgb_idx(a:g)
    let l:z = s:get_approximate_rgb_idx(a:b)

    if l:gx == l:gy && l:gy == l:gz
        " there are two possibilities
        let l:dgr = s:get_grey_level(l:gx) - a:r
        let l:dgg = s:get_grey_level(l:gy) - a:g
        let l:dgb = s:get_grey_level(l:gz) - a:b
        let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
        let l:dr = s:get_rgb_level(l:gx) - a:r
        let l:dg = s:get_rgb_level(l:gy) - a:g
        let l:db = s:get_rgb_level(l:gz) - a:b
        let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
        if l:dgrey < l:drgb
            " use the grey
            return s:get_grey_color_idx(l:gx)
        endif
        " use the color
        return s:get_rgb_idx(l:x, l:y, l:z)
    endif
    " only one possibility
    return s:get_rgb_idx(l:x, l:y, l:z)
endfun

" Returns the palette index to approximate the 'rrggbb' hex string.
fun s:get_rgb_as_index(rgb)
    let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
    let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
    let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
    return s:get_color(l:r, l:g, l:b)
endfun

" Sets the highlighting for the given group. 
fun s:highlight(group, fg, bg, attr)
    let l:cmd = "highlight " . a:group
    if a:fg != ""
        let l:cmd .= " guifg=#" . a:fg . " ctermfg=" . s:get_rgb_as_index(a:fg)
    endif
    if a:bg != ""
        let l:cmd .= " guibg=#" . a:bg . " ctermbg=" . s:get_rgb_as_index(a:bg)
    endif
    if a:attr != ""
        if a:attr == 'italic'
            let l:cmd .= " gui=" . a:attr . " cterm=none"
        else
            let l:cmd .= " gui=". a:attr. " cterm=" . a:attr
        endif
    endif
    exec l:cmd
endfun

" same as above, but makes it for the spell-like things
fun s:undercurl(group, bg)
    if a:bg != ""
        if ! has('gui_running')
            exec "highlight " . a:group . " ctermbg=" .
                        \s:get_rgb_as_index(a:bg)
        else
            exec "highlight " . a:group . " guisp=#" . a:bg . " gui=undercurl"
        endif
    endif
endfun
" }}}

" Colors {{{
" non-syntax items, interface, etc
call s:highlight("Normal",       "dddddd",   "242424",   "none")
call s:highlight("NonText",      "4c4c36",   "",         "none")
call s:highlight("Cursor",       "222222",   "ecee90",   "none")

if version > 700
    call s:highlight("CursorLine",   "", "32322e",   "none")
    hi link CursorColumn CursorLine
    if version > 703
        call s:highlight("ColorColumn", "", "2d2d2d", "")
    endif
endif

call s:highlight("Search",       "444444",   "ffab4b",   "")
call s:highlight("MatchParen",   "ecee90",   "857b6f",   "bold")
call s:highlight("SpecialKey",   "6c6c6c",   "2d2d2d",   "none")
call s:highlight("Visual",       "", "26512D",   "none")
call s:highlight("LineNr",       "857b6f",   "121212",   "none")
call s:highlight("SignColumn",   "", "121212",   "none")
call s:highlight("Folded",       "a0a8b0",   "404048",   "none")
call s:highlight("Title",        "f6f3e8",   "",         "bold")
call s:highlight("VertSplit",    "444444",   "444444",   "none")
call s:highlight("StatusLine",   "f6f3e8",   "444444",   s:italic)
call s:highlight("StatusLineNC", "857b6f",   "444444",   "none")
call s:highlight("Pmenu",        "f6f3e8",   "444444",   "")
call s:highlight("PmenuSel",     "121212",   "caeb82",   "")
call s:highlight("WarningMsg",   "ff0000",   "",         "")

hi! link VisualNOS  Visual
hi! link FoldColumn Folded
hi! link TabLineSel StatusLine
hi! link TabLineFill StatusLineNC
hi! link TabLine StatusLineNC
call s:highlight("TabLineSel", "f6f3e8", "", "none")

" syntax highlighting
call s:highlight("Comment",      "99968b",   "",         s:italic)

call s:highlight("Constant",     "e5786d",   "",         "none")
call s:highlight("String",       "95e454",   "",         s:italic)
"Character
"Number
"Boolean
"Float

call s:highlight("Identifier",   "caeb82",   "",         "none")
call s:highlight("Function",     "caeb82",   "",         "none")

call s:highlight("Statement",    "87afff",   "",         "none")
"Conditional
"Repeat
"Label
"Operator
call s:highlight("Keyword",      "87afff",   "",         "none")
"Exception

call s:highlight("PreProc",      "e5786d",   "",         "none")
"Include
"Define
"Macro
"PreCondit

call s:highlight("Type",         "caeb82",   "",         "none")
"StorageClass
"Structure
"Typedef

call s:highlight("Special",      "ffdead",   "",         "none")
"SpecialChar
"Tag
"Delimiter
"SpecialComment
"Debug

"Underlined

"Ignore

call s:highlight("Error", "bbbbbb", "aa0000", s:italic)

call s:highlight("Todo", "666666", "aaaa00", s:italic)

" Diff
call s:highlight("DiffAdd", "", "505450", "bold")
call s:highlight("DiffText", "", "673400", "bold")
call s:highlight("DiffDelete", "343434", "101010", "bold")
call s:highlight("DiffChange", "", "53402d", "bold")

" Spellchek
if  version > 700
    " spell, make it underline, and less bright colors. only for terminal
    call s:undercurl("SpellBad", "881000")
    call s:undercurl("SpellCap", "003288")
    call s:undercurl("SpellRare", "73009F")
    call s:undercurl("SpellLocal", "A0CC00")
endif

" Plugins:
" ShowMarks
call s:highlight("ShowMarksHLl", "ab8042", "121212", "bold")
call s:highlight("ShowMarksHLu", "aaab42", "121212", "bold")
call s:highlight("ShowMarksHLo", "42ab47", "121212", "bold")
call s:highlight("ShowMarksHLm", "aaab42", "121212", "bold")

" Syntastic
call s:undercurl("SyntasticError ", "880000")
call s:undercurl("SyntasticWarning", "886600")
call s:undercurl("SyntasticStyleError", "ff6600")
call s:undercurl("SyntasticStyleWarning", "ffaa00")
call s:highlight("SyntasticErrorSign", "", "880000", "")
call s:highlight("SyntasticWarningSign", "", "886600", "")
call s:highlight("SyntasticStyleErrorSign", "", "ff6600", "")
call s:highlight("SyntasticStyleWarningSign", "", "ffaa00", "")
" }}}

" delete functions {{{
delf s:undercurl
delf s:highlight
delf s:get_rgb_as_index
delf s:get_color
delf s:get_rgb_idx
delf s:get_rgb_level
delf s:get_approximate_rgb_idx
delf s:get_grey_color_idx
delf s:get_grey_level
delf s:get_approximate_grey_idx
" }}}

" vim:set ts=4 sw=4 sts=4 fdm=marker:
