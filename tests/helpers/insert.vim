let s:completeMapping = "\<C-x>\<C-u>"
function! SetCompletion( completeMapping )
    let s:completeMapping = a:completeMapping
endfunction
let s:completeExpr = ''
function! SetCompleteExpr( completeExpr )
    unlet s:completeExpr
    let s:completeExpr = a:completeExpr
endfunction

" a:idx	    Use -1 to cancel completion, 0 when only one unique match is
"	    expected, 1 for the first match, 2 for the second, etc.
function! s:CompletionKeys( idx )
    " XXX: Cannot use <C-n> since Vim 8.0.1482: "using feedkeys() does not work
    " to test completion". Fortunately, <Down> is a suitable replacement?!
    return s:completeMapping . repeat("\<Down>", (a:idx - 1)) . (a:idx == -1 ? "\<C-e>" : '') . (a:idx > 0 ? "\<C-y>" : '')
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
	    if empty(s:completeExpr) | throw "Invoke SetCompleteExpr('MyComplete#Expr') before InsertRepeat()" | endif
	    if type(s:completeExpr) == type(function('tr')) || s:completeExpr !~# '(.*)'
		call call(s:completeExpr, [])
	    else
		execute 'call' s:completeExpr
	    endif

	    let l:startCol = call(&completefunc, [1, ''])
	    call cursor(0, l:startCol + 1)
	    call CompleteHelper#Repeat#SetRecord()
	call setpos('.', l:save_cursor)
    let &virtualedit = l:save_virtualedit


    for l:idx in a:000
	let l:keys = 'a' . s:CompletionKeys(l:idx) . "\<Esc>"
	execute 'normal' l:keys

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
