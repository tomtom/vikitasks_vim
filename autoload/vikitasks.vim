" vikitasks.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    1100


" A list of glob patterns (or files) that will be searched for task 
" lists.
" Can be buffer-local.
" If you add ! to 'viminfo', this variable will be automatically saved 
" between editing sessions.
" Alternatively, add new items in ~/vimfiles/after/plugin/vikitasks.vim
TLet g:vikitasks#files = []

" A list of |regexp| patterns for filenames that should not be 
" scanned.
TLet g:vikitasks#files_ignored = []
let s:files_ignored = join(g:vikitasks#files_ignored, '\|')

" If non-null, automatically add the homepages of your intervikis to 
" |g:vikitasks#files|.
" If the value is 2, scan all files (taking into account the interviki 
" suffix) in the interviki's top directory.
" Can be buffer-local.
TLet g:vikitasks#intervikis = 0

" If true, completely ignore completed tasks.
TLet g:vikitasks#ignore_completed_tasks = 1

" A list of ignored intervikis.
" Can be buffer-local.
TLet g:vikitasks#intervikis_ignored = []

" If you use todo.txt (http://todotxt.com), set this variable to the 
" full name of base directory where todo.txt is kept.
" For display, lines in todo.txt are converted to viki task list syntax.
TLet g:vikitasks#todotxt_dir = ''

" If true, provide tighter integration with the vim viki plugin.
TLet g:vikitasks#sources = {
            \ 'viki': exists('g:loaded_viki'),
            \ 'todotxt': !empty(g:vikitasks#todotxt_dir)
            \ }

" Default category/priority when converting tasks without priorities.
TLet g:vikitasks#default_priority = 'F'

" The viewer for the quickfix list. If empty, use |:TRagcw|.
TLet g:vikitasks#qfl_viewer = ''

" Item classes that should be included in the list when calling 
" |:VikiTasks|.
" A user-defined value must be set in |vimrc| before the plugin is 
" loaded.
TLet g:vikitasks#rx_letters = 'A-W'

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

" Definition of the tasks that should be included in the Alarms list.
" Fields:
"   all_tasks  ... If non-null, also display tasks with no due-date
"   tasks      ... Either 'tasks' or 'sometasks'
"   constraint ... See |:VikiTasks|
TLet g:vikitasks#alarms = {'all_tasks': 0, 'tasks': 'sometasks', 'constraint': 14}

" If true, the end-date of date ranges (FROM..TO) is significant.
TLet g:vikitasks#use_end_date = 1

" Interpret entries with an unspecified date ("_") as current tasks.
TLet g:vikitasks#use_unspecified_dates = 0

" If true, remove unreadable files from the tasks list.
TLet g:vikitasks#remove_unreadable_files = 1

" The parameters for |:TRagcw| when |g:vikitasks#qfl_viewer| is empty.
" :read: TLet g:vikitasks#inputlist_params = {...}
" :nodoc:
TLet g:vikitasks#inputlist_params = {
            \ 'trag_list_syntax': g:vikitasks#sources.viki ? 'viki' : '',
            \ 'trag_list_syntax_nextgroup': '@vikiPriorityListTodo',
            \ 'trag_short_filename': 1,
            \ 'scratch': '__VikiTasks__',
            \ 'key_map': {
            \     'default': {
            \         "\<f2>" : {'key': "\<f2>", 'agent': 'vikitasks#AgentKeymap', 'key_name': '<f2>', 'help': 'Switch to vikitasks keymap'},
            \             24 : {'key': 24, 'agent': 'vikitasks#AgentMarkDone', 'key_name': '<c-x>', 'help': 'Mark done'},
            \             4 : {'key': 4, 'agent': 'vikitasks#AgentDueDays', 'key_name': '<c-d>', 'help': 'Mark as due in N days'},
            \             23 : {'key': 23, 'agent': 'vikitasks#AgentDueWeeks', 'key_name': '<c-w>', 'help': 'Mark as due in N weeks'},
            \             3 : {'key': 3, 'agent': 'vikitasks#AgentItemChangeCategory', 'key_name': '<c-c>', 'help': 'Change task category'},
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

" Mapleader for some vikitasks related maps.
TLet g:vikitasks#mapleader = '<LocalLeader>t'

" If true, add a date tag when marking a task done with |vikitasks#ItemMarkDone()|.
TLet g:vikitasks#done_add_date = 1

" A vim expression that returns the filename of the archive where 
" archived tasks should be moved to.
TLet g:vikitasks#archive_filename_expr = 'expand("%:p:r") ."_archived". g:vikiNameSuffix'

" A list of strings. The header for newly created tasks archives.
TLet g:vikitasks#archive_header = ['* Archived tasks']

" The date format string (see |strftime()|) for archived entries.
TLet g:vikitasks#archive_date_fmt = '** %Y-%m-%d'

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


function! s:TaskLineRx(filetype, inline, sometasks, letters, levels) "{{{3
    if a:filetype == 'todotxt'
        let val = '\C^\zs\(('. a:letters .')\s\+\|x\s\+\)\?\([0-9-]\+\s\+\)\{,2}.\+$'
    else
        let val = '\C^[[:blank:]]'. (a:inline ? '*' : '\+') .'\zs'.
                    \ '#\(T: \+.\{-}'. a:letters .'.\{-}:\|'. 
                    \ '['. a:levels .']\?['. a:letters .']['. a:levels .']\?'.
                    \ '\( \+\(_\|x\?[0-9%-]\+\)\)\?\)\(\s%s\|$\)'
    endif
    return val
endf


function! s:TasksRx(which_tasks, ...) "{{{3
    TVarArg ['filetype', 'viki']
    let fmt = s:{a:which_tasks}_{filetype}_rx
    if fmt =~ '%s'
        return printf(fmt, '.*')
    else
        return fmt
    endif
endf


let s:sometasks_viki_rx = s:TaskLineRx('viki', 1, 1, g:vikitasks#rx_letters, g:vikitasks#rx_levels)
let s:tasks_viki_rx = s:TaskLineRx('viki', 0, 0, 'A-Z', '0-9')
if g:vikitasks#sources.viki
    exec 'TRagDefKind tasks viki /'. s:tasks_viki_rx .'/'
    exec 'TRagDefKind sometasks viki /'. s:sometasks_viki_rx .'/'
endif
if g:vikitasks#sources.todotxt
    let s:sometasks_todotxt_rx = s:TaskLineRx('todotxt', 1, 1, g:vikitasks#rx_letters, g:vikitasks#rx_levels)
    let s:tasks_todotxt_rx = s:TaskLineRx('todotxt', 0, 0, 'A-Z', '0-9')
    exec 'TRagDefKind tasks todotxt /'. s:tasks_todotxt_rx .'/'
    exec 'TRagDefKind sometasks todotxt /'. s:sometasks_todotxt_rx .'/'
endif
exec 'TRagDefKind tasks * /'. s:tasks_viki_rx .'/'
exec 'TRagDefKind sometasks * /'. s:sometasks_viki_rx .'/'


let s:date_rx = '\C^\s*#[A-Z0-9]\+\s\+\zs\(x\?\)\(_\|\d\+-\d\+-\d\+\)\(\.\.\(\(_\|\d\+-\d\+-\d\+\)\)\)\?\ze\s'
let s:filetypes = {}


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

    if get(args, 'cached', 1)

        let qfl = copy(s:Tasks())
        let files = get(args, 'files', [])
        " TLogVAR files
        if !empty(files)
            for file in files
                let file_rx = substitute(file, '\*', '.\\{-}', 'g')
                let file_rx = substitute(file_rx, '?', '.', 'g')
                call filter(qfl, '(has_key(v:val, "filename") ? v:val.filename : bufname(v:val.bufnr)) =~ file_rx')
            endfor
        endif
        call s:TasksList(qfl, args, suspend)

    else

        if g:vikitasks#sources.viki && &filetype != 'viki' && !viki#HomePage()
            echoerr "VikiTasks: Not a viki buffer and cannot open the homepage"
            return
        endif

        " TLogVAR args
        let files = get(args, 'files', [])
        " TLogVAR files
        if empty(files)
            let files = s:MyFiles()
            " TLogVAR files
        endif
        " TAssertType files, 'list'

        " TLogVAR files
        call map(files, 'glob(v:val)')
        let files = split(join(files, "\n"), '\n')
        let files = map(files, 's:CanonicFilename(v:val)')
        let files = tlib#list#Uniq(files)
        " TLogVAR files
        if !empty(files)
            let qfl = trag#Grep('tasks', 1, files)
            " TLogVAR qfl
            " TLogVAR filter(copy(qfl), 'v:val.text =~ "#D7"')

            let tasks = copy(qfl)
            for i in range(len(tasks))
                let bufnr = tasks[i].bufnr
                let filename = s:CanonicFilename(fnamemodify(bufname(bufnr), ':p'))
                let tasks[i].filename = filename
                let filetype = get(s:filetypes, filename, '')
                if filetype != 'viki'
                    let tasks[i].text = s:Convert(tasks[i].text, filetype)
                endif
                call remove(tasks[i], 'bufnr')
            endfor
            call s:SaveInfo(s:Files(), tasks)

            call s:TasksList(qfl, args, suspend)
        else
            echom "VikiTasks: No task files"
        endif

    endif
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
    let break = repeat('^', (&columns - 20 - len(g:vikitasks#today)) / 2)
    let text = join([break, g:vikitasks#today, break])
    return text
endf


function! s:Setqflist(qfl, today) "{{{3
    " TLogVAR a:today
    if !empty(g:vikitasks#today) && len(a:qfl) > 1 && a:today > 1 && a:today < len(a:qfl) - 1
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
    " TLogVAR a:args

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
        call filter(a:tasks, 'empty(get(matchlist(v:val.text, s:date_rx), 1, ""))')
    endif

    let which_tasks = get(a:args, 'tasks', 'tasks')
    " TLogVAR which_tasks
    if which_tasks == 'sometasks'
        let rx = s:TasksRx('sometasks')
        " TLogVAR rx
        " TLogVAR len(a:tasks)
        call filter(a:tasks, 'v:val.text =~ rx')
        " TLogVAR len(a:tasks)
    endif

    if !get(a:args, 'all_tasks', 0)
        call filter(a:tasks, '!empty(s:GetTaskDueDate(v:val.text, 0, g:vikitasks#use_unspecified_dates))')
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
            call filter(a:tasks, 's:Select(v:val.text, from, to)')
        endif
    endif
endf


function! s:View(index, suspend) "{{{3
    if empty(g:vikitasks#qfl_viewer)
        let w = deepcopy(g:vikitasks#inputlist_params)
        if a:index > 1
            let w.initial_index = a:index
        endif
        call trag#QuickList(w, a:suspend)
    else
        exec g:vikitasks#qfl_viewer
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


function! s:GetTaskDueDate(task, use_end_date, use_unspecified) "{{{3
    let m = matchlist(a:task, s:date_rx)
    if a:use_end_date && g:vikitasks#use_end_date
        let rv = get(m, 4, '')
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


function! s:GetCurrentTask(qfl, daysdiff) "{{{3
    " TLogVAR a:daysdiff
    let i = 1
    let today = strftime('%Y-%m-%d')
    for qi in a:qfl
        let qid = s:GetTaskDueDate(qi.text, 1, g:vikitasks#use_unspecified_dates)
        " TLogVAR qid, today
        if !empty(qid) && qid != '_' && tlib#date#DiffInDays(qid, today, 1) <= a:daysdiff
            let i += 1
        else
            break
        endif
    endfor
    return i
endf


function! s:SortTasks(a, b) "{{{3
    let a = a:a.text
    let b = a:b.text
    let ad = s:GetTaskDueDate(a, 1, g:vikitasks#use_unspecified_dates)
    let bd = s:GetTaskDueDate(b, 1, g:vikitasks#use_unspecified_dates)
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


function! s:Files() "{{{3
    if !exists('s:files')
        let s:files = get(tlib#cache#Get(g:vikitasks#cache), 'files', [])
        if !has('fname_case') || g:tlib#dir#sep == '\'
            call map(s:files, 's:CanonicFilename(v:val)')
        endif
        " echom "DBG nfiles = ". len(s:files)
    endif
    return s:files
endf


function! s:Tasks() "{{{3
    if !exists('s:tasks')
        let s:tasks = get(tlib#cache#Get(g:vikitasks#cache), 'tasks', [])
        " echom "DBG ntasks = ". len(s:tasks)
    endif
    return s:tasks
endf


function! s:SaveInfo(files, tasks) "{{{3
    " TLogVAR len(a:files), len(a:tasks)
    let s:files = a:files
    let s:tasks = a:tasks
    call tlib#cache#Save(g:vikitasks#cache, {'files': a:files, 'tasks': a:tasks})
endf


function! s:CanonicFilename(filename) "{{{3
    let filename = a:filename
    if !has('fname_case')
        let filename = tolower(filename)
    endif
    if g:tlib#dir#sep == '\'
        let filename = substitute(filename, '\\', '/', 'g')
    endif
    return filename
endf


function! s:MyFiles() "{{{3
    let s:filetypes = {}
    let files = copy(tlib#var#Get('vikitasks#files', 'bg', []))
    " TLogVAR files
    let files += s:Files()
    " TLogVAR files
    if g:vikitasks#sources.viki
        if tlib#var#Get('vikitasks#intervikis', 'bg', 0) > 0
            call s:AddInterVikis(files)
        endif
    endif
    " TLogVAR files
    if !empty(s:files_ignored)
        call filter(files, 'v:val !~ s:files_ignored')
    endif
    " TLogVAR files
    if !has('fname_case') || g:tlib#dir#sep == '\'
        call map(files, 's:CanonicFilename(v:val)')
    endif
    " TLogVAR g:vikitasks#sources.todotxt
    if g:vikitasks#sources.todotxt
        let todotxt = tlib#file#Join([g:vikitasks#todotxt_dir, 'todo.txt'])
        if !has('fname_case') || g:tlib#dir#sep == '\'
            let todotxt = s:CanonicFilename(todotxt)
        endif
        if filereadable(todotxt)
            call add(files, todotxt)
            let s:filetypes[todotxt] = 'todotxt'
            if !trag#HasFiletype(todotxt)
                call trag#SetFiletype('todotxt', todotxt)
            endif
            " TLogVAR todotxt
        endif
    endif
    let files = tlib#list#Uniq(files)
    " TLogVAR files
    return files
endf


function! s:AddInterVikis(files) "{{{3
    if g:vikitasks#sources.viki
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
                    call s:AddDirPattern(a:files, dirpattern)
                else
                    if filereadable(file) && !isdirectory(file) && index(a:files, file) == -1
                        call add(a:files, file)
                    endif
                endif
            endif
        endfor
    endif
endf


function! s:AddDirPattern(files, dirpattern) "{{{3
    let files = split(glob(a:dirpattern), '\n')
    for hp in files
        " TLogVAR hp, filereadable(hp), !isdirectory(hp), index(a:files, hp) == -1
        if filereadable(hp) && !isdirectory(hp) && index(a:files, hp) == -1
            call add(a:files, hp)
        endif
    endfor
endf


function! s:Select(text, from, to) "{{{3
    let sfrom = strftime('%Y-%m-%d', a:from)
    let sto = strftime('%Y-%m-%d', a:to)
    let date1 = s:GetTaskDueDate(a:text, 0, g:vikitasks#use_unspecified_dates)
    let date2 = s:GetTaskDueDate(a:text, 1, g:vikitasks#use_unspecified_dates)
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


" Register BUFFER as a file that should be scanned for task lists.
function! vikitasks#AddBuffer(buffer, ...) "{{{3
    TVarArg ['save', 1]
    " TLogVAR a:buffer, save
    let fname = s:CanonicFilename(fnamemodify(a:buffer, ':p'))
    let files = s:Files()
    if filereadable(fname) && index(files, fname) == -1
        call add(files, fname)
        if save && !vikitasks#ScanCurrentBuffer(fname)
            call s:SaveInfo(files, s:Tasks())
        endif
    endif
endf


" Unregister BUFFER as a file that should be scanned for task lists.
function! vikitasks#RemoveBuffer(buffer, ...) "{{{3
    TVarArg ['save', 1]
    " TLogVAR a:buffer, save
    let fname = s:CanonicFilename(fnamemodify(a:buffer, ':p'))
    let files = s:Files()
    let fidx  = index(files, fname)
    if fidx != -1
        call remove(files, fidx)
        if save && !vikitasks#ScanCurrentBuffer(fname)
            call s:SaveInfo(files, s:Tasks())
        endif
    endif
endf


" Edit the list of files.
function! vikitasks#EditFiles() "{{{3
    let files = tlib#input#EditList('Edit task files:', copy(s:Files()))
    if files != s:files
        call s:SaveInfo(files, s:Tasks())
        call tlib#notify#Echo('Please update your task list by running :VikiTasks!', 'WarningMsg')
    endif
endf


" :nodoc:
" :display: vikitasks#Alarm(?ddays = -1)
" Display a list of alarms.
" If ddays >= 0, the constraint value in |g:vikitasks#alarms| is set to 
" ddays days.
" If ddays is -1 and |g:vikitasks#alarms| is empty, no alarms will be 
" listed.
function! vikitasks#Alarm(...) "{{{3
    TVarArg ['ddays', -1]
    " TLogVAR ddays
    if ddays < 0 && empty(g:vikitasks#alarms)
        return
    endif
    let tasks = copy(s:Tasks())
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


function! s:Convert(line, filetype) "{{{3
    " <+TODO+>
    if a:filetype == 'todotxt'
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
    else
        return a:line
    endif
endf


" :nodoc:
" Scan the current buffer for task lists.
function! vikitasks#ScanCurrentBuffer(...) "{{{3
    TVarArg ['filename', '']
    let use_buffer = empty(filename)
    if use_buffer
        let filename = s:CanonicFilename(fnamemodify(bufname('%'), ':p'))
    else
        let filename = s:CanonicFilename(filename)
    endif
    " TLogVAR filename, use_buffer
    if &buftype =~ '\<nofile\>' || (!empty(s:files_ignored) && filename =~ s:files_ignored) || !filereadable(filename) || isdirectory(filename) || empty(filename)
        return 0
    endif
    let tasks0 = s:Tasks()
    let ntasks = len(tasks0)
    let tasks = []
    let buftasks = {}
    let filetype = get(s:filetypes, filename, 'viki')
    for task in tasks0
        " TLogVAR task
        if s:CanonicFilename(task.filename) == filename
            " TLogVAR task.lnum, task
            if has_key(task, 'text')
                let buftasks[task.lnum] = task
            endif
        else
            call add(tasks, task)
        endif
        unlet task
    endfor
    " TLogVAR len(tasks)
    let rx = s:TasksRx('tasks', filetype)
    let def = {'inline': 0, 'sometasks': 0, 'letters': 'A-Z', 'levels': '0-9'}
    let @r = rx
    let update = 0
    let tasks_found = 0
    let lnum = 1
    " echom "DBG ". string(keys(buftasks))
    if use_buffer
        let lines = getline(1, '$')
    else
        let lines = readfile(filename)
    endif
    " call filter(tasks, 'v:val.filename != filename')
    for line in lines
        if filetype != 'viki'
            let line = s:Convert(line, filetype)
        endif
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
            let rx = printf(s:TaskLineRx(filetype, def.inline, def.sometasks, def.letters, def.levels), '.*')
        elseif line =~ rx
            let text = tlib#string#Strip(line)
            " TLogVAR text
            let tasks_found = 1
            if get(get(buftasks, lnum, {}), 'text', '') != text
                " TLogVAR lnum
                " echom "DBG ". get(buftasks,lnum,'')
                let update = 1
                " TLogVAR lnum, text
                call add(tasks, {
                            \ 'filename': filename,
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
    if update
        " TLogVAR update
        call vikitasks#AddBuffer(filename, 0)
        call s:SaveInfo(s:Files(), tasks)
    elseif !tasks_found
        call vikitasks#RemoveBuffer(filename, 0)
        call s:SaveInfo(s:Files(), tasks)
    endif
    return update
endf


" Mark a N tasks as done, i.e. assign them to category X -- see also 
" |g:vikitasks#final_categories|.
function! vikitasks#ItemMarkDone(count) "{{{3
    let rx = s:TasksRx('tasks')
    " TLogVAR rx
    for lnum in range(line('.'), line('.') + a:count)
        let line = getline(lnum)
        " TLogVAR lnum, line
        if line =~ rx && line !~ '^\C\s*#'. s:FinalRx()
            let line = substitute(line, '^\C\s*#\zs\u', 'X', '')
            if g:vikitasks#done_add_date
                let idx = matchend(line, s:date_rx)
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
        endif
    endfor
endf


" Archive final (see |g:vikitasks#final_categories|) tasks.
function! vikitasks#ItemArchiveFinal() "{{{3
    if empty(g:vikitasks#archive_filename_expr)
        echom "vikitasks: Cannot archive tasks: g:vikitasks#archive_filename_expr is empty"
    else
        let archive_filename = eval(g:vikitasks#archive_filename_expr)
        if filereadable(archive_filename)
            let archived = readfile(archive_filename)
        else
            let archived = copy(g:vikitasks#archive_header)
        endif
        let to_be_archived = []
        let clnum = line('.')
        for lnum in reverse(range(1, line('$')))
            let line = getline(lnum)
            if line =~ '\C^\s*#'. s:FinalRx() || line =~ '\C^\s\+#\(\u\d\|\d\u\)\s\+x[ [:digit:]]'
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
    endif
endf


" Edit a file monitored by vikitasks.
function! vikitasks#ListTaskFiles() "{{{3
    let files = s:Files()
    let selected = tlib#input#List('m', 'Select files:', files)
    for file in selected
        exec 'edit' fnameescape(file)
    endfor
endf


" Mark a tasks as due in N days.
function! vikitasks#ItemMarkDueInDays(count, days) "{{{3
    " TLogVAR a:count, a:days
    let duedate = strftime('%Y-%m-%d', localtime() + a:days * g:tlib#date#dayshift)
    for lnum in range(line('.'), line('.') + a:count)
        call vikitasks#MarkItemDuInDays(lnum, duedate)
    endfor
endf


" :nodoc:
function! vikitasks#MarkItemDuInDays(lnum, duedate) "{{{3
    " TLogVAR bufname('%'), a:lnum, a:duedate
    let rx = s:TasksRx('tasks')
    let line = getline(a:lnum)
    " TLogVAR line
    if line =~ rx && line =~ s:date_rx && line !~ '^\C\s*#'. s:FinalRx()
        let m = matchlist(line, s:date_rx)
        if !empty(get(m, 4, ''))
            let subst = '\1\2..'. a:duedate
        else
            let subst = '\1'. a:duedate
        endif
        let line1 = substitute(line, s:date_rx, subst, '')
        " TLogVAR line1
        call setline(a:lnum, line1)
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
    let category = toupper(category)
    if category =~ '\C^[A-Z]$'
        let rx = s:TasksRx('tasks')
        " TLogVAR rx
        for lnum in range(line('.'), line('.') + a:count)
            let line = getline(lnum)
            " TLogVAR lnum, line
            if line =~ rx
                let line = substitute(line, '^\C\s*#\zs\u', category, '')
                " TLogVAR line
                call setline(lnum, line)
            endif
        endfor
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


function! s:FinalRx() "{{{3
    return printf('\C[%s]', g:vikitasks#final_categories)
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
        let val = input("Number of days: ", 1)
        return trag#AgentWithSelected(a:world, a:selected, 'VikiTasksDueInDays '. val)
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
                \ printf('call vikitasks#MarkItemDuInDays(line("."), %s)', string(duedate)), 0)
    " TLogVAR world.state
    call setbufvar(s:calendar_callback_buffer, 'tlib_world', world)
    exec s:calendar_callback_window 'wincmd w'
endf


" :nodoc:
function! vikitasks#AgentDueWeeks(world, selected) "{{{3
    call inputsave()
    let val = input("Number of weeks: ", 1)
    call inputrestore()
    return trag#AgentWithSelected(a:world, a:selected, 'VikiTasksDueInWeeks '. val)
endf


" :nodoc:
function! vikitasks#Paste(newbuffer, args) "{{{3
    call vikitasks#Tasks(a:args, -1)
    let mode_filename = get(g:vikitasks#paste, 'filename', 'add')
    let lines = []
    if mode_filename == 'group'
        let due = s:DueText()
        let qfld = {}
        for item in getqflist()
            if item.text != due
                let bufname = fnamemodify(bufname(item.bufnr), ':p')
                if !has_key(qfld, bufname)
                    let qfld[bufname] = []
                endif
                call add(qfld[bufname], item)
            endif
        endfor
    else
        let qfld = {'*': getqflist()}
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
    if a:newbuffer
        new
        setf viki
    endif
    call append(line('.'), lines)
    if a:newbuffer
        0delete
    endif
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

