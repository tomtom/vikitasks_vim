" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    164


" If you use taskpaper, set this variable to a dictionary of glob 
" patterns that identifies taskpaper files that map onto the 
" corresponding archive files.
"
" Caveat: Make sure |g:vikitasks#sources.taskpaper| is true.
TLet g:vikitasks#ft#taskpaper#files = {}

TLet g:vikitasks#ft#taskpaper#archive_filename = 'done.taskpaper'

" Assume this default (in terms of vikitasks) for tasks with no due 
" date.
" Useful values:
"   '_' ... Unspecified date -> include in alarms list
"   ''  ... No date -> exclude from alarms list
TLet g:vikitasks#ft#taskpaper#due_default = ''   "{{{2


TLet g:vikitasks#ft#taskpaper#category_default = 'B'   "{{{2


TLet g:vikitasks#ft#taskpaper#ignore_rx = ''


" |:execute| a command (as string) after changing a line.
" See also |g:vikitasks#after_change_line_exec|.
TLet g:vikitasks#ft#taskpaper#after_change_line_exec = g:vikitasks#after_change_line_exec


" |:execute| a command (as string) after changing a buffer.
" See also |g:vikitasks#after_change_line_exec|.
TLet g:vikitasks#ft#taskpaper#after_change_buffer_exec = g:vikitasks#after_change_buffer_exec

TLet g:vikitasks#ft#taskpaper#tags_rx = {
            \ 'done': 'done',
            \ 'due': 'due',
            \ 'priority': '\%(pri\%[ority]\|cat\%[egory]\)',
            \ 'threshold': 't\%[hreshold]'
            \ }


