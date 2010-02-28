function! SetCompletion( completeMapping )
    execute 'normal Go' . a:completeMapping . "\<Esc>"
    normal! Gdd
    set completefunc?
endfunction
function! IsMatchesAtCursor( isAppend, base, expectedMatches, description )
    " Test completion at the current cursor position. 
    execute 'normal' (a:isAppend ? 'a' : 'i') . a:base . (exists('g:completeMapping') ? g:completeMapping : "\<C-x>\<C-u>") . "\<Esc>"
    let l:completions = call(&completefunc, [0, a:base])
    let l:actualMatches = map(l:completions, 'v:val.word')

    " Always do a case-insensitive comparison. 
    let l:save_ignorecase = &ignorecase
    set noignorecase
    call vimtap#collections#IsSet(l:actualMatches, a:expectedMatches, a:description)
    let &ignorecase = l:save_ignorecase
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

