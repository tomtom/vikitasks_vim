" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    1967

scriptencoding utf-8


" A list of glob patterns (or files) that will be searched for task 
" lists.
" Can be buffer-local.
" If you add ! to 'viminfo', this variable will be automatically saved 
" between editing sessions.
" Alternatively, add new items in ~/vimfiles/after/plugin/vikitasks.vim
TLet g:vikitasks#files = []

" A list of |regexp| patterns for filenames that should not be 
" scanned.
TLet g:vikitasks#files_ignored = ['_archived\.[^.]\+$']
let s:files_ignored = join(g:vikitasks#files_ignored, '\|')

" If true, completely ignore completed tasks.
TLet g:vikitasks#ignore_completed_tasks = 1

" If true, obey threshold information (t:YYYY-MM-DD), i.e. don't show 
" the task before this date.
TLet g:vikitasks#use_threshold = 1

" If the value is > 0 and no t: option (see see 
" |g:vikitasks#use_threshold|) is given for a task, hide tasks whose due 
" date is more than N days in the future.
"
" The value will be ignored if |g:vikitasks#use_threshold| is false.
TLet g:vikitasks#threshold_days = 90

" If non-false, provide tighter integration with the vim viki plugin.
TLet g:vikitasks#sources = {
            \ 'viki': exists('g:loaded_viki'),
            \ 'todotxt': 1
            \ }

" A dictionary of 'filetype' => source (see |g:vikitasks#sources|).
"
" By default vikitasks expects todo.txt files to have the filetype 
" |todotxt| (which is used by the todo.txt plugin found at 
" https://github.com/davidoc/todo.txt-vim and my own fork at 
" https://github.com/tomtom/todo.txt-vim-1/). Using this map allows 
" users to use todo.txt plugins that use the filetype "todo" (e.g. 
" https://github.com/freitass/todo.txt-vim).
TLet g:vikitasks#filetype_map = {
            \ 'txt': 'viki',
            \ 'todo': 'todotxt'
            \ }

" Default category/priority when converting tasks without priorities.
TLet g:vikitasks#default_priority = 'F'

" The viewer for the quickfix list. If empty, use |:TRagcw|.
TLet g:vikitasks#qfl_viewer = ''

" Item classes that should be included in the list when calling 
" |:VikiTasks|.
" A user-defined value must be set in |vimrc| before the plugin is 
" loaded.
TLet g:vikitasks#rx_categories = 'A-P'

" Item levels that should be included in the list when calling 
" |:VikiTasks|.
" A user-defined value must be set in |vimrc| before the plugin is 
" loaded.
TLet g:vikitasks#rx_levels = '1-5'

" If non-empty, vikitasks will insert a break line when displaying a 
" list in the background.
TLet g:vikitasks#today = 'DUE'

