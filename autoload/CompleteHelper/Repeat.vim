" CompleteHelper/Repeat.vim: Generic functions to support repetition of custom insert mode completions.
"
" DEPENDENCIES:
"   - ingo/text.vim autoload script
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.33.003	18-Dec-2013	Use ingo#text#Get() instead of
"				CompleteHelper#ExtractText().
"   1.11.002	01-Sep-2012	Make a:matchObj in CompleteHelper#ExtractText()
"				optional; it's not used there, anyway.
"   1.00.001	09-Oct-2011	file creation

let s:record = []
let s:startPos = []
let s:lastPos = []
let s:repeatCnt = 0
function! CompleteHelper#Repeat#SetRecord()
    let s:record = s:Record()
endfunction
function! CompleteHelper#Repeat#Clear()
    let s:record = []
endfunction
function! s:Record()
    return [tabpagenr(), winnr(), bufnr(''), b:changedtick, &completefunc] + getpos('.')
endfunction
function! CompleteHelper#Repeat#TestForRepeat()
    augroup CompleteHelperRepeat
	autocmd! CursorMovedI * call CompleteHelper#Repeat#SetRecord() | autocmd! CompleteHelperRepeat
    augroup END

    let l:pos = getpos('.')[1:2]
    if s:record == s:Record()
	let s:repeatCnt += 1
	let l:bpos = [l:pos[0], l:pos[1] - 1]

	let l:addedText = ingo#text#Get(s:lastPos, l:bpos)
	let s:lastPos = l:pos

	let l:fullText = ingo#text#Get(s:startPos, l:bpos)
	return [s:repeatCnt, l:addedText, l:fullText]
    else
	let s:record = []
	let l:base = call(&completefunc, [1, ''])
	let s:startPos = [line('.'), l:base + 1]
	let s:lastPos = s:startPos
	let s:repeatCnt = 0
	return [0, '', '']
    endif
endfunction

function! CompleteHelper#Repeat#Processor( text )
    " Condense a new line and the following indent to a single space to give a
    " continuous completion repeat just like the built-in repeat does.
    let l:textWithoutNewline = substitute(a:text, '^\s*\n\s*', ' ', '')

    if l:textWithoutNewline !=# a:text
	" Because the completion candidate that will be inserted now differs
	" from the original match (there's no newline and indent any more),
	" further repeats wouldn't find any matches.
echomsg '####' string(s:startPos) '->' string(s:lastPos)
	let s:startPos = [s:lastPos[0], s:lastPos[1] + 1]
    endif

    return l:textWithoutNewline
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
