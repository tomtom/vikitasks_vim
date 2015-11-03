" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    238

" If you use todo.txt (http://todotxt.com), set this variable to a 
" dictionary of glob patterns that identifies todotxt files that map 
" onto the corresponding archive files.
"
" Caveat: Make sure |g:vikitasks#sources.todotxt| is true.
TLet g:vikitasks#ft#todotxt#files = {}

TLet g:vikitasks#ft#todotxt#ignore_rx = '[\/]\(recur\|done\)\.txt$'

" If true, use t:DATE to hide entries until DATE.
TLet g:vikitasks#ft#todotxt#use_threshold = 1   "{{{2

" If true, hide lines containing a h:1 tag, which is used e.g. by the 
" Simpletask Android app.
TLet g:vikitasks#ft#todotxt#respect_h1 = 1

" Assume this default (in terms of vikitasks) for tasks with no due 
" date.
" Useful values:
"   '_' ... Unspecified date -> include in alarms list
"   ''  ... No date -> exclude from alarms list
TLet g:vikitasks#ft#todotxt#due_default = ''   "{{{2

" |:execute| a command (as string) after changing a line.
" See also |g:vikitasks#after_change_line_exec|.
TLet g:vikitasks#ft#todotxt#after_change_line_exec = g:vikitasks#after_change_line_exec


" |:execute| a command (as string) after changing a buffer.
" See also |g:vikitasks#after_change_line_exec|.
TLet g:vikitasks#ft#todotxt#after_change_buffer_exec = g:vikitasks#after_change_buffer_exec

TLet g:vikitasks#ft#todotxt#filetypes = ['todotxt', 'todo', 'ttodo']

" If true, copy items with rec:DATE tags.
TLet g:vikitasks#ft#todotxt#copy_rec_items = 1


if exists('g:ttodo#dirs')
    for s:dir in g:ttodo#dirs
        let g:vikitasks#ft#todotxt#files[tlib#file#Join([resolve(s:dir), '*.txt'])] = 'done.txt'
    endfor
    unlet! s:dir
elseif exists('g:todotxt#dir')
    let g:vikitasks#ft#todotxt#files[tlib#file#Join([resolve(g:todotxt#dir), '*.txt'])] = 'done.txt'
endif


let s:prototype = {}


function! s:prototype.GetFiletype(...) dict "{{{3
    return 'todotxt'
endf


function! s:prototype.DateRx() dict "{{{3
    return '\C\<due:'. g:tlib#date#date_rx
endf


function! s:prototype.CategoryRx() dict "{{{3
    return '\C\(^\|\s\+\)(\zs\u\ze)\($\|\s\+\)'
endf


function! s:prototype.FinalRx() dict "{{{3
    return '^x\s'
endf


function! s:prototype.TaskLineRx(inline, sometasks, letters, levels) dict "{{{3
    " let val = '\C^\s*\(\(('. a:letters .')\|x\)\s\+\)\?'
    " Every line matches
    let val = '.'
    return val
endf


