" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    47


" If non-null, automatically add the homepages of your intervikis to 
" |g:vikitasks#files|.
" If the value is 2, scan all files (taking into account the interviki 
" suffix) in the interviki's top directory.
" Can be buffer-local.
TLet g:vikitasks#ft#viki#intervikis = 0

" A list of ignored intervikis.
" Can be buffer-local.
TLet g:vikitasks#ft#viki#intervikis_ignored = []

TLet g:vikitasks#ft#viki#archive_filename_fmt = '"%s_archived". g:vikiNameSuffix'


let s:prototype = {}


function! s:prototype.GetFiletype(...) dict "{{{3
    return 'viki'
endf


function! s:prototype.TaskLineRx(inline, sometasks, letters, levels) dict "{{{3
    let val = '\C^[[:blank:]]'. (a:inline ? '*' : '\+') .'\zs'.
                \ '#\(T: \+.\{-}'. a:letters .'.\{-}:\|'. 
                \ '['. a:levels .']\?['. a:letters .']['. a:levels .']\?'.
                \ '\( \+\(_\|x\?[0-9%-]\+\)\)\?\)\(\s%s\|$\)'
    return val
endf


let s:prototype.sometasks_rx = s:prototype.TaskLineRx(1, 1, g:vikitasks#rx_letters, g:vikitasks#rx_levels)
let s:prototype.tasks_rx = s:prototype.TaskLineRx(0, 0, 'A-Z', '0-9')

exec 'TRagDefKind tasks viki /'. s:prototype.tasks_rx .'/'
exec 'TRagDefKind sometasks viki /'. s:prototype.sometasks_rx .'/'
exec 'TRagDefKind tasks * /'. s:prototype.tasks_rx .'/'
exec 'TRagDefKind sometasks * /'. s:prototype.sometasks_rx .'/'


function! s:prototype.ConvertLine(line) dict "{{{3
    return a:line
endf


function! s:prototype.GetFiles(registrar) dict "{{{3
    for file in tlib#var#Get('vikitasks#files', 'bg', [])
        call call(a:registrar, [file, 'viki', ''])
    endfor
    if tlib#var#Get('vikitasks#ft#viki#intervikis', 'bg', 0) > 0
        " TLogVAR a:files
        let ivignored = tlib#var#Get('vikitasks#intervikis_ignored', 'bg', [])
        let glob = tlib#var#Get('vikitasks#intervikis', 'bg', 0) == 2
        for iv in viki#GetInterVikis()
            if index(ivignored, matchstr(iv, '^\u\+')) == -1
                " TLogVAR iv
                let def = viki#GetLink(1, '[['. iv .']]', 0, '')
                let file = def[1]
                " TLogVAR def
                if glob > 0
                    let suffix = viki#InterVikiSuffix(iv)
                    let dirpattern = tlib#file#Join([fnamemodify(file, ':p:h'), '**/*'. suffix], 1)
                    call call(a:registrar, [dirpattern, 'viki', ''])
                else
                    call call(a:registrar, [file, 'viki', ''])
                endif
            endif
        endfor
    endif
endf


function! s:prototype.MarkDone(line) dict "{{{3
    let line = a:line
    let rx = vikitasks#TasksRx('tasks')
    if line =~ rx && line !~ '^\C\s*#'. vikitasks#FinalRx()
        let line = substitute(line, '^\C\s*#\zs\u', 'X', '')
        if g:vikitasks#done_add_date
            let idx = matchend(line, g:vikitasks#date_rx)
            if idx == -1
                let idx = matchend(line, '^\C\s*#\u\d*\ze\s')
            endif
            if idx != -1
                let line = strpart(line, 0, idx)
                            \ . strftime(' :done:%Y-%m-%d')
                            \ . strpart(line, idx)
            endif
        endif
        " TLogVAR line
        call setline(lnum, line)
        return [1, line]
    else
        return [0, line]
    endif
endf


function! s:prototype.GetArchiveName(filename) dict "{{{3
    if empty(g:vikitasks#ft#viki#archive_filename_fmt)
        throw "vikitasks: Cannot archive tasks: g:vikitasks#ft#viki#archive_filename_fmt is empty"
    else
        let fmt = eval(g:vikitasks#ft#viki#archive_filename_fmt)
        return printf(fmt, a:filename)
    endif
endf


function! s:prototype.ItemArchiveFinal() dict "{{{3
    let archive_filename = s:vikitasks#GetFileProperty('archive', expand("%:p:r"))
    if filereadable(archive_filename)
        let archived = readfile(archive_filename)
    else
        let archived = copy(g:vikitasks#archive_header)
    endif
    let to_be_archived = []
    let clnum = line('.')
    for lnum in reverse(range(1, line('$')))
        let line = getline(lnum)
        if line =~ '\C^\s*#'. vikitasks#FinalRx() || line =~ '\C^\s\+#\(\u\d\|\d\u\)\s\+x[ [:digit:]]'
            call insert(to_be_archived, line)
            if lnum <= clnum
                norm! k
            endif
            exec lnum 'delete'
        endif
    endfor
    if !empty(to_be_archived)
        if !empty(g:vikitasks#archive_date_fmt)
            let archived += ['', strftime(g:vikitasks#archive_date_fmt)]
        endif
        let archived += to_be_archived
        call writefile(archived, archive_filename)
    endif
endf


function! s:prototype.MarkItemDueInDays(line, duedate) dict "{{{3
    let line = a:line
    let rx = vikitasks#TasksRx('tasks')
    if line =~ rx && line =~ g:vikitasks#date_rx && line !~ '^\C\s*#'. vikitasks#FinalRx()
        let m = matchlist(line, g:vikitasks#date_rx)
        if !empty(get(m, 4, ''))
            let subst = '\1\2..'. a:duedate
        else
            let subst = '\1'. a:duedate
        endif
        let line1 = substitute(line, g:vikitasks#date_rx, subst, '')
        " TLogVAR line1
        return [1, line1]
    else
        return [0, line]
    endif
endf


function! s:prototype.IsA(filename) dict "{{{3
    return 1
endf


function! vikitasks#ft#viki#GetInstance() "{{{3
    return s:prototype
endf


