" @Author:      Tom Link (mailto:micathom AT gmail com?s<c-U>ubject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-05-12.
" @Revision:    21

exec 'noremap <buffer>' g:vikitasks#mapleader.'x' ':<C-U>call vikitasks#ItemMarkDone(v:count)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'a' ':call vikitasks#ItemArchiveFinal()<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'l' ':call vikitasks#ListTaskFiles()<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'d' ':<C-U>call vikitasks#ItemsMarkDueInDays(0, v:count)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'w' ':<C-U>call vikitasks#ItemsMarkDueInWeeks(0, v:count1)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'m' ':<C-U>call vikitasks#ItemsMarkDueInMonths(0, v:count1)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'c' ':<C-U>call vikitasks#ItemChangeCategory(v:count)<cr>'