let s:prototype.sometasks_rx = s:prototype.TaskLineRx(1, 1, g:vikitasks#rx_categories, g:vikitasks#rx_levels)
let s:prototype.tasks_rx = s:prototype.TaskLineRx(0, 0, 'A-Z', '0-9')

exec 'TRagDefKind tasks todotxt /'. s:prototype.tasks_rx .'/'
exec 'TRagDefKind sometasks todotxt /'. s:prototype.sometasks_rx .'/'
exec 'TRagDefKind tasks ttodo /'. s:prototype.tasks_rx .'/'
exec 'TRagDefKind sometasks ttodo /'. s:prototype.sometasks_rx .'/'


function! s:prototype.ConvertLine(line, ...) dict "{{{3
    " TLogVAR a:line
    let t_rx = '\<t:\zs'. g:tlib#date#date_rx
    if g:vikitasks#ft#todotxt#use_threshold && a:line =~ t_rx
        let today = strftime(g:vikitasks#date_fmt)
        let threshold = matchstr(a:line, t_rx)
        " TLogVAR today, threshold, today>threshold
        if today < threshold
            return ''
        endif
    endif
    " Priority
    let line = substitute(a:line, '^\C(\([A-Z]\))\ze\s\+', '#\1', '')
    let line = substitute(line, '^\Cx\ze\s\+', '#X', '')
    if line !~# '^#\u'
        let line = '#'. g:vikitasks#default_priority .' '. line
    endif
    if line !~# '\<due:\(\d\+-\d\+-\d\+\|_\)' && !empty(g:vikitasks#ft#todotxt#due_default)
        let line .= ' due:'. g:vikitasks#ft#todotxt#due_default
    endif
    for [rx, subst] in [
                \ ['\s\zs+\(\S\+\)', ':\1'],
                \ ['^#\u\d*\s\+\zs\('. g:tlib#date#date_rx .'\s\+\)\(.\{-}\)\s*$', '\2 created:\1'],
                \ ['^#\u\d*\s\+\zs\(.\{-}\)\<due:\('. g:tlib#date#date_rx .'\)\s*', '\2 \1'],
                \ ['\s\s\+', ' '],
                \ ]
        " \ ['^#\u\d*\s\+\(\d\+-\d\+-\d\+\s\+\)\?\zs\(.\{-}\)\<due:\(\d\+-\d\+-\d\+\)', '..\2 \1'],
        " \ ['^#\u\d*\s\([0-9-]\+\s\([0-9-]\+\)\?\s\)\?\zs\(.\{-}\)\s+\(\S\+\)\ze\+\(\s\|$\)', ':\4 \3']
        " \ ['^#\u\d*\s\([0-9-]\+\s\([0-9-]\+\)\?\s\)\?\zs\(.\{-}\)\s\(@\S\+\)\ze\+\(\s\|$\)', '\4 \3'],
        let line0 = ''
        let iterations = 5
        while line =~ rx && line0 != line && iterations > 0
            let line0 = line
            let line  = substitute(line, rx, subst, 'g')
            " TLogVAR rx, line0, line
            let iterations -= 1
        endwh
    endfor
    if g:vikitasks#ft#todotxt#respect_h1 && line =~# '\<h:1\>'
        let line = ''
    endif
    " let line = substitute(line, '^#\u\d*\s\zs\(.\{-}\s\)\?t:\([0-9-]\+\)\ze\(\s\|$\)', '\2 \1', 'g')
    " TLogVAR line
    return line
endf


function! s:prototype.IsA(filetype, filename) dict "{{{3
    if index(g:vikitasks#ft#todotxt#filetypes, a:filetype) != -1
        return 1
    endif
    let pattern = self.FindPattern(a:filename)
    TLibTrace 'vikitasks', a:filename, pattern
    return !empty(pattern)
endf


function! s:prototype.FindPattern(filename) dict "{{{3
    TLibTrace 'vikitasks', a:filename
    for [pattern, archive] in items(g:vikitasks#ft#todotxt#files)
        TLibTrace 'vikitasks', pattern, archive
        if (has('fname_case') && a:filename ==# pattern) || a:filename ==? pattern
            TLibTrace 'vikitasks', pattern
            return pattern
        endif
        let rx = vikitasks#Glob2Rx(pattern)
        TLibTrace 'vikitasks', rx, a:filename=~rx
        if a:filename =~ rx
            return pattern
        endif
    endfor
    return ''
endf


function! s:prototype.GetFiles(registrar) dict "{{{3
    for [pattern, archive] in items(g:vikitasks#ft#todotxt#files)
        for filename in split(glob(pattern), '\n')
            " TLogVAR filename, trag#HasFiletype(filename)
            " call add(files, filename)
            if !trag#HasFiletype(filename)
                call trag#SetFiletype('todotxt', filename)
            endif
            call call(a:registrar, [filename, 'todotxt', archive, g:vikitasks#ft#todotxt#ignore_rx])
        endfor
    endfor
endf


function! s:prototype.GetArchiveName(filename) dict "{{{3
    let pattern = self.FindPattern(a:filename)
    let archive = get(g:vikitasks#ft#todotxt#files, pattern, 'done.txt')
    if archive !~ '[\/]'
        let archive = tlib#file#Join([fnamemodify(a:filename, ':p:h'), archive])
    endif
    return archive
endf


function! s:prototype.ArchiveHeader(first_entry) dict "{{{3
    return ''
endf


function! s:prototype.ArchiveItem(line) dict "{{{3
    let date = strftime(g:vikitasks#date_fmt) .' '
    " return substitute(a:line, '^\C\s*x\zs\ze\s\+', ' archive:'. escape(date, '\'), '')
    return a:line .' archive:'. date
endf


function! s:prototype.MarkItemDueInDays(line, duedate) dict "{{{3
    let rx = self.DateRx()
    TLibTrace 'vikitasks', a:line, a:duedate, rx
    " TLogVAR a:line, a:duedate, rx
    if a:line =~# rx
        let line = substitute(a:line, rx, 'due:'. escape(a:duedate, '\'), 'g')
    else
        let line = a:line .' due:'. a:duedate
    endif
    " TLogVAR line
    return line
endf


function! s:prototype.ItemMarkDone(line, ...) dict "{{{3
    let donedate = strftime(g:vikitasks#date_fmt)
    TLibTrace 'vikitasks', a:line, donedate
    if a:line =~# '^x\s\+'. g:tlib#date#date_rx .'\%(\s\d\d:\d\d\)\?'
        let line = substitute(a:line, '^x\s\+\zs'. g:tlib#date#date_rx, donedate, '')
    elseif a:line =~# '^x\s'
        let line = substitute(a:line, '^x\s\+\zs', donedate .' ', '')
    else
        let check_rec = a:0 >= 1 ? a:1 : 1
        let rec = matchstr(a:line, '\<rec:\zs+\?\d\+[dwmy]\>')
        if check_rec && !empty(rec)
            let due = matchstr(a:line, '\<due:\zs'. g:tlib#date#date_rx)
            let shift = matchstr(rec, '\d\+\a$')
            let refdate = rec =~ '^+' && !empty(due) ? due : donedate
            let ndue = empty(due) ? donedate : due
            " TLogVAR rec, due, shift, refdate
            while ndue <= refdate
                let ndue = tlib#date#Shift(ndue, shift)
                " TLogVAR ndue
            endwh
            let line = [self.MarkItemDueInDays(a:line, ndue)]
            if g:vikitasks#ft#todotxt#copy_rec_items
                call insert(line, self.ItemMarkDone(a:line, 0))
            endif
            " TLogVAR a:line, line
        else
            let line = join(['x', donedate, a:line])
        endif
    endif
    TLibTrace 'vikitasks', line
    return line
endf


function! s:prototype.ChangeCategory(line, category) dict "{{{3
    let rx = self.CategoryRx()
    TLibTrace 'vikitasks', a:line, a:category, rx
    if a:line =~ rx
        let line = substitute(a:line, rx, a:category, '')
    else
        let line = printf('(%s) %s', a:category, a:line)
    endif
    return line
endf


function! s:prototype.AfterChangeBuffer() dict "{{{3
    if !empty(g:vikitasks#ft#todotxt#after_change_buffer_exec)
        exec g:vikitasks#ft#todotxt#after_change_buffer_exec
    endif
endf


function! s:prototype.AfterChangeLine() dict "{{{3
    if !empty(g:vikitasks#ft#todotxt#after_change_line_exec)
        exec g:vikitasks#ft#todotxt#after_change_line_exec
    endif
endf


function! vikitasks#ft#todotxt#GetInstance() "{{{3
    return s:prototype
endf


function! vikitasks#ft#todotxt#OpenTodoUrl(url) abort "{{{3
    let tname = substitute(a:url, '^todo://', '', '')
    let beg = -len(tname)
    let files = []
    for dir in g:vikitasks#ft#todotxt#files
        let files1 = split(glob(dir), '\n')
        let files1 = filter(files1, 'v:val[beg : -1] ==# tname')
        let files += files1
    endfor
    let file = tlib#input#List('s', 'Pick todo file:', files)
    if !empty(file)
        call tlib#file#Edit(file)
    endif
endf

