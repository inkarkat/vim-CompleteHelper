" CompleteHelper.vim: Generic functions to support custom insert mode completions. 
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
"*******************************************************************************
"* PURPOSE:
"   Extract the text between a:startPos and a:endPos from the current buffer. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:startPos	    [line,col]
"   a:endPos	    [line,col]
"* RETURN VALUES: 
"   string text
"*******************************************************************************
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
function! s:FindMatchesInCurrentWindow( matches, pattern, matchTemplate, options )
    let l:isBackward = has_key(a:options, 'backward_search')

    let l:save_cursor = getpos('.')

    let l:firstMatchPos = [0,0]
    while ! complete_check()
	let l:matchPos = searchpos( a:pattern, 'w' . (l:isBackward ? 'b' : '') )
	if l:matchPos == [0,0] || l:matchPos == l:firstMatchPos
	    " Stop when no matches or wrapped around to first match. 
	    break
	endif
	let l:matchEndPos = searchpos( a:pattern, 'cen' )
	let l:matchText = (has_key(a:options, 'extractor') ? a:options.extractor(l:matchPos, l:matchEndPos) : CompleteHelper#ExtractText(l:matchPos, l:matchEndPos))
	" Insert mode completion cannot complete multiple lines, so join
	" multi-line matches together with spaces, like the 'J' command. 
	let l:matchText = substitute( l:matchText, "\n", (&joinspaces ? '  ' : ' '), 'g' )
	if index(a:matches, l:matchText) == -1
	    let l:matchObj = copy(a:matchTemplate)
	    let l:matchObj.word = l:matchText
	    call add( a:matches, l:matchObj )
	endif
"****D echomsg '**** match from' string(l:matchPos) 'to' string(l:matchEndPos) l:matchText

	if l:firstMatchPos == [0,0]
	    " Record first match position to detect wrap-around. 
	    let l:firstMatchPos = l:matchPos
	endif
    endwhile
    
    call setpos('.', l:save_cursor)
endfunction
function! s:FindMatchesInOtherWindows( matches, pattern, options )
    let l:searchedBuffers = { bufnr('') : 1 }
    let l:originalWinNr = winnr()

    for l:winNr in range(1, winnr('$'))
	execute l:winNr 'wincmd w'

	let l:matchTemplate = { 'menu': bufname('') }

	if ! has_key( l:searchedBuffers, bufnr('') )
	    call s:FindMatchesInCurrentWindow( a:matches, a:pattern, l:matchTemplate, a:options )
	    let l:searchedBuffers[ bufnr('') ] = 1
	endif
    endfor

    execute l:originalWinNr 'wincmd w'
endfunction
function! CompleteHelper#FindMatches( matches, pattern, options )
"*******************************************************************************
"* PURPOSE:
"   Find matches for a:pattern according to a:options and store them in
"   a:matches. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   none
"* INPUTS:
"   a:matches	(Empty) List that will hold the matches (in Dictionary format,
"		cp. :help complete-functions). Matches will be appended. 
"   a:pattern	Regular expression specifying what text will match as a
"		completion candidate. 
"   a:options	Dictionary with match configuration:
"   a:options.complete	    Specifies what is searched, like the 'complete'
"			    option. Supported options: '.' for current buffer, 
"			    'w' for buffers from other windows. 
"   a:options.backward_search	Flag whether to search backwards from the cursor
"				position. 
"   a:options.extractor	    Function reference that extracts the matched text
"			    from the current buffer. Will be invoked with
"			    ([startLine, startCol], [endLine, endCol])
"			    arguments; must return string. 
"* RETURN VALUES: 
"   a:matches
"*******************************************************************************
    let l:complete = get(a:options, 'complete', '')
    for l:places in split(l:complete, ',')
	if l:places == '.'
	    call s:FindMatchesInCurrentWindow( a:matches, a:pattern, {}, a:options )
	elseif l:places == 'w'
	    call s:FindMatchesInOtherWindows( a:matches, a:pattern, a:options )
	endif
    endfor
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
