let s:completeMapping = "\<C-x>\<C-u>"
function! SetCompletion( completeMapping )
    unlet s:completeMapping
    let s:completeMapping = a:completeMapping
endfunction

" a:idx	    Use -1 to cancel completion, 0 when only one unique match is
"	    expected, 1 for the first match, 2 for the second, etc.
function! s:CompletionKeys( idx, ... )
    if type(s:completeMapping) == type([])
	let l:completeMapping = s:completeMapping[(len(s:completeMapping) > 1 && a:0 && ! a:1 ? 1 : 0)]
    else
	let l:completeMapping = s:completeMapping
    endif

    return l:completeMapping . repeat("\<C-n>", (a:idx - 1)) . (a:idx == -1 ? "\<C-e>" : '') . (a:idx > 0 ? "\<C-y>" : '')
endfunction
function! Insert( base, idx )
    stopinsert
    let l:keys = 'a' . a:base . s:CompletionKeys(a:idx) . ' '
    execute 'normal' l:keys
endfunction
function! InsertRepeat( base, ... )
    stopinsert
    execute 'normal! a' . a:base . "\<Esc>"

    " XXX: Somehow, CompleteHelper's CursorMovedI autocmd isn't fired; we need
    " to do this ourselves, first to set the record at the start of the base.
    let l:save_virtualedit=&virtualedit
    set virtualedit=onemore
	let l:save_cursor = getpos('.')
	normal! l
	    call InnerFragmentComplete#Expr()
	    let l:startCol = call(&completefunc, [1, ''])
	    call cursor(0, l:startCol + 1)
	    call CompleteHelper#Repeat#SetRecord()
	call setpos('.', l:save_cursor)
    let &virtualedit = l:save_virtualedit


    let l:isFirst = 1
    for l:idx in a:000
	let l:keys = 'a' . s:CompletionKeys(l:idx, l:isFirst) . "\<Esc>"
	execute 'normal' l:keys
	let l:isFirst = 0

	" XXX: Somehow, CompleteHelper's CursorMovedI autocmd isn't fired; we
	" need to do this ourselves, now to set the record after completion.
	let l:save_virtualedit=&virtualedit
	set virtualedit=onemore
	    normal! l
		call CompleteHelper#Repeat#SetRecord()
	    normal! h
	let &virtualedit = l:save_virtualedit
    endfor
    execute "normal! o\<Esc>"
endfunction
