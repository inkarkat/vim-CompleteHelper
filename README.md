COMPLETE HELPER   
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

Via 'completefunc' and the i\_CTRL-X\_CTRL-U command, it is possible to define
custom complete-functions. To write extensions or alternatives to the
built-in completion functions, you often need to derive the completion
candidates from Vim's buffers and windows. This plugin offers generic
functions around extraction and handling of completion matches (something that
Vim doesn't yet expose to Vimscript), so that building your own custom
completion is quick and simple.

### SEE ALSO

The following custom completions use this plugin:

- AlphaComplete.vim ([vimscript #4912](http://www.vim.org/scripts/script.php?script_id=4912)):
  Completes any sequence of alphabetic characters.
- BidiComplete.vim ([vimscript #4658](http://www.vim.org/scripts/script.php?script_id=4658)):
  Considers text before AND AFTER the cursor.
- CamelCaseComplete.vim ([vimscript #3915](http://www.vim.org/scripts/script.php?script_id=3915)):
  Expands CamelCaseWords and underscore\_words based on anchor characters for
  each word fragment.
- EntryComplete.vim ([vimscript #5073](http://www.vim.org/scripts/script.php?script_id=5073)):
  Completes whole lines from designated files or buffers.
- InnerFragmentComplete.vim ([vimscript #4804](http://www.vim.org/scripts/script.php?script_id=4804)):
  Completes (and expands CamelCaseWord) fragments inside words.
- LineComplete.vim ([vimscript #4911](http://www.vim.org/scripts/script.php?script_id=4911)):
  Completes entire lines with looser matching that the built-in
  i\_CTRL-X\_CTRL-L.
- MotionComplete.vim ([vimscript #4265](http://www.vim.org/scripts/script.php?script_id=4265)):
  Completes a chunk covered by queried {motion} or text object.
  - BracketComplete.vim ([vimscript #4266](http://www.vim.org/scripts/script.php?script_id=4266)):
    Completes text inside various brackets.
  - LineEndComplete.vim ([vimscript #4267](http://www.vim.org/scripts/script.php?script_id=4267)):
    Completes the rest of the line.
- MultiWordComplete.vim ([vimscript #4805](http://www.vim.org/scripts/script.php?script_id=4805)):
  Completes a sequence of words based on anchor characters for each word.
- PatternComplete.vim ([vimscript #4248](http://www.vim.org/scripts/script.php?script_id=4248)):
  Completes matches of queried {pattern} or last search pattern.
- PrevInsertComplete.vim ([vimscript #4185](http://www.vim.org/scripts/script.php?script_id=4185)):
  Recall and insert mode completion for previously inserted text.
- SameFiletypeComplete.vim ([vimscript #4242](http://www.vim.org/scripts/script.php?script_id=4242)):
  Completion from buffers with the same filetype.
- SnippetComplete.vim ([vimscript #2926](http://www.vim.org/scripts/script.php?script_id=2926)):
  Completes defined abbreviations and other snippets.
- SpecialLocationComplete.vim ([vimscript #5120](http://www.vim.org/scripts/script.php?script_id=5120)):
  Completes special, configurable custom patterns.
- WORDComplete.vim ([vimscript #5613](http://www.vim.org/scripts/script.php?script_id=5613)):
  Completes an entire sequence of non-blank characters.

### RELATED WORKS

- Mark Weber's vim-addon-completion library
  (https://github.com/MarcWeber/vim-addon-completion) has some functions to
  switch between completions and to do CamelCase matching.

USAGE
------------------------------------------------------------------------------

    The options.complete attribute specifies what is searched, like the 'complete'
    option for built-in completions. The following (comma-separated) option values
    are currently supported:
        - "." current buffer
        - "w" buffers from other windows
        - "b" other loaded buffers that are in the buffer list
        - "u" unloaded buffers that are in the buffer list
        - "U" buffers that are not in the buffer list

    This plugin defines several functions. The following is an overview; you'll
    find the details directly in the implementation files in the .vim/autoload/
    directory.

    CompleteHelper#FindMatches( matches, pattern, options )

    The main helper function that finds all matches of a:pattern in buffers
    specified by a:options, and returns them in the List a:matches that can be
    returned as-is to Vim.

    CompleteHelper#Find( matches, Funcref, options )

    A generic alternative that doesn't prescribe using a regular expression match.
    Instead, a Funcref is passed to find and extract matches, reusing the window
    and buffer iteration functionality provided by this plugin.

    CompleteHelper#ExtractText( startPos, endPos, matchObj )

    Low-level function for extracting text from the current buffer. This is the
    default extractor used by CompleteHelper#FindMatches().

    CompleteHelper#Abbreviate#Word( matchObj )

    Processes the match objects to make them prettier to display. Usually
    |map()|ed over the matches returned from CompleteHelper#FindMatches().

    CompleteHelper#JoinMultiline( text )

    Can be used in CompleteHelper#FindMatches()'s a:options.processor if you want
    to flatten multi-line matches, as the current default behavior of Vim is not
    what users expect. (Newlines are inserted literally as ^@.)

    CompleteHelper#Repeat#TestForRepeat()

    Some built-in completions support the repetition of a completion, so that
    subsequent words from the completion source are appended. This function allows
    to implement such a repetition for custom completions, too.

### DEBUGGING

    To help you with developing your own plugins, you can make the plugin save the
    last used pattern(s) in a global variable, if it is defined:
        :let g:CompleteHelper_DebugPatterns = []
        " Trigger custom completion.
        :echo g:CompleteHelper_DebugPatterns

EXAMPLE
------------------------------------------------------------------------------

Here is a simple completion that completes the keywords in front of the cursor
from the current file, like the built-in compl-current does. From the
completion base, it constructs a regexp matching all keywords that start with
the base, and delegates the entire work of finding the matches and building
the appropriate match objects to CompleteHelper#FindMatches().
>
    function! SimpleComplete( findstart, base )
        if a:findstart
            " Locate the start of the keyword.
            let l:startCol = searchpos('\k*\%#', 'bn', line('.'))[1]
            if l:startCol == 0
                let l:startCol = col('.')
            endif
            return l:startCol - 1 " Return byte index, not column.
        else
            " Find matches starting with a:base.
            let l:matches = []
            call CompleteHelper#FindMatches( l:matches, '\V\<' . escape(a:base, '\') . '\k\+', {'complete': '.'} )
            return l:matches
        endif
    endfunction

    inoremap <C-x><C-z> <C-o>:set completefunc=SimpleComplete<CR><C-x><C-u>

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-CompleteHelper
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim CompleteHelper*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.028 or
  higher.

### CONFIGURATION

For a permanent configuration, put the following commands into your vimrc:

When no a:options.backward\_search is passed to CompleteHelper#FindMatches(),
it defaults to backwards search, as this offers recent / preceding matches
(which are likier to be recalled) first. If you don't want that, either
explicitly pass the a:options.backward\_search flag (especially do this if you
offer both backward and forward matching mappings), or globally revert to the
previous behavior via:

    let g:CompleteHelper_IsDefaultToBackwardSearch = 0

LIMITATIONS
------------------------------------------------------------------------------

- Only the '.' (current buffer), 'w' (other windows), and 'b' (other listed
  buffers) values (the last one with limitations) of 'complete'
  are currently implemented.
- As the searched buffers need to be either displayed in a
  window and jumped around for text extraction, or the buffer contents
  searched line by line, this doesn't scale well in Vimscript. I would wish
  for a built-in Vim function that does this (and supports all values of
  'complete').

### CONTRIBUTING

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-CompleteHelper/issues or email (address below).

HISTORY
------------------------------------------------------------------------------

##### 1.52    28-Sep-2017
- Need to restore entire view, not just the cursor position when matching in
  the current window. Else, a completion may change the current view.
- CompleteHelper#Abbreviate#Word(): Only offer the full word in the preview
  window if a:matchObj.info hasn't been set yet.
- Use ingo#compat#window#IsCmdlineWindow().
  __You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.028!__

##### 1.51    23-Apr-2015
- Backwards compatibility: haslocaldir() doesn't exist in Vim 7.0.
- FIX: Duplicate matches when the additional match info is different. Only
  CompleteHelper#AddMatch() when the same a:match.word doesn't yet exist in
  a:matches; a test for existence of the same a:match object isn't sufficient
  due to the other attributes.
- Don't consider the current buffer when a:options.complete does not contain
  "."; some completions may want to explicitly exclude the current buffer.
- CHG: Exclude unloaded buffers from a:options.complete = "b" and introduce
  "u" option value for those.
- Add "U" option value for unlisted (loaded and unloaded) buffers, like in the
  built-in 'complete' option.
- DWIM: Check for a:options.extractor and then skip incompatible
  a:options.complete values. This allows MotionComplete.vim plugins to default
  to 'complete' values and prevents user misconfiguration.
- FIX: Also consider buffers from windows visible in other tab pages (by
  collecting their buffer numbers, not by actually visiting each tab page).
  This matters when a:options.complete does not contain "b" (or "u" when
  unlisted buffers are shown in a window).
- ENH: Keep previous (last accessed) window when searching through them for
  matches.

##### 1.50    23-Dec-2014
- Split the match extraction via pattern match from the window / buffer
  iteration, which now takes a generic Funcref, allowing for other algorithms:
  Remove ...Matches... from the s:FindMatchesIn...() functions. Extract
  s:MatchInCurrent() and s:MatchInBuffer(). Add CompleteHelper#Find() generic
  alternative to CompleteHelper#FindMatches() that takes a Funcref instead of
  a regular expression.
- Expose CompleteHelper#AddMatch().
- ENH: Add a:options.abbreviate and evaluate in CompleteHelper#AddMatch().
  This saves completion plugins from doing an additional map() over the List
  of matches.

##### 1.42    27-Nov-2014
- getbufline() can only access loaded buffers, for completion from unloaded
  buffers, we need to use readfile().

##### 1.41    31-May-2014
- FIX: In the completion buffer, check for the cursor position being anywhere
  in the match, not just at the end. We must not only avoid matching the base,
  but any text around the cursor. This is especially important for completion
  repeats, to avoid offering text after the cursor.
  __You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.019!__

##### 1.40    16-Apr-2014
- Remove the duplicated implementation in CompleteHelper#ExtractText(),
  deprecate it, and delegate to ingo#text#Get().
- FIX: a:options.backward\_search with falsy value also enables backward
  search.
- Add g:CompleteHelper\_IsDefaultToBackwardSearch config var that lets
  CompleteHelper#FindMatches() default to backwards search when no
  a:options.backward\_search is given. Since all of my custom completions don't
  offer separate backward / forward mappings, and backward search (i.e.
  offering first what got recently typed) makes more sense, default to
  backward search from now on.
- Allow to debug the pattern via :let g:CompleteHelper\_DebugPatterns = [].
- Allow completion repeats to continue repeating from following lines like the
  built-in completions do: The newline plus any indent is removed, and just
  the first word from the following line is matched. For this, the
  CompleteHelper#Repeat#Processor() is offered.
- I18N: Correctly handle repeats of (text ending with a) multi-byte character:
  Instead of just subtracting one from the column, ask for an end-exclusive
  text grab from ingo#text#Get().
- Add CompleteHelper#Repeat#GetPattern() to encapsulate the common assembly of
  the repeat pattern, especially the complex expressions with negative and
  positive character expressions to emulate Vim's built-in completion repeat
  behavior.
  __You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.018!__

##### 1.32    14-Dec-2013
- ENH: Allow to pass a List of regular expressions to
  CompleteHelper#FindMatches(). If you have multiple regular expressions that
  can match at the same position and should yield separate matches, you cannot
  use regular expression branches.
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)). __You need to separately
  install ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.014 (or higher)!__

##### 1.31    07-Mar-2013
- Truncate to a bit less than half of Vim's width because the popup menu
  spacing as well as fold, number and sign columns further reduce the
  available space.
- Avoid "E11: Invalid in command-line window" error when performing
  completions that search other windows from the command-line window. Use the
  buffer-search instead; it does not need to change the current window for its
  search.
- FIX: Don't abort iteration of buffers in s:FindMatchesInOtherBuffers() when
  one buffer was already searched; instead :continue with the next.

##### 1.30    27-Sep-2012
- ENH: Allow skipping of buffers via new a:options.bufferPredicate Funcref.
- Optimization: Skip search in other windows where there's only one that got
  searched already by s:FindMatchesInCurrentWindow().
- Optimization: Only visit window when its buffer wasn't already searched.

##### 1.20    03-Sep-2012 (unreleased)
- ENH: Implement a:options.complete = 'b' (only supporting single-line matches and no a:options.extractor).
- Transparently handle 'autochdir': still show the correct relative path in
  matches from other windows, and restore the buffer's CWD even if it was
  temporarily changed.

##### 1.11    03-Sep-2012
- Make a:matchObj in CompleteHelper#ExtractText() optional; it's not used
  there, anyway. This avoids having to pass an empty dictionary just to
  satisfy the API.
- Introduce a:alreadySearchedBuffers to allow for swapped order in
  a:options.complete and to prepare for additional complete options.

##### 1.10    05-May-2012
- Factor out CompleteHelper#Abbreviate#Text() to allow processing of
  completion menu text (and other uses), too.
- ENH: Offer full completion word in the preview window when it is shown
  abbreviated. Clients get this automatically when using
  CompleteHelper#Abbreviate#Word().

##### 1.00    31-Jan-2012
- First published version.

##### 0.01    13-Aug-2008
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2008-2017 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat <ingo@karkat.de>
