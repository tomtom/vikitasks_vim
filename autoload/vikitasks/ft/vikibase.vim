" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    149

" If non-null, automatically add the homepages of your intervikis to 
" |g:vikitasks#files|.
" If the value is 2, scan all files (taking into account the interviki 
" suffix) in the interviki's top directory.
" Can be buffer-local.
TLet g:vikitasks#ft#vikibase#intervikis = 2

" A list of ignored intervikis.
" Can be buffer-local.
TLet g:vikitasks#ft#vikibase#intervikis_exclude = []

" If non-empty, scan an interviki only if the name is included in this 
" list.
TLet g:vikitasks#ft#vikibase#intervikis_include = []

TLet g:vikitasks#ft#vikibase#intervikis_suffixes = ['.viki', '.txt']

TLet g:vikitasks#ft#vikibase#archive_filename_fmt = '"%s_archived". g:viki_name_suffix'

" |:execute| a command (as string) after changing a line.
" See also |g:vikitasks#after_change_line_exec|.
TLet g:vikitasks#ft#vikibase#after_change_line_exec = g:vikitasks#after_change_line_exec

" |:execute| a command (as string) after changing a buffer.
" See also |g:vikitasks#after_change_line_exec|.
TLet g:vikitasks#ft#vikibase#after_change_buffer_exec = g:vikitasks#after_change_buffer_exec


let s:prototype = {}


function! s:prototype.GetFiletype(...) dict "{{{3
    return 'vikibase'
endf


function! s:prototype.DateRx() dict "{{{3
    return g:vikitasks#viki_date_rx
endf


function! s:prototype.CategoryRx() dict "{{{3
    return '^\C\s*#\zs\u'
endf


