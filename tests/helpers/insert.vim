" a:idx	    Use -1 when only one unique match is expected, 0 for the first
"	    match, 1 for the second, etc. 
function! Insert( base, idx )
    stopinsert
    let l:keys = 'a' . a:base . "\<C-x>\<C-c>" . repeat("\<C-n>", a:idx) . (a:idx >= 0 ? "\<C-y>" : '') . ' '
    execute 'normal' l:keys
endfunction

