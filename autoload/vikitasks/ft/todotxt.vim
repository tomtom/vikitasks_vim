" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    35


" If you use todo.txt (http://todotxt.com), set this variable to a 
" dictionary of glob patterns that identifies todotxt files that map 
" onto the corresponding archive files.
"
" Caveat: Make sure |g:vikitasks#sources.todotxt| is true.
TLet g:vikitasks#ft#todotxt#files = {}


let s:prototype = {}


function! s:prototype.GetFiletype(...) dict "{{{3
    return 'todotxt'
endf


function! s:prototype.TaskLineRx(inline, sometasks, letters, levels) dict "{{{3
    let val = '\C^\zs\(('. a:letters .')\s\+\|x\s\+\)\?\([0-9-]\+\s\+\)\{,2}.\+$'
    return val
endf


let s:prototype.sometasks_rx = s:prototype.TaskLineRx(1, 1, g:vikitasks#rx_letters, g:vikitasks#rx_levels)
let s:prototype.tasks_rx = s:prototype.TaskLineRx(0, 0, 'A-Z', '0-9')

exec 'TRagDefKind tasks todotxt /'. s:tasks_todotxt_rx .'/'
exec 'TRagDefKind sometasks todotxt /'. s:sometasks_todotxt_rx .'/'


function! s:prototype.ConvertLine(line) dict "{{{3
    let line = substitute(a:line, '^\C(\([A-Z]\))\ze\s\+', '#\1', '')
    if line !~# '^#\u'
        let line = '#'. g:vikitasks#default_priority .' '. line
    endif
    for [rx, subst] in [
                \ ['^#\u\d*\s\([0-9-]\+\s\([0-9-]\+\)\?\s\)\?\zs\(.\{-}\)\s\(@\S\+\)\ze\+\(\s\|$\)', '\4 \3'],
                \ ['^#\u\d*\s\([0-9-]\+\s\([0-9-]\+\)\?\s\)\?\zs\(.\{-}\)\s+\(\S\+\)\ze\+\(\s\|$\)', ':\4 \3']
                \ ]
        let line0 = ''
        let iterations = 5
        while line0 != line && iterations > 0
            let line0 = line
            let line  = substitute(line, rx, subst, 'g')
            let iterations -= 1
        endwh
    endfor
    let line = substitute(line, '^#\u\d*\s\zs\(.\{-}\s\)\?t:\([0-9-]\+\)\ze\(\s\|$\)', '\2 \1', 'g')
    " TLogVAR line
    return line
endf


function! s:prototype.IsA(filename) dict "{{{3
    for [pattern, archive] in items(g:vikitasks#ft#todotxt#files)
        if (has('fname_case') && a:filename ==# pattern) || a:filename ==? pattern
            return 1
        endif
        let rx = vikitasks#Glob2Rx(pattern)
        if a:filename =~ rx
            return 1
        endif
    endfor
    return 0
endf


function! s:prototype.GetFiles(registrar) dict "{{{3
    for [pattern, archive] in items(g:vikitasks#ft#todotxt#files)
        for filename in split(glob(pattern), '\n')
            " call add(files, filename)
            call call(a:registrar, [filename, 'todotxt', archive])
        endfor
    endfor
endf


function! s:prototype.GetArchiveName(filename) dict "{{{3
    return tlib#file#Join([fnamemodify(a:filename, ':p:h'), 'done.txt'])
endf


function! vikitasks#ft#todotxt#GetInstance() "{{{3
    if !trag#HasFiletype(todotxt)
        call trag#SetFiletype('todotxt', 'todotxt')
    endif
    return s:prototype
endf

