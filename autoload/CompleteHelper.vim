" TODO: summary
"
" DESCRIPTION:
" USAGE:
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2008 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	13-Aug-2008	file creation

function! CompleteHelper#ExtractText( startPos, endPos )
    let [l:line, l:column] = a:startPos
    let [l:endLine, l:endColumn] = a:endPos
    if l:line > l:endLine || (l:line == l:endLine && l:column > l:endColumn)
	return ''
    endif

    let l:text = ''
    while 1
	if l:line == l:endLine
	    let l:text .= matchstr( getline(l:line) . "\n", '\%' . l:column . 'c' . '.*\%' . (l:endColumn + 1) . 'c' )
	    break
	else
	    let l:text .= matchstr( getline(l:line) . "\n", '\%' . l:column . 'c' . '.*' )
	    let l:line += 1
	    let l:column = 1
	endif
    endwhile
    return l:text
endfunction
function! CompleteHelper#FindMatches( pattern, isBackward )
    let l:save_cursor = getpos('.')
    let l:matches = []

    let l:firstMatchPos = [0,0]
    while 1
	let l:matchPos = searchpos( a:pattern, 'w' . (a:isBackward ? 'b' : '') )
	if l:matchPos == [0,0] || l:matchPos == l:firstMatchPos
	    " Stop when no matches or wrapped around to first match. 
	    break
	endif
	let l:matchEndPos = searchpos( a:pattern, 'cen' )
	let l:matchText = CompleteHelper#ExtractText(l:matchPos, l:matchEndPos)
	" Insert mode completion cannot complete multiple lines, so join
	" multi-line matches together with spaces, like the 'J' command. 
	let l:matchText = substitute( l:matchText, "\n", (&joinspaces ? '  ' : ' '), 'g' )
	if index(l:matches, l:matchText) == -1
	    call add(l:matches, {'word': l:matchText})
	endif
"****D echomsg '**** match from' string(l:matchPos) 'to' string(l:matchEndPos) l:matchText

	if l:firstMatchPos == [0,0]
	    " Record first match position to detect wrap-around. 
	    let l:firstMatchPos = l:matchPos
	endif
    endwhile
    
    call setpos('.', l:save_cursor)
    return l:matches
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
