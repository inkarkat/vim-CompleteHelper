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
" Copyright: (C) 2008-2010 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	008	04-Mar-2010	Collapse multiple lines consisting of only
"				whitespace and a newline into a single space,
"				not one space per line. 
"	007	25-Jun-2009	Now using :noautocmd to avoid unnecessary
"				processing while searching other windows. 
"	006	09-Jun-2009	Do not include a match ending at the cursor
"				position when finding completions in the buffer
"				where the completion is undertaken. 
"				Vim would not offer this anyway, and this way it
"				feels cleaner and does not confuse unit tests.
"				Such a match can happen if a:base =~ a:pattern. 
"	005	03-Mar-2009	Now restoring window sizes in
"				s:FindMatchesInOtherWindows() to avoid
"				increating window height from 0 to 1. 
"	004	19-Aug-2008	Initial matchObj is now passed to text extractor
"				function. 
"	003	18-Aug-2008	Added a:options.multiline; default is to
"				collapse newline and surrounding whitespace into
"				a single <Space>. 
"	002	17-Aug-2008	BF: Check for match not yet in the list still
"				used match text, not object. 
"	001	13-Aug-2008	file creation

function! CompleteHelper#ExtractText( startPos, endPos, matchObj )
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
"   a:matchObj	    The match object to be returned to the completion function. 
"		    This function does not need to set anything there, the
"		    mandatory matchObj.word will be set from this function's
"		    return value automatically (and with additional processing).
"		    However, you _can_ modify other items if you deem necessary.
"		    (E.g. add a note to matchObj.menu that the text was
"		    truncated.) 
"* RETURN VALUES: 
"   string text; return an empty string to signal that no match should be added
"   to the list of matches. 
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
function! s:FindMatchesInCurrentWindow( matches, pattern, matchTemplate, options, isInCompletionBuffer )
    let l:isBackward = has_key(a:options, 'backward_search')

    let l:save_cursor = getpos('.')

    let l:firstMatchPos = [0,0]
    while ! complete_check()
	let l:matchPos = searchpos( a:pattern, 'w' . (l:isBackward ? 'b' : '') )
	if l:matchPos == [0,0] || l:matchPos == l:firstMatchPos
	    " Stop when no matches or wrapped around to first match. 
	    break
	endif
	if l:firstMatchPos == [0,0]
	    " Record first match position to detect wrap-around. 
	    let l:firstMatchPos = l:matchPos
	endif

	let l:matchEndPos = searchpos( a:pattern, 'cen' )
	if a:isInCompletionBuffer && (l:matchEndPos == l:save_cursor[1:2])
	    " Do not include a match ending at the cursor position; this is just
	    " the completion base, and Vim would not offer this anyway. Such a
	    " match can happen if a:base =~ a:pattern. 
	    continue
	endif

	" Initialize the match object and extract the match text. 
	let l:matchObj = copy(a:matchTemplate)
	let l:matchText = (has_key(a:options, 'extractor') ? a:options.extractor(l:matchPos, l:matchEndPos, l:matchObj) : CompleteHelper#ExtractText(l:matchPos, l:matchEndPos, l:matchObj))

	" Process multi-line matches. 
	if stridx( l:matchText, "\n") != -1
	    " Insert mode completion cannot complete multiple lines, so the
	    " default is to replace newline(s) plus any surrounding whitespace
	    " with a single <Space>. 
	    let l:matchText = (has_key(a:options, 'multiline') ? a:options.multiline(l:matchText) : substitute(l:matchText, "\\%(\\s*\n\\)\\+\\s*", ' ', 'g'))
	endif

	" Store match text in match object. 
	let l:matchObj.word = l:matchText

	" Only add if this is an actual match that is not yet in the list of
	" matches. 
	if ! empty(l:matchText) && index(a:matches, l:matchObj) == -1
	    call add( a:matches, l:matchObj )
	endif
"****D echomsg '**** match from' string(l:matchPos) 'to' string(l:matchEndPos) l:matchText
    endwhile
    
    call setpos('.', l:save_cursor)
endfunction
function! s:FindMatchesInOtherWindows( matches, pattern, options )
    let l:searchedBuffers = { bufnr('') : 1 }
    let l:originalWinNr = winnr()

    " By entering a window, its height is potentially increased from 0 to 1 (the
    " minimum for the current window). To avoid any modification, save the window
    " sizes and restore them after visiting all windows. 
    let l:originalWindowLayout = winrestcmd()

    for l:winNr in range(1, winnr('$'))
	execute 'noautocmd' l:winNr . 'wincmd w'

	let l:matchTemplate = { 'menu': bufname('') }

	if ! has_key( l:searchedBuffers, bufnr('') )
	    call s:FindMatchesInCurrentWindow( a:matches, a:pattern, l:matchTemplate, a:options, 0 )
	    let l:searchedBuffers[ bufnr('') ] = 1
	endif
    endfor

    execute 'noautocmd' l:originalWinNr . 'wincmd w'
    silent! execute l:originalWindowLayout
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
"		Note: In the buffer where the completion takes place, Vim
"		temporarily removes the a:base part (as passed to the
"		complete-function) during the completion. This helps avoiding
"		that the text directly after the cursor also matches a:pattern
"		(assuming something like '\<'.a:base.'\k\+') and appears in the
"		list. 
"		Note: Matching is done via the searchpos() function, so the
"		'ignorecase' and 'smartcase' settings apply. Add |/\c| / |/\C|
"		to the regexp to set the case sensitivity. 
"   a:options	Dictionary with match configuration:
"   a:options.complete	    Specifies what is searched, like the 'complete'
"			    option. Supported options: '.' for current buffer, 
"			    'w' for buffers from other windows. 
"   a:options.backward_search	Flag whether to search backwards from the cursor
"				position. 
"   a:options.extractor	    Function reference that extracts the matched text
"			    from the current buffer. Will be invoked with
"			    ([startLine, startCol], [endLine, endCol], matchObj)
"			    arguments with the cursor positioned at the start of
"			    the current match; must return string; can modify
"			    the initial matchObj. 
"   a:options.multiline	    Function reference that processes multiline matches,
"			    as insert mode completion cannot complete multiple
"			    lines. Will be invoked with (matchText) argument;
"			    must return processed string. 
"* RETURN VALUES: 
"   a:matches
"*******************************************************************************
    let l:complete = get(a:options, 'complete', '')
    for l:places in split(l:complete, ',')
	if l:places == '.'
	    call s:FindMatchesInCurrentWindow( a:matches, a:pattern, {}, a:options, 1 )
	elseif l:places == 'w'
	    call s:FindMatchesInOtherWindows( a:matches, a:pattern, a:options )
	endif
    endfor
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
