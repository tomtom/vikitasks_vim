" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2013-03-07.
" @Revision:    20

exec 'noremap <buffer>' g:vikitasks#mapleader.'x' ':call vikitasks#ItemMarkDone(v:count)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'a' ':call vikitasks#ItemArchiveFinal()<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'l' ':call vikitasks#ListTaskFiles()<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'d' ':call vikitasks#ItemMarkDueInDays(0, v:count)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'w' ':call vikitasks#ItemMarkDueInWeeks(0, v:count1)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'c' ':call vikitasks#ItemChangeCategory(v:count)<cr>'

