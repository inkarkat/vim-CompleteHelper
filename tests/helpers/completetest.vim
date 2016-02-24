" Use this only if you cannot :set completefunc=FooComplete#FooComplete directly
" (e.g. if it is a script-local function).
function! SetCompletion( completeMapping )
    execute 'normal Go' . a:completeMapping . "\<Esc>"
    normal! Gdd
    set completefunc?
endfunction
function! GetMatchesAtCursor( isAppend, base )
    " Test completion at the current cursor position.
    execute 'normal' (a:isAppend ? 'a' : 'i') . a:base . "\<Esc>"
	if exists('g:SelectBase')
	    execute "normal! vg`[o\<Esc>"
	    execute g:SelectBase
	endif
    let l:col = col('.')

    " Emulate cursor being to the right of the insert position, as in insert
    " mode.
    let l:save_virtualedit = &virtualedit
    set virtualedit=onemore
	normal! l
	let l:startCol = call(&completefunc, [1, ''])
    let &virtualedit = l:save_virtualedit

    let l:line = getline('.')
    let l:endCol = (l:col - l:startCol) + a:isAppend
    let l:base = strpart(l:line, l:startCol, l:endCol)
    " Remove base, as in original completion.
    call setline('.', strpart(l:line, 0, l:startCol) . strpart(l:line, l:endCol))
    let l:completions = call(&completefunc, [0, l:base])
    let l:actualMatches = map(l:completions, 'v:val.word')
"****D echomsg '****' string(l:actualMatches)
    return l:actualMatches
endfunction
function! IsMatchesAtCursor( isAppend, base, expectedMatches, description )
    let l:actualMatches = GetMatchesAtCursor(a:isAppend, a:base)
    call vimtap#collections#IsSet(l:actualMatches, a:expectedMatches, a:description)
endfunction

function! GetMatchesInIsolatedLine( base )
    " Test completion in a temporary empty line at the end of the buffer.
    normal! Go
    let l:actualMatches = GetMatchesAtCursor(1, a:base)
    normal! Gdd
    return l:actualMatches
endfunction
function! IsMatchesInIsolatedLine( base, expectedMatches, description )
    " Test completion in a temporary empty line at the end of the buffer.
    normal! Go
    call IsMatchesAtCursor(1, a:base, a:expectedMatches, a:description)
    normal! Gdd
endfunction

function! GetMatchesInContext( prefix, postfix, base )
    " Test completion in a temporary line at the end of the buffer in the middle
    " of a:prefix and a:postfix.
    call setline(line('$') + 1, a:prefix . a:postfix)
    call cursor(line('$'), len(a:prefix) + 1)
    let l:actualMatches = GetMatchesAtCursor((len(a:postfix) == 0), a:base)
    normal! Gdd
    return l:actualMatches
endfunction
function! IsMatchesInContext( prefix, postfix, base, expectedMatches, description )
    " Test completion in a temporary line at the end of the buffer in the middle
    " of a:prefix and a:postfix.
    call setline(line('$') + 1, a:prefix . a:postfix)
    call cursor(line('$'), len(a:prefix) + 1)
    call IsMatchesAtCursor((len(a:postfix) == 0), a:base, a:expectedMatches, a:description)
    normal! Gdd
endfunction
