function! SetCompletion( completeMapping )
    let l:save_cursor = getpos('.')
    execute 'normal Go' . a:completeMapping . "\<Esc>"
    normal! dd
    call setpos('.', l:save_cursor)

    set completefunc?
endfunction
function! IsMatches( base, expectedMatches, description )
    execute 'normal i' . a:base . (exists('g:completeMapping') ? g:completeMapping : "\<C-x>\<C-u>") . "\<Esc>"
    let l:completions = call(&completefunc, [0, a:base])
    let l:actualMatches = map(l:completions, 'v:val.word')
    call vimtap#collections#IsSet(l:actualMatches, a:expectedMatches, a:description)
endfunction

