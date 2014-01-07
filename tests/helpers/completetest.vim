" Use this only if you cannot :set completefunc=FooComplete#FooComplete directly
" (e.g. if it is a script-local function). 
function! SetCompletion( completeMapping )
    execute 'normal Go' . a:completeMapping . "\<Esc>"
    normal! Gdd
    set completefunc?
endfunction
function! IsMatchesAtCursor( isAppend, base, expectedMatches, description )
    " Test completion at the current cursor position. 
	normal! mz
    execute 'normal' (a:isAppend ? 'a' : 'i') . a:base
	if exists('g:isSelectBase')
	    execute "normal! vg`zo\<Esc>"
	endif
    let l:startCol = call(&completefunc, [1, ''])
    let l:base = strpart(getline('.'), l:startCol, (col('.') - l:startCol) + a:isAppend)
    let l:completions = call(&completefunc, [0, l:base])
    let l:actualMatches = map(l:completions, 'v:val.word')
"****D echomsg '****' string(l:actualMatches)
    call vimtap#collections#IsSet(l:actualMatches, a:expectedMatches, a:description)
endfunction

function! IsMatchesInIsolatedLine( base, expectedMatches, description )
    " Test completion in a temporary empty line at the end of the buffer. 
    normal! Go
    call IsMatchesAtCursor(1, a:base, a:expectedMatches, a:description)
    normal! Gdd
endfunction

function! IsMatchesInContext( prefix, postfix, base, expectedMatches, description )
    " Test completion in a temporary line at the end of the buffer in the middle
    " of a:prefix and a:postfix. 
    call setline(line('$') + 1, a:prefix . a:postfix)
    call cursor(line('$'), len(a:prefix) + 1)
    call IsMatchesAtCursor((len(a:postfix) == 0), a:base, a:expectedMatches, a:description)
    normal! Gdd
endfunction

