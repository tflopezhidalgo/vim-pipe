" Vim plugin for piping current editor
" content to terminal.

if exists("g:pipe_loaded")
   finish
endif

let g:pipe_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

" Plugin
function! s:get_visual_selection()
    " Dark magic to get current selected words
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

" `range` is a modifier to function that makes
" our function be called only once even when we
" are selecting many lines.

function! s:pipe() range
    if ! exists("g:last_terminal_id")
        echom "No terminal opened!"
        return 
    endif
    let data = s:get_visual_selection()
    let data = substitute(data, "    ", "", "g")
    try
        call chansend(g:last_terminal_id, data)
    catch
        echom "Terminal was closed. Unable to send data"
        unlet g:last_terminal_id
    endtry
endfunction

augroup Terminal
    au!
    vmap ,l :call <SID>pipe()<cr>
    au TermOpen * let g:last_terminal_id = b:terminal_job_id
    au TermClose * unlet g:last_terminal_id
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