" Cache file name.
" By default, use |tlib#cache#Filename()| to determine the file name.
TLet g:vikitasks#cache = tlib#cache#Filename('vikitasks', 'files', 1)
call add(g:tlib#cache#dont_purge, '[\/]vikitasks[\/]files$')

" If true, check whether the mtime of files with cached tasks has 
" changed and update the info as necessary.
TLet g:vikitasks#cache_check_mtime_rx = '.'

" Definition of the tasks that should be included in the Alarms list.
" Fields:
"   all_tasks  ... If non-null, also display tasks with no due-date
"   tasks      ... Either 'tasks' or 'sometasks'
"   constraint ... See |:VikiTasks|
TLet g:vikitasks#alarms = {'all_tasks': 0, 'tasks': 'sometasks', 'persistent_categories': 'A', 'constraint': 14}

" If true, the end-date of date ranges (FROM..TO) is significant.
TLet g:vikitasks#use_end_date = 1

" Interpret entries with an unspecified date ("_") as current tasks.
TLet g:vikitasks#use_unspecified_dates = 1

" If true, remove unreadable files from the tasks list.
TLet g:vikitasks#remove_unreadable_files = 1

" |:execute| a command (as string) after changing a line.
" A useful value is |:update|.
TLet g:vikitasks#after_change_line_exec = ''

" |:execute| a command (as string) after changing a buffer.
" A useful value is |:update|.
TLet g:vikitasks#after_change_buffer_exec = ''

" If true, save _all_ modified buffers via |:wall|, when leaving the 
" tasks list.
TLet g:vikitasks#auto_save = 0

" The parameters for |:TRagcw| when |g:vikitasks#qfl_viewer| is empty.
" :read: TLet g:vikitasks#inputlist_params = {...}
" :nodoc:
TLet g:vikitasks#inputlist_params = {
            \ 'trag_short_filename': 1,
            \ 'index_next_syntax': 'vikitasksItem',
            \ 'GetBufferLines': function('vikitasks#GetBufferLines'),
            \ 'on_leave': ['vikitasks#OnLeave'],
            \ 'scratch': '__VikiTasks__',
            \ 'key_map': {
            \     'default': {
            \         "\<f2>" : {'key': "\<f2>", 'agent': 'vikitasks#AgentKeymap', 'key_name': '<f2>', 'help': 'Switch to vikitasks keymap'},
            \             24 : {'key': 24, 'agent': 'vikitasks#AgentMarkDone', 'key_name': '<c-x>', 'help': 'Mark done'},
            \             4 : {'key': 4, 'agent': 'vikitasks#AgentDueDays', 'key_name': '<c-d>', 'help': 'Mark as due in N days'},
            \             23 : {'key': 23, 'agent': 'vikitasks#AgentDueWeeks', 'key_name': '<c-w>', 'help': 'Mark as due in N weeks'},
            \             3 : {'key': 3, 'agent': 'vikitasks#AgentItemChangeCategory', 'key_name': '<c-c>', 'help': 'Change task category'},
            \             14 : {'key': 14, 'agent': 'vikitasks#AgentPaste', 'key_name': '<c-n>', 'help': 'Paste selected items in a new buffer'},
            \     },
            \     'vikitasks': extend(copy(g:tlib#input#keyagents_InputList_s),
            \         {
            \             char2nr('x') : {'agent': 'vikitasks#AgentMarkDone', 'key_name': 'x', 'help': 'Mark done'},
            \             char2nr('d')  : {'agent': 'vikitasks#AgentDueDays', 'key_name': 'd', 'help': 'Mark as due in N days'},
            \             char2nr('w')  : {'agent': 'vikitasks#AgentDueWeeks', 'key_name': 'w', 'help': 'Mark as due in N weeks'},
            \             char2nr('c') : {'agent': 'vikitasks#AgentItemChangeCategory', 'key_name': 'c', 'help': 'Change task category'},
            \            'unknown_key': {'agent': 'tlib#agent#Null', 'key_name': 'other keys', 'help': 'ignore key'},
            \         }
            \     )
            \ }
            \ }
            " \ 'AfterRunCmd': function('vikitasks#ScanCurrentBuffer'),

" Mapleader for some vikitasks related maps.
TLet g:vikitasks#mapleader = '<LocalLeader>t'

" If true, add a date tag when marking a task done with |vikitasks#ItemMarkDone()|.
TLet g:vikitasks#done_add_date = 1

" A vim expression that returns the filename of the archive where 
" archived tasks should be moved to.
TLet g:vikitasks#archive_filename_fmt = '"%s_archived". g:vikiNameSuffix'

" A list of strings. The header for newly created tasks archives.
TLet g:vikitasks#archive_header = ['* Archived tasks']

" The date format string (see |strftime()|).
TLet g:vikitasks#date_fmt = "%Y-%m-%d"

" The date format string (see |strftime()|) for archived entries.
TLet g:vikitasks#archive_header_fmt = "** " . g:vikitasks#date_fmt

" Letters of final categories, i.e. tasks that should not be altered 
" after assigning them to one of these categories.
"
" Tasks in these categories will be considered suitable candidates for 
" automatic archival by |vikitasks#ItemArchiveFinal()|.
"
" By default the following categories are considered final:
"   X ... done
"   Y ... cancelled
"   Z ... ???
TLet g:vikitasks#final_categories = 'XYZ'

" If non-empty, use |:Calendar| as date picker when marking an item as 
" due in N days. 
"
" NOTE: This experimental feature is disabled by default. Enable it by 
" setting this variable to, e.g., "Calendar" in your |vimrc| file.
TLet g:vikitasks#use_calendar = ''
" TLet g:vikitasks#use_calendar = exists(':Calendar') ? 'Calendar' : ''

" Define how to format the list when calling |:VikiTasksPaste|.
" A dictionary with the fields (default values are marked with "*"):
"   filename: add*|group|none
TLet g:vikitasks#paste = {}

TLet g:vikitasks#debug = 0

" If non-null, convert cygwin filenames to windows format.
TLet g:vikitasks#convert_cygwin = has('win32unix') && executable('cygpath')


let s:tasks_rx = {}

function! vikitasks#TasksRx(which_tasks, ...) "{{{3
    if a:0 >= 1
        if type(a:1) == 4
            let filetype = a:1.GetFiletype()
        else
            let filetype = a:1
        endif
    else
        let filetype = 'viki'
    endif
    if has_key(get(s:tasks_rx, filetype, {}), a:which_tasks)
        return s:tasks_rx[filetype][a:which_tasks]
    else
        let ftdef = vikitasks#ft#{filetype}#GetInstance()
        let fmt = ftdef[a:which_tasks .'_rx']
        if fmt =~ '%s'
            let rv = printf(fmt, '.*')
        else
            let rv = fmt
        endif
        if !has_key(s:tasks_rx, filetype)
            let s:tasks_rx[filetype] = {}
        endif
        let s:tasks_rx[filetype][a:which_tasks] = rv
        return rv
    endif
endf


let g:vikitasks#date_rx = '\d\+-\d\+-\d\+\>'
let g:vikitasks#viki_date_rx = printf('\C^\s*#[A-Z0-9]\+\s\+\zs\(x\?\)\(_\|%s\)\(\.\.\(\(_\|%s\)\)\)\?\ze\s', g:vikitasks#date_rx, g:vikitasks#date_rx)


" :nodoc:
function! vikitasks#GetArgs(bang, list) "{{{3
    let args = {}
    let args.cached = !a:bang
    let a0 = get(a:list, 0, '.')
    let files_idx = 2
    " TLogVAR a0
    if a0 =~ '^\(t\%[oday]\|c\%[urrent]\|w\%[eek]\|m\%[onth]\|[+-]\?\d\+[dwm]\?\|[.*]\)$'
        let args.all_tasks = a0 =~ '^[.*]$'
        let args.tasks = a0 =~ '^[*-]' ? 'tasks' : 'sometasks'
        let args.constraint = a0
        if !empty(a:list)
            call remove(a:list, 0)
            let files_idx -= 1
        endif
    else
        let args.all_tasks = 1
        let args.tasks = 'sometasks'
        let args.constraint = '.'
    endif
    let args.rx = s:MakePattern(get(a:list, 0, '.'))
    let args.files = a:list[files_idx : -1]
    let args.ignore_completed = g:vikitasks#ignore_completed_tasks
    " TLogVAR args
    return args
endf


function! s:GetTasks(args, use_cached) "{{{3
    " TLogVAR a:args, a:use_cached
    if a:use_cached
        let qfl = copy(s:GetCachedTasks())
        let files = get(a:args, 'files', [])
        " TLogVAR files
        if !empty(files)
            " TLogVAR filter(copy(files), 'v:val =~ ''\CAcademia.txt$''')
            for file in files
                let file_rx = vikitasks#Glob2Rx(file)
                call filter(qfl, '(has_key(v:val, "filename") ? v:val.filename : bufname(v:val.bufnr)) =~ file_rx')
            endfor
        endif
        if !empty(g:vikitasks#cache_check_mtime_rx)
            let file_defs = s:GetCachedFiles()
            " TLogVAR file_defs
            let cfiles = map(copy(qfl), 's:CanonicFilename(v:val.filename)')
            let cfiles = tlib#list#Uniq(cfiles, '', 1)
            " TLogVAR filter(copy(cfiles), 'v:val =~ ''\CAcademia.txt$''')
            if !empty(cfiles)
                let update = {}
                let remove = []
                for cfilename in cfiles
                    " TLogVAR cfilename
                    if cfilename =~ g:vikitasks#cache_check_mtime_rx
                        " TLogVAR cfilename
                        if filereadable(cfilename)
                            let mtime = getftime(cfilename)
                            let cmtime = get(get(file_defs, cfilename, {}), 'mtime', 0)
                            " TLogVAR cfilename, mtime, cmtime
                            " TLogVAR get(file_defs,cfilename,{})
                            if mtime > cmtime
                                " TLogVAR mtime>cmtime
                                if has_key(file_defs, cfilename)
                                    let filetype = file_defs[cfilename].filetype
                                    if !has_key(update, cfilename)
                                        let update[filetype] = []
                                    endif
                                    call add(update[filetype], cfilename)
                                else
                                    echom 'VikiTasks: GetTasks: Internal error: No info about' cfilename
                                    " echom 'DBG' string(keys(file_defs))
                                endif
                            endif
                        else
                            call add(remove, cfilename)
                        endif
                    endif
                endfor
                if !empty(update)
                    for [filetype, cfiles] in items(update)
                        let [file_defs, tasks] = s:UpdateFiles(cfiles, filetype)
                    endfor
                    let qfl = copy(tasks)
                endif
                if !empty(remove)
                    call s:RemoveFiles(remove)
                endif
            endif
        endif
        return qfl
    else
        if g:vikitasks#sources.viki && s:GetBufferFiletype() != 'viki' && !viki#HomePage()
            echoerr "VikiTasks: Not a viki buffer and cannot open the homepage"
            return
        endif
        let files = get(a:args, 'files', [])
        " TLogVAR files
        if empty(files)
            let [files, file_defs] = s:CollectTaskFiles(0)
            " TLogVAR filter(copy(files), 'v:val =~ ''\<Academia.txt$''')
            " TLogVAR files
        else
            let file_defs = {}
        endif
        " TAssertType files, 'list'
        " TLogVAR files
        call map(files, 'glob(v:val)')
        let files = split(join(files, "\n"), '\n')
        let cfiles = map(files, 's:CanonicFilename(v:val)')
        let cfiles = tlib#list#Uniq(cfiles, '', 1)
        " TLogVAR len(cfiles)
        " TLogVAR cfiles
        if !empty(cfiles)
            let [new_file_defs, new_tasks] = s:ScanFiles(cfiles, '', file_defs)
            " TLogVAR len(new_file_defs), len(new_tasks)
            let [file_defs, tasks] = s:MergeInfo(new_file_defs, new_tasks, file_defs, [])
            return tasks
        else
            throw "VikiTasks: No task files"
        endif
    endif
endf


function! s:RemoveFiles(cfiles) "{{{3
    " TLogVAR a:cfiles
    let file_defs = s:GetCachedFiles()
    let tasks = s:GetCachedTasks()
    for cfilename in a:cfiles
        if has_key(file_defs, cfilename)
            call remove(file_defs, cfilename)
        endif
        let tasks = filter(tasks, 'v:val.filename != cfilename')
    endfor
    call s:SaveInfo(file_defs, tasks)
endf


function! s:UpdateFiles(cfiles, filetype) "{{{3
    if !empty(a:cfiles)
        " let cfiles = map(a:cfiles, 's:CanonicFilename(v:val)')
        let cfiles = a:cfiles
        " TLogVAR len(cfiles)
        " TLogVAR cfiles
        let [new_file_defs, new_tasks] = s:ScanFiles(cfiles, a:filetype)
        " TLogVAR len(new_file_defs), len(new_tasks)
        " TLogVAR new_file_defs, new_tasks
        " call s:SetTimestamp(file_defs, a:cfiles)
        if !empty(new_tasks)
            return s:MergeInfo(new_file_defs, new_tasks)
        endif
    endif
    let file_defs = s:GetCachedFiles()
    let tasks = s:GetCachedTasks()
    return [file_defs, tasks]
endf


" new_file_defs ... The file definitions for the files in new_tasks
" new_tasks ... A tasks list
function! s:MergeInfo(new_file_defs, new_tasks, ...) "{{{3
    " TLogVAR len(a:new_file_defs), len(a:new_tasks)
    " TLogVAR a:new_tasks
    let file_defs0 = a:0 >= 1 ? a:1 : s:GetCachedFiles()
    let tasks0 = a:0 >= 2 ? a:2 : s:GetCachedTasks()
    " TLogVAR len(file_defs0), len(tasks0)
    let new_file_defs = s:SetTimestamp(a:new_file_defs)
    " TLogVAR a:new_file_defs, new_file_defs
    " TLogVAR len(new_file_defs)
    " TLogVAR keys(new_file_defs)[0 : 20]
    " TLogVAR map(copy(tasks0), 'v:val.filename')[0 : 20]
    let file_defs = filter(copy(file_defs0), '!has_key(new_file_defs, v:key )')
    let tasks = filter(copy(tasks0), '!has_key(new_file_defs, v:val.filename)')
    " TLogVAR tasks
    " TLogVAR len(file_defs), len(tasks)
    let file_defs = extend(file_defs, new_file_defs)
    let tasks += a:new_tasks
    " TLogVAR len(file_defs), len(tasks)
    call s:SaveInfo(file_defs, tasks)
    return [file_defs, tasks]
endf


function! s:SetTimestamp(file_defs, ...) "{{{3
    let cfilenames = a:0 >= 1 ? a:1 : []
    let file_defs = a:file_defs
    for cfilename in keys(file_defs)
        if empty(cfilenames) || index(cfilenames, cfilename) != -1
            let mtime = getftime(cfilename)
            let file_defs[cfilename]['mtime'] = mtime
        endif
    endfor
    return file_defs
endf


let s:did_init_trag = 0

function! s:InitTrag() "{{{3
    if !s:did_init_trag
        for [source, enabled] in items(g:vikitasks#sources)
            if enabled
                call vikitasks#ft#{source}#GetInstance()
            endif
        endfor
        let s:did_init_trag = 1
    endif
endf


function! s:ScanFiles(cfiles, ...) "{{{3
    let filetype0 = a:0 >= 1 ? a:1 : ''
    let file_defs = a:0 >= 2 ? a:2 : s:GetCachedFiles()
    " TLogVAR len(a:cfiles), filetype0
    call s:InitTrag()
    let qfl = trag#Grep('tasks', 1, copy(a:cfiles), filetype0)
    " TLogVAR len(qfl)
    " TLogVAR qfl
    " TLogVAR filter(copy(qfl), 'v:val.text =~ "#D7"')
    " TLogVAR keys(file_defs)
    " TLogVAR filter(copy(a:cfiles), 'v:val =~ ''\Ctodo.txt$''')
    " TLogVAR filter(keys(file_defs), 'v:val =~ ''\Ctodo.txt$''')
    let new_file_defs = {}
    for cfilename in a:cfiles
        " TLogVAR cfilename, has_key(file_defs,cfilename)
        if has_key(file_defs, cfilename)
            let new_file_defs[cfilename] = file_defs[cfilename]
        else
            let filetype = empty(filetype0) ? s:GetFiletype(cfilename) : filetype0
            call s:MaybeRegisterFilename(new_file_defs, cfilename, filetype, '')
        endif
    endfor
    let new_tasks = copy(qfl)
    " TLogVAR len(file_defs), len(new_file_defs), len(new_tasks)
    " TLogVAR file_defs
    " TLogVAR new_file_defs
    " TLogVAR new_tasks
    let remove_tasks = []
    let ntasks = len(new_tasks)
    call tlib#progressbar#Init(ntasks, 'VikiTasks: Scan %s', 20)
    try
        for i in range(ntasks)
            " TLogVAR new_tasks[i]
            let bufnr = new_tasks[i].bufnr
            if bufnr > 0
                let cfilename = s:CanonicFilename(fnamemodify(bufname(bufnr), ':p'))
                call tlib#progressbar#Display(i, ' '. pathshorten(cfilename))
                " TLogVAR cfilename
                let new_tasks[i].filename = cfilename
                " let filetype = empty(filetype0) ? s:GetFiletype(cfilename) : filetype0
                let these_file_defs = has_key(new_file_defs, cfilename) ? new_file_defs : file_defs
                if has_key(these_file_defs, cfilename)
                    let file_def = these_file_defs[cfilename]
                    let filetype = file_def.filetype
                    " if filetype != 'viki'
                    let new_tasks[i].text = s:ConvertLine(these_file_defs, cfilename, filetype, new_tasks[i].text)
                    " endif
                    if empty(new_tasks[i].text)
                        call add(remove_tasks, i)
                    else
                        call remove(new_tasks[i], 'bufnr')
                    endif
                else
                    echohl WarningMsg
                    echom 'VikiTasks: Internal error: No filedef for' has_key(new_file_defs, cfilename) has_key(file_defs, cfilename) bufnr string(cfilename)
                    echohl NONE
                endif
            endif
        endfor
    finally
        call tlib#progressbar#Restore()
    endtry
    " TLogVAR remove_tasks
    for i in remove_tasks
        call remove(new_tasks, i)
    endfor
    " TLogVAR len(new_file_defs), len(new_tasks)
    return [new_file_defs, new_tasks]
endf


" :display: vikitasks#Tasks(?{'all_tasks': 0, 'cached': 1, 'files': [], 'constraint': '', 'rx': ''}, ?suspend=0)
" If files is non-empty, use these files (glob patterns actually) 
" instead of those defined in |g:vikitasks#files|.
" 
" suspend must be one of:
"   -1 ... Don't display a list
"    0 ... List takes the focus
"    1 ... Current buffer takes the focus
function! vikitasks#Tasks(...) "{{{3
    TVarArg ['args', {}], ['suspend', 0]
    " TLogVAR args, suspend
    let qfl = s:GetTasks(args, get(args, 'cached', 1))
    if !empty(qfl)
        call s:TasksList(qfl, args, suspend)
    endif
endf


function! s:ConvertLine(file_defs, cfilename, filetype, line) "{{{3
    let ftdef = vikitasks#ft#{a:filetype}#GetInstance()
    if !empty(a:line) && has_key(ftdef, 'ConvertLine')
        let ftdef = vikitasks#ft#{a:filetype}#GetInstance()
        let line = ftdef.ConvertLine(a:line)
        if !empty(line) && line =~ vikitasks#TasksRx('tasks', ftdef)
            if !has_key(a:file_defs, a:cfilename)
                throw 'VikiTasks: Internal error: No filedef for '. a:cfilename
            else
                let mapsource = get(a:file_defs[a:cfilename], 'mapsource', {})
                let mapsource[a:line] = line
                let a:file_defs[a:cfilename].mapsource = mapsource
                " TLogVAR a:filetype, a:line, line
            endif
        endif
    else
        let line = a:line
    endif
    let line = s:CleanLine(line)
    return line
endf


function! s:CleanLine(line) "{{{3
    let line = substitute(a:line, '\<t:'. g:vikitasks#date_rx .'\s*', '', 'g')
    return line
endf


function! s:TasksList(qfl, args, suspend) "{{{3
    " TLogVAR a:qfl, a:args, a:suspend
    let qfl = a:qfl
    call s:FilterTasks(qfl, a:args)
    call sort(qfl, "s:SortTasks")
    let i = s:GetCurrentTask(qfl, 0)
    call s:Setqflist(qfl, a:suspend ? i : -1)
    if a:suspend >= 0
        call s:View(i, a:suspend)
    endif
endf


function! s:DueText() "{{{3
    let break = repeat('- ', (&columns - 20 - len(g:vikitasks#today)) / 4)
    let break = substitute(break, ' $', '', '')
    let text = join([break, g:vikitasks#today, break])
    return text
endf


function! s:Setqflist(qfl, today) "{{{3
    " TLogVAR a:today, len(a:qfl)
    if !empty(g:vikitasks#today) && len(a:qfl) > 1 && a:today > 1 && a:today <= len(a:qfl)
        let qfl = insert(a:qfl, {'bufnr': 0, 'text': s:DueText()}, a:today - 1)
        call setqflist(qfl)
    else
        call setqflist(a:qfl)
    endif
endf


function! s:FileReadable(filename, cache) "{{{3
    let readable = get(a:cache, a:filename, -1)
    if readable >= 0
        return readable
    else
        let a:cache[a:filename] = filereadable(a:filename)
        return a:cache[a:filename]
    endif
endf


function! s:FilterTasks(tasks, args) "{{{3
    " TLogVAR len(a:tasks), a:args

    let rx = get(a:args, 'rx', '')
    if !empty(rx)
        call filter(a:tasks, 'v:val.text =~ rx')
    endif

    if g:vikitasks#remove_unreadable_files
        let filenames = {}
        call filter(a:tasks, 's:FileReadable(v:val.filename, filenames)')
    endif

    let ignore_completed = get(a:args, 'ignore_completed', g:vikitasks#ignore_completed_tasks)
    if ignore_completed
        call filter(a:tasks, 'empty(get(matchlist(v:val.text, g:vikitasks#viki_date_rx), 1, ""))')
    endif

    let which_tasks = get(a:args, 'tasks', 'tasks')
    " TLogVAR which_tasks
    if which_tasks == 'sometasks'
        let rx = vikitasks#TasksRx('sometasks')
        " TLogVAR rx
        " TLogVAR len(a:tasks)
        call filter(a:tasks, 'v:val.text =~ rx')
        " TLogVAR len(a:tasks)
    endif

    if !get(a:args, 'all_tasks', 0)
        call filter(a:tasks, '!empty(s:GetTaskDueDate(v:val.text, 0, g:vikitasks#use_unspecified_dates, a:args))')
        " TLogVAR len(a:tasks)

        let constraint = get(a:args, 'constraint', '.')
        " TLogVAR constraint
        if constraint !~ '^[+-]\?\d\+'
            let future = ''
            let n = 1
        else
            let [m0, future, n; _] = matchlist(constraint, '^\([+-]\?\)\(\d\+\)')
        endif
        let from = empty(future) ? 0 : localtime()
        let to = 0
        if constraint =~ '^t\%[oday]'
            let from = localtime()
            let to = from
        elseif constraint =~ '^c\%[urrent]'
            let from = 0
            let to = localtime()
        elseif constraint =~ '^m\%[onth]'
            let to = localtime() + 86400 * 31
        elseif constraint == 'w\%[eek]'
            let to = localtime() + 86400 * 7
        elseif constraint =~ '^[+-]\?\d\+[dwm]\?$'
            let to = localtime()
            let delta = n * 86400
            if constraint =~ 'w$'
                let delta = delta * 7
            elseif constraint =~ 'm$'
                let delta = delta * 31
            endif
            if constraint =~ '^-'
                let from -= delta
            else
                let to += delta
            endif
        else
            echoerr "vikitasks: Malformed constraint: ". constraint
        endif
        " TLogVAR from, to
        if from != 0 || to != 0
            call filter(a:tasks, 's:Select(v:val.text, from, to, a:args)')
        endif

        let use_threshold = get(a:args, 'use_threshold', g:vikitasks#use_threshold)
        if use_threshold
            let today = strftime(g:vikitasks#date_fmt)
            if g:vikitasks#threshold_days > 0
                let threshold_date = strftime(g:vikitasks#date_fmt, localtime() + g:vikitasks#threshold_days * g:tlib#date#dayshift)
            else
                let threshold_date = ''
            endif
            call filter(a:tasks, 's:IsThresholdOk(v:val.text, today, threshold_date)')
        endif
    endif
endf


function! s:View(index, suspend) "{{{3
    let bufnr = bufnr('%')
    if empty(g:vikitasks#qfl_viewer)
        let w = deepcopy(g:vikitasks#inputlist_params)
        if a:index > 1
            let w.initial_index = a:index
        endif
        let w.format_item = 'vikitasks#FormatQFLE(v:val, s:world)'
        let w.set_syntax = 'vikitasks#SetSyntax'
        let w.dueline = s:DueText()
        call trag#QuickList(w, a:suspend)
    else
        exec g:vikitasks#qfl_viewer
    endif
    if a:suspend && bufnr != bufnr('%')
        let bufwinnr = bufwinnr(bufnr)
        exec bufwinnr 'wincmd w'
    endif
endf


function! vikitasks#SetSyntax() dict "{{{3
    syn match TTagedFilesFilenameSep / | /
    syn match TTagedFilesFilename / | [^|]*$/ contains=TTagedFilesFilenameSep
    hi def link TTagedFilesFilenameSep Special
    hi def link TTagedFilesFilename Directory
    let b:vikiMarkInexistent = 0
    runtime syntax/viki.vim
    if has('conceal')
        syn match vikitasksDates /\s*\(created\|t\):\d\+-\d\+-\d\+/ contained conceal
    endif
    syn match vikitasksItem /#\(T: \+.\{-}\u.\{-}:\|\d*\u\d*\)\s.*$/ contains=vikiContact,vikiTag,@vikiPriorityListTodo,@vikiText,TTagedFilesFilename,vikitasksDates
endf


function! vikitasks#FormatQFLE(qfe, world) "{{{3
    let text = get(a:qfe, "text")
    let filename = trag#GetFilename(a:qfe)
    if empty(filename) || text == a:world.dueline
        return text
    else
        if get(a:world, 'trag_short_filename', '')
            let filename = pathshorten(filename)
        endif
        return printf("%-". (&co / 2) ."s | %s#%d", text, filename, a:qfe.lnum)
    endif
endf


" The |regexp| PATTERN is prepended with |\<| if it seems to be a word. 
" The PATTERN is made case sensitive if it contains an upper-case letter 
" and if 'smartcase' is true.
function! s:MakePattern(pattern) "{{{3
    let pattern = a:pattern
    if empty(pattern)
        let pattern = '.'
    elseif pattern != '.'
        if pattern =~ '^\w'
            let pattern = '\<'. pattern
        endif
        if &smartcase && pattern =~ '\u'
            let pattern = '\C'. pattern
        endif
    endif
    return pattern
endf


function! s:GetTaskCategory(task) "{{{3
    let c = matchstr(a:task, '^\s*#\d*\zs\u')
    return c
endf


function! s:GetTaskDueDate(task, use_end_date, use_unspecified, args) "{{{3
    let m = matchlist(a:task, g:vikitasks#viki_date_rx)
    if a:use_end_date && g:vikitasks#use_end_date
        let rv = get(m, 4, '')
    elseif has_key(a:args, 'persistent_categories') && s:GetTaskCategory(a:task) =~ '^['. a:args.persistent_categories .']$'
        let rv = '_'
    else
        let rv = ''
    endif
    if empty(rv)
        let rv = get(m, 2, '')
    endif
    if rv == '_' && !a:use_unspecified
        let rv = ''
    endif
    " TLogVAR a:task, m, rv
    return rv
endf


function! s:IsThresholdOk(task, today, threshold_date) "{{{3
    " TLogVAR a:task, a:today
    let t = matchstr(a:task, '\<t:\zs'. g:vikitasks#date_rx)
    if !empty(t)
        let rv = t <= a:today
    elseif empty(a:threshold_date)
        let rv = 1
    else
        let date = s:GetTaskDueDate(a:task, 0, 0, {})
        let rv = empty(date) || date == '_' || date <= a:threshold_date
    endif
    " TLogVAR t, rv
    return rv
endf


function! s:GetCurrentTask(qfl, daysdiff) "{{{3
    " TLogVAR a:daysdiff
    let i = 1
    let today = strftime(g:vikitasks#date_fmt)
    for qi in a:qfl
        let qid = s:GetTaskDueDate(qi.text, 1, g:vikitasks#use_unspecified_dates, {})
        if !empty(qid) && qid != '_' && tlib#date#DiffInDays(qid, today, 1) <= a:daysdiff
            " let ddays = tlib#date#DiffInDays(qid,today,1)  " DBG
            " TLogVAR qid, today, ddays
            let i += 1
        else
            break
        endif
    endfor
    " TLogVAR i
    return i
endf


function! s:SortTasks(a, b) "{{{3
    let a = a:a.text
    let b = a:b.text
    let ad = s:GetTaskDueDate(a, 1, g:vikitasks#use_unspecified_dates, {})
    let bd = s:GetTaskDueDate(b, 1, g:vikitasks#use_unspecified_dates, {})
    if ad && !bd
        return -1
    elseif !ad && bd
        return 1
    elseif ad && bd && ad != bd
        return ad > bd ? 1 : -1
    else
        return a == b ? 0 : a > b ? 1 : -1
    endif
endf


function! vikitasks#ResetCachedInfo() "{{{3
    let s:file_defs = {}
    let s:tasks = []
    call s:SaveInfo(s:file_defs, s:tasks)
endf


function! s:GetCachedFiles() "{{{3
    if !exists('s:file_defs')
        let cdata = s:GetInfo()
        let s:file_defs = get(cdata, 'file_defs', {})
        " echom "DBG file_defs" string(s:file_defs)
        if empty(s:file_defs)
            let files = get(cdata, 'files', [])
            for file in files
                let cfilename = s:CanonicFilename(file)
                call vikitasks#RegisterFilename(cfilename, s:GetFiletype(cfilename), '')
            endfor
        endif
    endif
    return s:file_defs
endf


function! s:GetCachedTasks() "{{{3
    if !exists('s:tasks')
        let s:tasks = get(s:GetInfo(), 'tasks', [])
        " echom "DBG ntasks = ". len(s:tasks)
    endif
    return s:tasks
endf


function! s:GetInfo() "{{{3
    if !exists('s:cdata')
        let s:cdata = tlib#cache#Get(g:vikitasks#cache)
    endif
    return s:cdata
endf


function! s:SaveInfo(file_defs, tasks) "{{{3
    " TLogVAR len(a:file_defs), len(a:tasks)
    let s:file_defs = a:file_defs
    let s:tasks = a:tasks
    let s:timestamp = localtime()
    let s:cdata = {'file_defs': a:file_defs, 'tasks': a:tasks, 'timestamp': s:timestamp}
    call tlib#cache#Save(g:vikitasks#cache, s:cdata)
endf


function vikitasks#MustUseCanonicFilename()
    return !has('fname_case') || g:tlib#dir#sep == '\'
endf


let s:cygpath = {}

function! s:CanonicFilename(filename) "{{{3
    if !vikitasks#MustUseCanonicFilename()
        return a:filename
    else
        let filename = a:filename
        if g:vikitasks#convert_cygwin && filename !~ '^\c[a-z]:'
            if !has_key(s:cygpath, filename)
                let s:cygpath[filename] = substitute(system('cygpath -m '. shellescape(filename)), '\n$', '', '')
            endif
            let filename = s:cygpath[filename]
            " TLogVAR a:filename, filename
        endif
        if !has('fname_case')
            let filename = tolower(filename)
        endif
        if g:tlib#dir#sep == '\'
            let filename = substitute(filename, '\\', '/', 'g')
        endif
        if filename !~ '^\w\+://'
            let filename = substitute(filename, '//\+', '/', 'g')
        endif
        return filename
    endif
endf


function! vikitasks#EachSource(fallback, fn, args, params) "{{{3
    let rvs = {}
    for [source, ok] in items(g:vikitasks#sources)
        if source != a:fallback
            let ftdef = vikitasks#ft#{source}#GetInstance()
            let rv = call(ftdef[a:fn], a:args, ftdef)
            let rvs[source] = rv
            if has_key(a:params, 'Check') && a:params.Check(rv)
                return [source, rv]
            else
            endif
            unlet rv
        endif
    endfor
    let ftdef = vikitasks#ft#{a:fallback}#GetInstance()
    let rv = call(ftdef[a:fn], a:args, ftdef)
    let rvs[a:fallback] = rv
    if has_key(a:params, 'Check')
        return [a:fallback, rv]
    else
        return rvs
    endif
endf


let s:find_params = {}
function s:find_params.Check(val) dict
    return !empty(a:val)
endf


function! s:GetFileSource(cfilename, filetype) "{{{3
    return vikitasks#EachSource(s:TaskSource(a:filetype), 'IsA', [a:cfilename], s:find_params)
endf


function! s:GetBufferFiletype(...) "{{{3
    let bufnr = a:0 >= 1 ? a:1 : bufnr('%')
    let ft = getbufvar(bufnr, '&filetype')
    return get(g:vikitasks#filetype_map, ft, ft)
endf


function! s:GetFiletype(...) "{{{3
    let cfilename = a:0 >= 1 ? a:1 : s:CanonicFilename(expand('%:p'))
    let filetype = a:0 >= 2 ? a:2 : ''
    let on_error = a:0 >= 3 ? a:3 : 0
    let [ft, ok] = s:GetFileSource(cfilename, filetype)
    if !ok
        if on_error == 2
            throw 'VikiTasks: Unsupported filetype: '. filetype
        elseif on_error == 1
            return ''
        endif
    endif
    return ft
endf


function! s:GetArchiveName(filename, filetype) "{{{3
    let cfilename = s:CanonicFilename(a:filename)
    let [ft, archive] = vikitasks#EachSource(s:TaskSource(a:filetype), 'GetArchiveName', [cfilename], s:find_params)
    return archive
endf


function! s:CollectTaskFiles(reset) "{{{3
    if a:reset
        call vikitasks#ResetCachedInfo()
    endif
    let file_defs = s:GetCachedFiles()
    " TLogVAR filter(keys(file_defs), 'v:val =~ ''\Ctodo.txt$''')
    for [source, ok] in items(g:vikitasks#sources)
        " TLogVAR source, ok
        if ok
            let ftdef = vikitasks#ft#{source}#GetInstance()
            call ftdef.GetFiles(function('vikitasks#RegisterFilename'))
        endif
    endfor
    let taskfiles = sort(keys(s:file_defs))
    " TLogVAR filter(copy(taskfiles), 'v:val =~ ''\Ctodo.txt$''')
    " TLogVAR taskfiles
    " TLogVAR len(taskfiles)
    return [taskfiles, s:file_defs]
endf


function! vikitasks#UnRegisterFilename(filename) "{{{3
    let cfilename = s:CanonicFilename(a:filename)
    if has_key(s:file_defs, cfilename)
        call remove(s:file_defs, cfilename)
    endif
endf


function! vikitasks#RegisterFilename(dirpattern, filetype, archive, ...) "{{{3
    TVarArg 'ignore_rx'
    " TLogVAR a:dirpattern, a:filetype, a:archive, ignore_rx
    for filename in split(glob(a:dirpattern), '\n')
        if filereadable(filename) && !isdirectory(filename)
            let cfilename = s:CanonicFilename(filename)
            if empty(ignore_rx) || filename !~ ignore_rx
                call s:MaybeRegisterFilename(s:file_defs, cfilename, a:filetype, a:archive)
            endif
            " TLogVAR cfilename
        endif
    endfor
endf


function! s:MaybeRegisterFilename(file_defs, cfilename, filetype, archive) "{{{3
    " if a:cfilename =~ '\Ctodo.txt$' | echom "DBG MaybeRegisterFilename" a:cfilename | endif " DBG
    if !has_key(a:file_defs, a:cfilename) && a:cfilename !~ s:files_ignored
        let a:file_defs[a:cfilename] = {'filetype': a:filetype}
        " TLogVAR a:cfilename, a:filetype, a:archive
        if !empty(a:archive)
            let a:file_defs[a:cfilename].archive = a:archive
        endif
        return 1
    endif
    return 0
endf


function! s:Select(text, from, to, args) "{{{3
    let sfrom = strftime(g:vikitasks#date_fmt, a:from)
    let sto = strftime(g:vikitasks#date_fmt, a:to)
    let date1 = s:GetTaskDueDate(a:text, 0, g:vikitasks#use_unspecified_dates, a:args)
    let date2 = s:GetTaskDueDate(a:text, 1, g:vikitasks#use_unspecified_dates, a:args)
    if date1 == '_'
        let rv = 1
    elseif date1 == date2
        let rv = date1 >= sfrom && date1 <= sto
    else
        let rv = (date1 >= sfrom && date1 <= sto) || (date2 >= sfrom && date2 <= sto)
    endif
    " TLogVAR sfrom, sto, date1, date2, rv
    return rv
endf


function! s:TaskSource(filetype) "{{{3
    if has_key(g:vikitasks#sources, a:filetype) && g:vikitasks#sources[a:filetype]
        return a:filetype
    else
        return 'viki'
    endif
endf


" Register BUFFER as a file that should be scanned for task lists.
function! vikitasks#AddBuffer(buffer, ...) "{{{3
    if type(a:buffer) == 0
        let bufnr = a:buffer
        let bufname = bufname(bufnr)
    else
        let bufname = a:buffer
        let bufnr = bufnr(bufname)
    endif
    let bft = s:GetBufferFiletype(bufnr)
    TVarArg ['save', 1], ['filetype', bft]
    " TLogVAR a:buffer, bufnr, bufname, save, filetype
    let cfilename = s:CanonicFilename(fnamemodify(bufname, ':p'))
    let file_defs = s:GetCachedFiles()
    if filereadable(cfilename) && !has_key(file_defs, cfilename)
        let filetype = s:TaskSource(filetype)
        call vikitasks#RegisterFilename(cfilename, filetype, '')
        if save && !vikitasks#ScanCurrentBuffer(cfilename)
            " TLogVAR len(file_defs)
            let file_defs = s:SetTimestamp(file_defs, [cfilename])
            " TLogVAR len(file_defs)
            call s:SaveInfo(file_defs, s:GetCachedTasks())
        endif
    endif
endf


" Unregister BUFFER as a file that should be scanned for task lists.
function! vikitasks#RemoveBuffer(buffer, ...) "{{{3
    TVarArg ['save', 1]
    " TLogVAR a:buffer, save
    let cfilename = s:CanonicFilename(fnamemodify(a:buffer, ':p'))
    let file_defs = s:GetCachedFiles()
    if has_key(file_defs, cfilename)
        let source = s:TaskSource(file_defs[cfilename].filetype)
        let ftdef = vikitasks#ft#{source}#GetInstance()
        if has_key(ftdef, 'RemoveFile')
            call ftdef.RemoveFile(cfilename)
        endif
        call vikitasks#UnRegisterFilename(cfilename)
        " <+TODO+> Are tasks from a:buffer removed?
        if save && !vikitasks#ScanCurrentBuffer(cfilename)
            call s:SaveInfo(file_defs, s:GetCachedTasks())
        endif
    endif
endf


" Edit the list of files.
function! vikitasks#EditFiles() "{{{3
    let file_defs = s:GetCachedFiles()
    let cfiles = keys(file_defs)
    let cfiles1 = tlib#input#EditList('Edit task files:', cfiles)
    if cfiles != cfiles1
        for cfilename in cfiles1
            if !has_key(file_defs)
                let file_defs[cfilename] = s:GetFiletype(cfilename)
            endif
        endfor
        for cfilename in cfiles
            if index(cfiles1, cfilename) == -1 && has_key(file_defs, cfilename)
                call remove(file_defs, cfilename)
            endif
        endfor
        call s:SaveInfo(file_defs, s:GetCachedTasks())
        call tlib#notify#Echo('Please update your task list by running :VikiTasks!', 'WarningMsg')
    endif
endf


" :nodoc:
" :display: vikitasks#Alarm(?ddays = -1, ?use_cached = 1)
" Display a list of alarms.
" If ddays >= 0, the constraint value in |g:vikitasks#alarms| is set to 
" ddays days.
" If ddays is -1 and |g:vikitasks#alarms| is empty, no alarms will be 
" listed.
function! vikitasks#Alarm(...) "{{{3
    TVarArg ['ddays', -1], ['use_cached', 1]
    " TLogVAR ddays
    if ddays < 0 && empty(g:vikitasks#alarms)
        return
    endif
    let tasks = s:GetTasks({}, use_cached)
    call sort(tasks, "s:SortTasks")
    let alarms = copy(g:vikitasks#alarms)
    if ddays >= 0
        let alarms.constraint = ddays
    endif
    " TLogVAR alarms
    call s:FilterTasks(tasks, alarms)
    if !empty(tasks)
        " TLogVAR tasks
        call s:Setqflist(tasks, s:GetCurrentTask(tasks, 0))
        call s:View(0, 1)
        redraw
    endif
endf


function! vikitasks#GetBufferLines(from, to) "{{{3
    let lines = getline(a:from, a:to)
    let file_defs = s:GetCachedFiles()
    let ftdef = s:GetBufferTasksDef()
    let cfilename = s:CanonicFilename(expand('%:p'))
    let filetype = ftdef.GetFiletype()
    let lines = map(lines, 's:ConvertLine(file_defs, cfilename, filetype, v:val)')
    " call s:SaveInfo(file_defs, tasks)
    return lines
endf


" :nodoc:
" Scan the current buffer for task lists.
function! vikitasks#ScanCurrentBuffer(...) "{{{3
    TVarArg ['filename', '']
    let use_buffer = empty(filename)
    if use_buffer
        let bufnr = bufnr('%')
        let cfilename = s:CanonicFilename(expand('%:p'))
    else
        let bufnr = bufnr(filename)
        let cfilename = s:CanonicFilename(filename)
    endif
    if getbufvar(bufnr, '&buftype') =~ '\<nofile\>' || (!empty(s:files_ignored) && cfilename =~ s:files_ignored) || !filereadable(cfilename) || isdirectory(cfilename) || empty(cfilename)
        return 0
    endif
    let [source, ok] = s:GetFileSource(cfilename, s:GetBufferFiletype(bufnr))
    " TLogVAR source, ok, cfilename
    if !ok
        return 0
    endif
    let file_defs = s:GetCachedFiles()
    call s:MaybeRegisterFilename(file_defs, cfilename, source, '')
    " TLogVAR cfilename, use_buffer, has_key(file_defs, cfilename)
    let tasks0 = s:GetCachedTasks()
    let ntasks = len(tasks0)
    " TLogVAR ntasks
    let tasks = []
    let buftasks = {}
    let ftdef = vikitasks#ft#{source}#GetInstance()
    for task in tasks0
        " TLogVAR task
        if s:CanonicFilename(task.filename) == cfilename
            " TLogVAR task.lnum, task
            if has_key(task, 'text')
                let buftasks[task.lnum] = task
            endif
        else
            call add(tasks, task)
        endif
        unlet task
    endfor
    " TLogVAR len(tasks), len(buftasks)
    let rx = vikitasks#TasksRx('tasks', source)
    let def = {'inline': 0, 'sometasks': 0, 'letters': 'A-Z', 'levels': '0-9'}
    let @r = rx
    let update = 0
    let tasks_found = 0
    let lnum = 1
    " echom "DBG ". string(keys(buftasks))
    " TLogVAR keys(buftasks)
    if use_buffer
        let lines = getline(1, '$')
    else
        let lines = readfile(cfilename)
    endif
    " call filter(tasks, 'v:val.filename != cfilename')
    for line0 in lines
        let line = s:ConvertLine(file_defs, cfilename, source, line0)
        if line =~ '^%\s*vikitasks:'
            let paramss = matchstr(line, '^%\s*vikitasks:\s*\zs.*$')
            " TLogVAR paramss
            if paramss =~ '^\s*none\s*$'
                return
            else
                let paramsl = split(paramss, ':')
                " TLogVAR paramsl
                call map(paramsl, 'split(v:val, "=", 1)')
                " TLogVAR paramsl
                try
                    for [var, val] in paramsl
                        let def[var] = val
                    endfor
                catch
                    echoerr 'Vikitasks: Malformed vikitasks-mode-line parameters: '. paramss
                endtry
                unlet! var val
            endif
            let rx = printf(ftdef.TaskLineRx(def.inline, def.sometasks, def.letters, def.levels), '.*')
        elseif line =~ rx
            let text = tlib#string#Strip(line)
            let ltext = get(get(buftasks, lnum, {}), 'text', '')
            let tasks_found = 1
            if ltext != text
                " echom "DBG ". get(buftasks,lnum,'')
                let update = 1
                " TLogVAR lnum, text
                call add(tasks, {
                            \ 'filename': cfilename,
                            \ 'lnum': lnum,
                            \ 'text': text
                            \ })
            else
                call add(tasks, buftasks[lnum])
            endif
        endif
        let lnum += 1
    endfor
    " TLogVAR len(tasks)
    " TLogVAR update
    if update
        call vikitasks#AddBuffer(bufnr, 0, source)
        let file_defs = s:SetTimestamp(file_defs, [cfilename])
        call s:SaveInfo(file_defs, tasks)
    elseif !tasks_found
        call vikitasks#RemoveBuffer(cfilename, 0)
        call s:SaveInfo(file_defs, tasks)
    endif
    return update
endf


" Mark a N tasks as done, i.e. assign them to category X -- see also 
" |g:vikitasks#final_categories|.
function! vikitasks#ItemMarkDone(count) "{{{3
    let ftdef = s:GetBufferTasksDef()
    let rx = vikitasks#TasksRx('tasks', ftdef)
    " TLogVAR rx
    let modified = 0
    for lnum in range(line('.'), line('.') + a:count)
        let line = getline(lnum)
        " TLogVAR lnum, line
        if line =~ rx && line !~ ftdef.FinalRx()
            let line = ftdef.ItemMarkDone(line)
            " TLogVAR line
            call setline(lnum, line)
            let modified = 1
            call s:AfterChange('Line', ftdef, lnum)
        endif
    endfor
    if modified
        call s:AfterChange('Buffer', ftdef)
    endif
endf


" Archive final (see |g:vikitasks#final_categories|) tasks.
function! vikitasks#ItemArchiveFinal() "{{{3
    let ftdef = s:GetBufferTasksDef()
    let archive_filename = ftdef.GetArchiveName(expand("%:p:r"))
    if filereadable(archive_filename)
        let archived = readfile(archive_filename)
    else
        let archived = split(ftdef.ArchiveHeader(1), '\n')
    endif
    let to_be_archived = []
    let clnum = line('.')
    for lnum in reverse(range(1, line('$')))
        let line = getline(lnum)
        if line =~ ftdef.FinalRx()
            call insert(to_be_archived, line)
            if lnum <= clnum
                norm! k
            endif
            exec lnum 'delete'
        endif
    endfor
    if !empty(to_be_archived)
        let archive_header = ftdef.ArchiveHeader(0)
        if !empty(archive_header)
            let archived += split(strftime(archive_header), '\n')
        endif
        let archived += map(to_be_archived, 'ftdef.ArchiveItem(v:val)')
        call writefile(archived, archive_filename)
    endif
endf


" Edit a file monitored by vikitasks.
function! vikitasks#ListTaskFiles() "{{{3
    let file_defs = s:GetCachedFiles()
    let files = keys(file_defs)
    let selected = tlib#input#List('m', 'Select files:', files)
    for file in selected
        exec 'edit' fnameescape(file)
    endfor
endf


" Mark a tasks as due in N days.
function! vikitasks#ItemMarkDueInDays(count, days) "{{{3
    " TLogVAR a:count, a:days
    let duedate = strftime(g:vikitasks#date_fmt, localtime() + a:days * g:tlib#date#dayshift)
    for lnum in range(line('.'), line('.') + a:count)
        call vikitasks#MarkItemDueInDays(lnum, duedate)
    endfor
endf


function! s:GetBufferTasksDef() "{{{3
    let source = s:GetFiletype()
    let ftdef = vikitasks#ft#{source}#GetInstance()
    return ftdef
endf


function! s:AfterChange(type, ftdef, ...) "{{{3
    let lnum = a:0 >= 1 ? a:1 : 0
    let name = 'AfterChange'. a:type
    if has_key(a:ftdef, name)
        let pos = getpos('.')
        try
            if lnum > 0
                exec lnum
                norm! ^
            endif
            call call(a:ftdef[name], [], a:ftdef)
        finally
            call setpos('.', pos)
        endtry
    endif
endf


" :nodoc:
function! vikitasks#MarkItemDueInDays(lnum, duedate) "{{{3
    " TLogVAR bufname('%'), a:lnum, a:duedate
    let ftdef = s:GetBufferTasksDef()
    " TLogVAR ftdef
    let rx = vikitasks#TasksRx('tasks', ftdef)
    " TLogVAR rx
    let line = getline(a:lnum)
    " TLogVAR line, line=~rx
    " TLogVAR line =~ rx, line =~ ftdef.DateRx(), line !~ ftdef.FinalRx()
    if line =~ rx && line =~ ftdef.DateRx() && line !~ ftdef.FinalRx()
        " TLogVAR line
        let line1 = ftdef.MarkItemDueInDays(line, a:duedate)
        " TLogVAR line1
        call setline(a:lnum, line1)
        call s:AfterChange('Line', ftdef, a:lnum)
        call s:AfterChange('Buffer', ftdef)
    endif
endf


" Mark a tasks as due in N weeks.
function! vikitasks#ItemMarkDueInWeeks(count, weeks) "{{{3
    " TLogVAR a:count, a:weeks
    call vikitasks#ItemMarkDueInDays(a:count, a:weeks * 7)
endf


" Change the category for the current and the next a:count tasks.
function! vikitasks#ItemChangeCategory(count, ...) "{{{3
    if a:0 >= 1
        let category = a:1
    else
        call inputsave()
        let category = input('New task category [A-Z]: ')
        call inputrestore()
    endif
    let ftdef = s:GetBufferTasksDef()
    let category = toupper(category)
    if category =~ '\C^[A-Z]$'
        let rx = vikitasks#TasksRx('tasks', ftdef)
        " TLogVAR rx
        let modified = 0
        for lnum in range(line('.'), line('.') + a:count)
            let line = getline(lnum)
            " TLogVAR lnum, line
            if line =~ rx
                let line = ftdef.ChangeCategory(line, category)
                " TLogVAR line
                call setline(lnum, line)
                let modified = 1
                call s:AfterChange('Line', ftdef, lnum)
            endif
        endfor
        if modified
            call s:AfterChange('Buffer', ftdef)
        endif
    else
        echohl WarningMsg
        echom 'Invalid category (must be A-Z):' category
        echohl NONE
    endif
endf


" :nodoc:
function! vikitasks#AgentItemChangeCategory(world, selected) "{{{3
    call inputsave()
    let category = toupper(input('New task category [A-Z]: '))
    call inputrestore()
    if category =~ '\C^[A-Z]$'
        return trag#AgentWithSelected(a:world, a:selected, 'call vikitasks#ItemChangeCategory(0,'. string(category) .')')
    else
        echohl WarningMsg
        echom 'Invalid category (must be A-Z):' category
        echohl NONE
        let a:world.state = 'redisplay'
        return a:world
    endif
endf


" :nodoc:
function! vikitasks#AgentKeymap(world, selected) "{{{3
    let a:world.key_mode = 'vikitasks'
    let a:world.state = 'display'
    return a:world
endf


" :nodoc:
function! vikitasks#AgentMarkDone(world, selected) "{{{3
    return trag#AgentWithSelected(a:world, a:selected, 'VikiTasksDone')
endf


" :nodoc:
function! vikitasks#AgentDueDays(world, selected) "{{{3
    if !empty(g:vikitasks#use_calendar)
        let s:calendar_action = exists('g:calendar_action') ? g:calendar_action : "<SID>CalendarDiary"
        let s:calendar_callback_window = winnr()
        let s:calendar_callback_buffer = winbufnr(0)
        let s:calendar_callback_world = a:world
        let s:calendar_callback_selected = a:selected
        let g:calendar_action = 'vikitasks#CalendarCallback'
        exec g:vikitasks#use_calendar
        let s:calendar_window = winnr()
        let s:calendar_buffer = winbufnr(0)
        let world = tlib#agent#Suspend(a:world, a:selected)
        exec s:calendar_window 'wincmd w'
        return world
    else
        call inputsave()
        let val = input("Number of days: ", 1)
        call inputrestore()
        if empty(val)
            let a:world.state = 'redisplay'
            return a:world
        else
            return trag#AgentWithSelected(a:world, a:selected, 'VikiTasksDueInDays '. val)
        endif
    endif
endf


" :nodoc:
function! vikitasks#CalendarCallback(day, month, year, week, dir) "{{{3
    " TLogVAR a:day, a:month, a:year, a:week, a:dir
    if winbufnr(s:calendar_window) == s:calendar_buffer
        silent! exec s:calendar_window 'wincmd c'
    endif
    let g:calendar_action = s:calendar_action
    let duedate = printf('%4d-%02d-%02d', a:year, a:month, a:day)
    " TLogVAR duedate
    let world = trag#RunCmdOnSelected(s:calendar_callback_world, s:calendar_callback_selected,
                \ printf('call vikitasks#MarkItemDueInDays(line("."), %s)', string(duedate)), 0)
    " TLogVAR world.state
    call setbufvar(s:calendar_callback_buffer, 'tlib_world', world)
    exec s:calendar_callback_window 'wincmd w'
endf


" :nodoc:
function! vikitasks#AgentDueWeeks(world, selected) "{{{3
    call inputsave()
    let val = input("Number of weeks: ", 1)
    call inputrestore()
    if empty(val)
        let a:world.state = 'redisplay'
        return a:world
    else
        return trag#AgentWithSelected(a:world, a:selected, 'VikiTasksDueInWeeks '. val)
    endif
endf


" :nodoc:
function s:Paste(newbuffer, qfl) "{{{3
    let mode_filename = get(g:vikitasks#paste, 'filename', 'add')
    let lines = []
    if mode_filename == 'group'
        let due = s:DueText()
        let qfld = {}
        for item in a:qfl
            if item.text != due
                let bufname = fnamemodify(bufname(item.bufnr), ':p')
                if !has_key(qfld, bufname)
                    let qfld[bufname] = []
                endif
                call add(qfld[bufname], item)
            endif
        endfor
    else
        let qfld = {'*': a:qfl}
    endif
    for key in sort(keys(qfld))
        if key != '*'
            call add(lines, s:FormatPasteLink(key, 0))
        endif
        for item in qfld[key]
            " TLogVAR item
            let bufname = fnamemodify(bufname(item.bufnr), ':p')
            if mode_filename == 'group'
                call add(lines, repeat(' ', &sw) . item.text)
            elseif mode_filename == 'add'
                call add(lines, ' '. item.text .' ' . s:FormatPasteLink(bufname, 1))
            endif
        endfor
        if key != '*'
            call add(lines, '')
        endif
    endfor
    silent! colder
    " TLogVAR lines
    if !empty(a:newbuffer)
        let name = substitute(a:newbuffer, '[[:space:]\/*&<>]', '_', 'g') . g:vikiNameSuffix
        exec 'split' name
        setf viki
    endif
    call append(line('.'), lines)
    if a:newbuffer
        0delete
    endif
endf


function! vikitasks#AgentPaste(world, selected) "{{{3
    if empty(a:selected)
        call a:world.RestoreOrigin()
    else
        call a:world.RestoreOrigin()
        let qfl = []
        for idx in a:selected
            let idx -= 1
            if idx >= 0
                let qfe = a:world.qfl[idx]
                call add(qfl, qfe)
            endif
        endfor
        call s:Paste(a:world.DisplayFilter(), qfl)
    endif
    let a:world.state = "exit"
    return a:world
endf


" :nodoc:
function! vikitasks#Paste(newbuffer, args) "{{{3
    call vikitasks#Tasks(a:args, -1)
    call s:Paste(newbuffer, getqflist())
endf


function! s:FormatPasteLink(fname, inpars) "{{{3
    if has('conceal')
        let fmt = a:inpars ? '([[%s][%s]])' : '[[%s][%s]]'
        let link = printf(fmt, a:fname, fnamemodify(a:fname, ':t'))
    else
        let link = printf('[[%s]]', a:fname)
    endif
    return link
endf


function! vikitasks#Glob2Rx(pattern) "{{{3
    let rx = escape(a:pattern, '\')
    let rx = substitute(rx, '\*\*', '\\.\\{-}', 'g')
    let rx = substitute(rx, '\*', '\\[^\\/]\\*', 'g')
    let rx = substitute(rx, '?', '\\.\\?', 'g')
    if has('fname_case')
        let rx = '\C'. rx
    endif
    return '\V'. rx
endf


function! vikitasks#OnLeave(w) "{{{3
    " TLogVAR g:vikitasks#auto_save
    if g:vikitasks#auto_save
        wall
    endif
endf