function! s:prototype.FinalRx() dict "{{{3
    let rx = printf('\C^\s*#\([%s]\|\(\u\d\|\d\u\)\s\+x[ [:digit:]]\)', g:vikitasks#final_categories)
    return rx
endf


function! s:prototype.TaskLineRx(inline, sometasks, letters, levels) dict "{{{3
    let val = '\C^[[:blank:]]'. (a:inline ? '*' : '\+') .'\zs'.
                \ '#\(T: \+.\{-}'. a:letters .'.\{-}:\|'. 
                \ '['. a:levels .']\?['. a:letters .']['. a:levels .']\?'.
                \ '\( \+\(_\|x\?[0-9%-]\+\)\)\?\)\(\s%s\|$\)'
    return val
endf


let s:prototype.sometasks_rx = s:prototype.TaskLineRx(1, 1, g:vikitasks#rx_categories, g:vikitasks#rx_levels)
let s:prototype.tasks_rx = s:prototype.TaskLineRx(0, 0, 'A-Z', '0-9')

exec 'TRagDefKind tasks vikibase /'. s:prototype.tasks_rx .'/'
exec 'TRagDefKind sometasks vikibase /'. s:prototype.sometasks_rx .'/'
if !get(g:vikitasks#sources, 'viki', 0)
    exec 'TRagDefKind tasks * /'. s:prototype.tasks_rx .'/'
    exec 'TRagDefKind sometasks * /'. s:prototype.sometasks_rx .'/'
endif


function! s:prototype.GetFiles(registrar) dict "{{{3
    for file in tlib#var#Get('vikitasks#files', 'bg', [])
        call call(a:registrar, [file, 'vikibase', ''])
    endfor
    let scan_interviki = tlib#var#Get('vikitasks#ft#vikibase#intervikis', 'bg', 0)
    Tlibtrace 'vikitasks', scan_interviki
    if scan_interviki > 0
        let iv_exclude = tlib#var#Get('vikitasks#ft#vikibase#intervikis_exclude', 'bg', [])
        let iv_include = tlib#var#Get('vikitasks#ft#vikibase#intervikis_include', 'bg', [])
        Tlibtrace 'vikitasks', iv_exclude, iv_include
        let ivikis = viki#interviki#GetInterVikis()
        let nvikis = len(ivikis)
        call tlib#progressbar#Init(nvikis, 'VikiTasks: Scan viki %s', 20)
        try
            let i = 0
            for iv in ivikis
                let i += 1
                let iv_name = matchstr(iv, '^\u\+')
                Tlibtrace 'vikitasks', iv, iv_name
                if viki#interviki#IsKnown(iv_name) && !viki#interviki#IsSpecialName(iv_name) && (!empty(iv_include) ? index(iv_include, iv_name) != -1 : index(iv_exclude, iv_name) == -1)
                    call tlib#progressbar#Display(i, ' '. iv)
                    if scan_interviki == 2
                        let suffix0 = viki#interviki#GetSuffix(iv_name)
                        if empty(suffix0)
                            let suffixes = g:vikitasks#ft#vikibase#intervikis_suffixes
                        else
                            let suffixes = [suffix0]
                        endif
                        for suffix in suffixes
                            let filepattern = '*'. suffix
                            if index(g:vikitasks_scan_patterns, filepattern) != -1
                                let prefix = viki#interviki#GetDest(iv_name)
                                let dirpattern = tlib#file#Join([fnamemodify(prefix, ':p:h'), '**/'. filepattern], 1)
                                Tlibtrace 'vikitasks', iv_name, dirpattern
                                call call(a:registrar, [dirpattern, 'vikibase', ''])
                            endif
                        endfor
                    else
                        let index = viki#interviki#GetIndex(iv_name)
                        if !empty(index)
                            call call(a:registrar, [index, 'vikibase', ''])
                        endif
                    endif
                endif
            endfor
        finally
            call tlib#progressbar#Restore()
        endtry
    endif
endf


function! s:prototype.MarkDone(line) dict "{{{3
    let line = a:line
    let rx = vikitasks#TasksRx('tasks')
    if line =~ rx && line !~ '^\C\s*#'. self.FinalRx()
        let line = substitute(line, '^\C\s*#\zs\u', 'X', '')
        if g:vikitasks#done_add_date
            let idx = matchend(line, g:vikitasks#viki_date_rx)
            if idx == -1
                let idx = matchend(line, '^\C\s*#\u\d*\ze\s')
            endif
            if idx != -1
                let line = strpart(line, 0, idx)
                            \ . strftime(' :done:'. g:vikitasks#date_fmt)
                            \ . strpart(line, idx)
            endif
        endif
        Tlibtrace 'vikitasks', line
        call setline(lnum, line)
        return [1, line]
    else
        return [0, line]
    endif
endf


function! s:prototype.GetArchiveName(filename) dict "{{{3
    if empty(g:vikitasks#ft#vikibase#archive_filename_fmt)
        throw "vikitasks: Cannot archive tasks: g:vikitasks#ft#vikibase#archive_filename_fmt is empty"
    else
        let fmt = eval(g:vikitasks#ft#vikibase#archive_filename_fmt)
        return printf(fmt, a:filename)
    endif
endf


function! s:prototype.ArchiveHeader(first_entry) dict "{{{3
    return (a:first_entry ? '' : "\n"). g:vikitasks#archive_header_fmt
endf


function! s:prototype.ArchiveItem(line) dict "{{{3
    return a:line
endf


function! s:prototype.MarkItemDueInDays(line, duedate) dict "{{{3
    let line = a:line
    let rx = vikitasks#TasksRx('tasks')
    if line =~ rx && line =~ g:vikitasks#viki_date_rx && line !~ '^\C\s*#'. self.FinalRx()
        let m = matchlist(line, g:vikitasks#viki_date_rx)
        if !empty(get(m, 4, ''))
            let subst = '\1\2..'. a:duedate
        else
            let subst = '\1'. a:duedate
        endif
        let line1 = substitute(line, g:vikitasks#viki_date_rx, subst, '')
        Tlibtrace 'vikitasks', line1
        return [1, line1]
    else
        return [0, line]
    endif
endf


function! s:prototype.IsA(filetype, filename) dict "{{{3
    Tlibtrace 'vikitasks', bufloaded(a:filename), a:filename
    return a:filetype =~# '^viki\(base\)\?$'
endf


function! s:prototype.MarkItemDueInDays(line, duedate) dict "{{{3
    let m = matchlist(a:line, g:vikitasks#viki_date_rx)
    if !empty(get(m, 4, ''))
        let subst = '\1\2..'. a:duedate
    else
        let subst = '\1'. a:duedate
    endif
    let line1 = substitute(a:line, g:vikitasks#viki_date_rx, subst, '')
    return line1
endf


function! s:prototype.ItemMarkDone(line) dict "{{{3
    let line = substitute(a:line, '^\C\s*#\zs\u', 'X', '')
    if g:vikitasks#done_add_date
        let idx = matchend(line, self.DateRx())
        if idx == -1
            let idx = matchend(line, '^\C\s*#\u\d*\ze\s')
        endif
        if idx != -1
            let line = strpart(line, 0, idx)
                        \ . strftime(' :done:'. g:vikitasks#date_fmt)
                        \ . strpart(line, idx)
        endif
    endif
    return line
endf


function! s:prototype.ChangeCategory(line, category) dict "{{{3
    let line = substitute(a:line, self.CategoryRx(), a:category, '')
    return line
endf


function! s:prototype.AfterChangeBuffer() dict "{{{3
    if !empty(g:vikitasks#ft#vikibase#after_change_buffer_exec)
        exec g:vikitasks#ft#vikibase#after_change_buffer_exec
    endif
endf


function! s:prototype.AfterChangeLine() dict "{{{3
    if !empty(g:vikitasks#ft#vikibase#after_change_line_exec)
        exec g:vikitasks#ft#vikibase#after_change_line_exec
    endif
endf


function! vikitasks#ft#vikibase#GetInstance() "{{{3
    return s:prototype
endf


