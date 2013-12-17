let s:completeMapping = "\<C-x>\<C-u>"
function! SetCompletion( completeMapping )
    let s:completeMapping = a:completeMapping
endfunction

" a:idx	    Use -1 to cancel completion, 0 when only one unique match is
"	    expected, 1 for the first match, 2 for the second, etc. 
function! Insert( base, idx )
    stopinsert
    let l:keys = 'a' . a:base . s:completeMapping . repeat("\<C-n>", (a:idx - 1)) . (a:idx == -1 ? "\<C-e>" : '') . (a:idx > 0 ? "\<C-y>" : '') . ' '
    execute 'normal' l:keys
endfunction

