let s:completeMapping = "\<C-x>\<C-u>"
function! SetCompletion( completeMapping )
    let s:completeMapping = a:completeMapping
endfunction

" a:idx	    Use -1 to cancel completion, 0 when only one unique match is
"	    expected, 1 for the first match, 2 for the second, etc.
function! s:CompletionKeys( idx )
    return s:completeMapping . repeat("\<C-n>", (a:idx - 1)) . (a:idx == -1 ? "\<C-e>" : '') . (a:idx > 0 ? "\<C-y>" : '')
endfunction
function! Insert( base, idx )
    stopinsert
    let l:keys = 'a' . a:base . s:CompletionKeys(a:idx) . ' '
    execute 'normal' l:keys
endfunction
function! InsertRepeat( base, ... )
    stopinsert
    let l:base = a:base

    for l:idx in a:000
	let l:keys = 'a' . l:base . s:CompletionKeys(l:idx) . "\<Esc>"
	let l:base = ''
	execute 'normal' l:keys

	" XXX: Somehow, CompleteHelper's CursorMovedI autocmd isn't fired; we
	" need to do this ourselves.
	let l:save_virtualedit=&virtualedit
	set virtualedit=onemore
	    normal! l
		call CompleteHelper#Repeat#SetRecord()
	    normal! h
	let &virtualedit = l:save_virtualedit
    endfor
    execute "normal! o\<Esc>"
endfunction
