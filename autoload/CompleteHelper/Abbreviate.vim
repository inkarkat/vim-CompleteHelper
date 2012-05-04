" CompleteHelper/Abbreviate.vim: Utility functions to shorten completion items.
"
" DEPENDENCIES:
"   - EchoWithoutScrolling.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	04-May-2012	file creation from CompleteHelper.vim autoload
"				script

function! s:ListChar( settingFilter, fallback )
    let listchar = matchstr(&listchars, a:settingFilter)
    return (empty(listchar) ? a:fallback : listchar)
endfunction
let s:tabReplacement = s:ListChar('tab:\zs..', '^I')
let s:eolReplacement = s:ListChar('eol:\zs.', '^J') " Vim commands like :reg show newlines as ^J.
delfunction s:ListChar

function! CompleteHelper#Abbreviate#Text( text )
"******************************************************************************
"* PURPOSE:
"   Shorten a:text and change (invisible) <Tab> and newline characters to what's
"   defined in 'listchars'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:text	    Completion match word or menu.
"* RETURN VALUES:
"   Potentially shortened text.
"******************************************************************************
    let l:text = substitute(a:text, '\t', s:tabReplacement, 'g')
    let l:text = substitute(l:text, "\n", s:eolReplacement, 'g')

    let l:maxDisplayLen = &columns / 2
    return (len(l:text) > l:maxDisplayLen ? EchoWithoutScrolling#TruncateTo(l:text, l:maxDisplayLen) : l:text)
endfunction

function! CompleteHelper#Abbreviate#Word( matchObj )
"******************************************************************************
"* PURPOSE:
"   Shorten the match abbreviation and change (invisible) <Tab> and newline
"   characters to what's defined in 'listchars'.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:matchObj	    The match object to be returned to the completion function.
"* RETURN VALUES:
"   Extended match object with 'abbr' attribute.
"******************************************************************************
    let l:abbr = CompleteHelper#Abbreviate#Text(a:matchObj.word)
    if l:abbr !=# a:matchObj.word
	let a:matchObj.abbr = l:abbr
    endif
    return a:matchObj
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
