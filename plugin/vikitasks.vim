" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vikitasks_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-12-13.
" @Last Change: 2014-02-05.
" @Revision:    316
" GetLatestVimScripts: 2894 0 :AutoInstall: vikitasks.vim
" Search for task lists and display them in a list

scriptencoding utf-8

if !exists('g:loaded_tlib') || g:loaded_tlib < 113
    runtime plugin/02tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 113
        echoerr 'tlib >= 1.13 is required'
        finish
    endif
endif
if !exists('g:loaded_trag') || g:loaded_trag < 102
    runtime plugin/trag.vim
    if !exists('g:loaded_trag') || g:loaded_trag < 102
        echoerr 'trag >= 0.102 is required'
        finish
    endif
endif
if &cp || exists("g:loaded_vikitasks")
    finish
endif
let g:loaded_vikitasks = 101

let s:save_cpo = &cpo
set cpo&vim


" Show alarms on pending tasks.
" If 0, don't display alarms for pending tasks.
" If n > 0, display alarms for pending tasks or tasks with a deadline in n 
" days.
"
" A useful value (for your |vimrc|) is: >
"
"     let g:vikitasks_startup_alarms = (!has('clientserver') || len(split(serverlist(), '\n')) <= 1) && argc() == 0
"
" This will display alarms when running the first instance of gvim 
" without arguments.
TLet g:vikitasks_startup_alarms = 0


" Scan a buffer on these events.
TLet g:vikitasks_scan_events = 'BufWritePost,BufWinEnter'

" A list of filename patterns (see 'wildcards') for files that should 
" automatically on events specified in |g:vikitasks_scan_events|.
TLet g:vikitasks_scan_patterns = ['*.txt', '*.viki']

" :display: :VikiTasks[!] [CONSTRAINT] [PATTERN] [FILE_PATTERNS]
" CONSTRAINT defined which tasks should be displayed. Possible values 
" for CONSTRAINT are:
"
"   today            ... Show tasks that are due today
"   current          ... Show pending and today's tasks
"   NUMBER (of days) ... Show tasks that are due within N days
"   Nd               ... Tasks for the next N days
"   Nw               ... Tasks for the next N weeks (i.e. 7 days)
"   Nm               ... Tasks for the next N months (i.e. 31 days)
"   week             ... Tasks for the next week (i.e. 7 days)
"   month            ... Tasks for the next month (i.e. 31 days)
"   .                ... Show some tasks (see |g:vikitasks#rx_letters| 
"                        and |g:vikitasks#rx_levels|)
"   *                ... Show all tasks
"
" The default value for CONSTRAINT is ".".
" 
" If N is prepended with + (e.g. "+2w"), tasks with a deadline in the 
" past are hidden.
"
" If N is prepended with - (e.g. "-2w"), only tasks with a deadline in 
" the past (in this example in the last two weeks) are shown. This 
" implies showing all tasks as with "*".
"
" If CONSTRAINT doesn't match one of the constraints described above, it 
" is assumed to be a PATTERN -- see also |viki-tasks|.
"
" The |regexp| PATTERN is prepended with |\<| if it seems to be a word. 
" The PATTERN is made case sensitive if it contains an upper-case letter 
" and if 'smartcase' is true. Only tasks matching the PATTERN will be 
" listed. Use "." to match any task.
" 
" With the optional !, all files are rescanned. Otherwise cached 
" information is used. Either scan all known files (|interviki|s and 
" pages registered via |:VikiTasksAdd|) or files matching FILE_PATTERNS.
"
" The current buffer has to be a viki buffer. If it isn't, your 
" |g:vikiHomePage|, which must be set, is opened first.
"
" Examples:
"   Show all cached tasks with a date: >
"         :VikiTasks
" <   Rescan files and show all tasks: >
"         :VikiTasks!
" <   Show all cached tasks for today: >
"         :VikiTasks today
" <   Show all current cached tasks (today or with a deadline in the 
"   past) in a specified list of files: >
"         :VikiTasks current Notes*.txt
command! -bang -nargs=* -bar VikiTasks call vikitasks#Tasks(vikitasks#GetArgs(!empty("<bang>"), [<f-args>]), 0)

" The same as |:VikiTasks| but the tasks list doesn't take the focus.
command! -bang -nargs=* -bar VikiTasksStatic call vikitasks#Tasks(vikitasks#GetArgs(!empty("<bang>"), [<f-args>]), 1)
" cabbr vikitasks VikiTasks

" :display: :VikiTasksPaste[!] [ARGUMENTS...]
" Paste the results of a VIKITASKSCOMMAND (default: VikiTasks) in a 
" buffer. When called with a |bang| [!], create a new buffer. See 
" |:VikiTasks| for the allowed ARGUMENTS.
command! -bang -nargs=* -bar VikiTasksPaste call vikitasks#Paste(empty("<bang>") ? '' : 'VikiTasksPaste', vikitasks#GetArgs(0, [<f-args>]))

" :display: :[count]VikiTasksAlarms 
" Display a list of alarms. Shows alarms due within N days.
" If N is -1, uses |g:vikitasks#alarms| if any.
command! -count -bang -bar VikiTasksAlarms call vikitasks#Alarm(<count>, empty('<bang>'))

" :display: :VikiTasksAdd
" Add the current buffer to |g:vikitasks#files|.
command! VikiTasksAdd call vikitasks#AddBuffer(expand('%:p'))


" Mark a task as done (see |vikitasks#ItemMarkDone()|).
command! -count=0 -bar VikiTasksDone call vikitasks#ItemMarkDone(<count>)


" Archive final (see |g:vikitasks#final_categories|) tasks.
command! -bar VikiTasksArchive call vikitasks#ItemArchiveFinal()


" :display: :VikiEditTasksFiles
" Edit |g:vikitasks#files|. This allows you to remove buffers from the 
" list.
command! -bar VikiEditTasksFiles call vikitasks#EditFiles()


" :display: :VikiTasksFiles
" Edit a file monitored by vikitasks.
command! -bar VikiTasksFiles call vikitasks#ListTaskFiles()


" :display: :[count]VikiTasksDueInDays [DAYS=0]
" Mark [count] task(s) as due in N days.
command! -bar -range -nargs=? VikiTasksDueInDays <line1>,<line2>call vikitasks#ItemMarkDueInDays(0, 0 + <q-args>)


" :display: :[count]VikiTasksDueInDays [WEEKS=1]
" Mark [count] task(s) as due in N weeks.
command! -bar -range -nargs=? VikiTasksDueInWeeks <line1>,<line2>call vikitasks#ItemMarkDueInWeeks(0, empty(<q-args>) ? 1 : 0 + <q-args>)


augroup VikiTasks
    autocmd!
    " TLogVAR g:vikitasks_startup_alarms, has('vim_starting')
    if g:vikitasks_startup_alarms
        if has('vim_starting')
            autocmd VimEnter *  call vikitasks#Alarm()
        else
            call vikitasks#Alarm()
        endif
    endif
    if !empty(g:vikitasks_scan_events)
        for s:pattern in g:vikitasks_scan_patterns
            " exec 'autocmd' g:vikitasks_scan_events s:pattern 'if exists("b:vikiEnabled") && b:vikiEnabled | call vikitasks#ScanCurrentBuffer(expand("<afile>:p")) | endif'
            exec 'autocmd' g:vikitasks_scan_events s:pattern 'call vikitasks#ScanCurrentBuffer(expand("<afile>:p"))'
        endfor
    endif
    unlet g:vikitasks_startup_alarms g:vikitasks_scan_events s:pattern
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