function! s:GetTag(name, ...) abort "{{{3
    let tag = get(g:vikitasks#ft#taskpaper#tags_rx, a:name, '')
    if !empty(tag)
        let tag = printf('\C@%s\>', tag)
        if a:0 >= 1 && !empty(a:1)
            if type(a:1) == 1
                let tag .= '('. a:1 .')'
            else
                let tag .= '(\([^)]*\))'
            endif
        endif
    endif
    return tag
endf


let s:prototype = deepcopy(vikitasks#ft#todotxt#GetInstance())


function! s:prototype.GetFiletype(...) dict "{{{3
    return 'taskpaper'
endf


function! s:prototype.DateRx() dict "{{{3
    return s:GetTag('due', '\zs'. g:vikitasks#date_rx .'\ze')
endf


function! s:prototype.CategoryRx() dict "{{{3
    return s:GetTag('priority', '\zs[^)]*\ze')
endf


function! s:prototype.FinalRx() dict "{{{3
    return s:GetTag('done', 0)
endf


function! s:prototype.TaskLineRx(inline, sometasks, letters, levels) dict "{{{3
    let task = '\s*-'
    if a:sometasks
        let task .= '.\{-}'. s:GetTag('priority', a:levels)
    endif
    let rx = '^\%('. task .'\|.\{-}:\s*$\)'
    return rx
endf


let s:prototype.sometasks_rx = s:prototype.TaskLineRx(1, 1, g:vikitasks#rx_categories, '['. g:vikitasks#rx_levels .']')
let s:prototype.tasks_rx = s:prototype.TaskLineRx(0, 0, 'A-Z', '[0-9]\+')

exec 'TRagDefKind tasks taskpaper /'. s:prototype.tasks_rx .'/'
exec 'TRagDefKind sometasks taskpaper /'. s:prototype.sometasks_rx .'/'


let s:convertline_state = {}


function! vikitasks#ft#taskpaper#ConvertFile(cfilename) abort "{{{3
    let lines = readfile(a:cfilename)
    let cvt = vikitasks#ft#taskpaper#GetInstance()
    let clines = map(lines, 'cvt.ConvertLine(v:val, a:cfilename)')
    let clines = filter(clines, '!empty(v:val)')
    return clines
endf


function! s:prototype.ConvertLine(line, cfilename) dict "{{{3
    " TLogVAR a:line
    if get(s:convertline_state, 'filename', '') != a:cfilename
        let s:convertline_state = {'filename': a:cfilename, 'headings': [], 'levels': []}
    endif
    if a:line =~ '^\s*[^-].\{-}:\s*$'
        let hd = substitute(a:line, '\(^\s*\|:\s*$\)', '', 'g')
        let level = len(matchstr(a:line, '^\s*'))
        let olev = get(s:convertline_state.levels, -1, -1)
        while level <= olev
            call remove(s:convertline_state.headings, -1)
            call remove(s:convertline_state.levels, -1)
            if empty(s:convertline_state.levels)
                let olev = -1
                break
            else
                let olev = s:convertline_state.levels[-1]
            endif
        endwh
        call add(s:convertline_state.headings, hd)
        call add(s:convertline_state.levels, level)
        return ''
    else
        let line = substitute(a:line, '^\s*-', '#'. g:vikitasks#ft#taskpaper#category_default, '')
        if !empty(g:vikitasks#ft#taskpaper#due_default) && line !~ self.DateRx()
            let line = substitute(a:line, '^#\u\?\d\*\zs', g:vikitasks#ft#taskpaper#due_default .' ', '')
        endif
        for [rx, subst] in [
                    \ ['^\(.\{-}\)'. s:GetTag('priority', 1), '\=s:ConvertPriTag(submatch(2), submatch(1))'],
                    \ ['^\(.\{-}\)'. self.FinalRx(), '\=s:ConvertDoneTag(submatch(2), submatch(1))'],
                    \ ['@\(\w\+\%(([^)]*)\)\)', ':\1'],
                    \ ['\s\s\+', ' '],
                    \ ['\s\+$', ''],
                    \ ]
            let line0 = ''
            let iterations = 3
            while line =~ rx && line0 != line && iterations > 0
                let line0 = line
                let line  = substitute(line, rx, subst, 'g')
                " TLogVAR rx, line0, line
                let iterations -= 1
            endwh
        endfor
        if !empty(line)
            let line .= ' /'. join(s:convertline_state.headings, '/')
        endif
        " TLogVAR line
        return line
    endif
endf


function! s:ConvertPriTag(pri, prefix) abort "{{{3
    return substitute(a:prefix, '^#[A-Z]\?\zs\d*', a:pri, '')
endf


function! s:ConvertDoneTag(pri, prefix) abort "{{{3
    return substitute(a:prefix, '^#\zs[A-Z]', 'X', '')
endf


function! s:prototype.IsA(filetype, filename) dict "{{{3
    return a:filetype =~ '^taskpaper$' || matchstr(a:filename, '\.\zs\a\+$') ==# 'taskpaper'
endf


function! s:prototype.FindPattern(filename) dict "{{{3
    " TLogVAR a:filename
    for [pattern, archive] in items(g:vikitasks#ft#taskpaper#files)
        if (has('fname_case') && a:filename ==# pattern) || a:filename ==? pattern
            " TLogVAR "ok", pattern
            return pattern
        endif
        let rx = vikitasks#Glob2Rx(pattern)
        " TLogVAR rx
        if a:filename =~ rx
            return pattern
        endif
    endfor
    return ''
endf


function! s:prototype.GetFiles(registrar) dict "{{{3
    for [pattern, archive] in items(g:vikitasks#ft#taskpaper#files)
        for filename in split(glob(pattern), '\n')
            " TLogVAR filename
            " call add(files, filename)
            if !trag#HasFiletype(filename)
                call trag#SetFiletype('taskpaper', filename)
            endif
            call call(a:registrar, [filename, 'taskpaper', archive, g:vikitasks#ft#taskpaper#ignore_rx])
        endfor
    endfor
endf


function! s:prototype.GetArchiveName(filename) dict "{{{3
    let pattern = self.FindPattern(a:filename)
    let archive = get(g:vikitasks#ft#taskpaper#files, pattern, g:vikitasks#ft#taskpaper#archive_filename)
    if archive !~ '[\/]'
        let archive = tlib#file#Join([fnamemodify(a:filename, ':p:h'), archive])
    endif
    return archive
endf


" function! s:prototype.ArchiveHeader(first_entry) dict "{{{3
"     return ''
" endf


" function! s:prototype.ArchiveItem(line) dict "{{{3
"     let date = strftime(g:vikitasks#date_fmt) .' '
"     return substitute(a:line, '^\C\s*x\s\+\zs', escape(date, '\'), '')
" endf


" function! s:prototype.MarkItemDueInDays(line, duedate) dict "{{{3
"     let rx = self.DateRx()
"     " TLogVAR a:line, a:duedate, rx
"     let line = substitute(a:line, rx, escape(a:duedate, '\'), 'g')
"     " TLogVAR line
"     return line
" endf


function! s:prototype.ItemMarkDone(line) dict "{{{3
    let line = [a:line]
    if g:vikitasks#done_add_date
        call insert(line, strftime(g:vikitasks#date_fmt))
    endif
    call add(line, '@done')
    return join(line, ' ')
endf


function! s:prototype.ChangeCategory(line, category) dict "{{{3
    let rx = self.CategoryRx()
    if a:line =~ rx
        let line = substitute(a:line, rx, a:category, '')
    else
        let line = printf('(%s) %s', a:category, a:line)
    endif
    return line
endf


function! s:prototype.AfterChangeBuffer() dict "{{{3
    if !empty(g:vikitasks#ft#taskpaper#after_change_buffer_exec)
        exec g:vikitasks#ft#taskpaper#after_change_buffer_exec
    endif
endf


function! s:prototype.AfterChangeLine() dict "{{{3
    if !empty(g:vikitasks#ft#taskpaper#after_change_line_exec)
        exec g:vikitasks#ft#taskpaper#after_change_line_exec
    endif
endf


function! vikitasks#ft#taskpaper#GetInstance() "{{{3
    return s:prototype
endf

