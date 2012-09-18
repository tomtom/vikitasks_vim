" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2012-09-17.
" @Revision:    11

exec 'noremap <buffer>' g:vikitasks#mapleader.'D' ':call vikitasks#ItemMarkDone(v:count)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'A' ':call vikitasks#ItemArchiveDone()<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'L' ':call vikitasks#ListTaskFiles()<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'T' ':call vikitasks#ItemMarkDueInDays(v:count)<cr>'
exec 'noremap <buffer>' g:vikitasks#mapleader.'W' ':call vikitasks#ItemMarkDueInWeeks(v:count)<cr>'

