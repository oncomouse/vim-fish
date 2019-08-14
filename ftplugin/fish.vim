setlocal comments=:#
setlocal commentstring=#%s
setlocal define=\\v^\\s*function>
setlocal foldexpr=fish#Fold()
setlocal formatoptions+=ron1
setlocal formatoptions-=t
setlocal include=\\v^\\s*\\.>
setlocal iskeyword=@,48-57,-,_,.,/
setlocal suffixesadd^=.fish

" Use the 'j' format option when available.
if v:version ># 703 || v:version ==# 703 && has('patch541')
    setlocal formatoptions+=j
endif

if executable('fish_indent')
    setlocal formatexpr=fish#Format()
endif

function! s:buf_handler(output)
  let l:paths = []
  if len(a:output) > 0
    let l:paths = split(a:output[0][0])
  else
    let l:paths = []
  endif
  for l:path in l:paths
      execute 'setlocal path+='.l:path
  endfor
endfunction

if executable('fish')
    setlocal omnifunc=fish#Complete
    let s:out = []
    if has('nvim')
      call jobstart("fish -c 'echo $fish_function_path'", { 'on_stdout': {j,d,e -> add(s:out, d) }, 'on_exit': {-> <SID>buf_handler(s:out)}})
    elseif !has('nvim') && has('job') && has('channel') && has('lambda')
      call job_start("fish -c 'echo $fish_function_path'", { 'out_mode': 'nl', 'on_stdout': {j,d,e -> add(s:out, d)}, 'exit_cb': {-> <SID>buf_handler(s:out)}})
    else
      call <SID>buf_handler([system("fish -c 'echo $fish_function_path'")])
    endif
else
    setlocal omnifunc=syntaxcomplete#Complete
endif

" Use the 'man' wrapper function in fish to include fish's man pages.
" Have to use a script for this; 'fish -c man' would make the the man page an
" argument to fish instead of man.
execute 'setlocal keywordprg=fish\ '.fnameescape(expand('<sfile>:p:h:h').'/bin/man.fish')

let b:match_words =
            \ escape('<%(begin|function|if|switch|while|for)>:<end>', '<>%|)')

let b:endwise_addition = 'end'
let b:endwise_words = 'begin,function,if,switch,while,for'
let b:endwise_syngroups = 'fishKeyword,fishConditional,fishRepeat'
