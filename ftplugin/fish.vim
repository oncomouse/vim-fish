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

function! s:buf_handler(bufnameOrOutput)
  let l:paths = []
  if has('nvim')
    if len(a:bufnameOrOutput) > 0
      let l:paths = split(a:bufnameOrOutput[0][0])
    else
      let l:paths = []
    endif
  else
    let l:buflines = getbufline(bufnr(a:bufnameOrOutput), 1, '$')
    try
      execute('bdelete! '.bufnr(a:bufnameOrOutput))
    catch
    endtry
    let l:paths = split(l:buflines)
  endif
  for l:path in l:paths
      execute 'setlocal path+='.l:path
  endfor
endfunction

if executable('fish')
    setlocal omnifunc=fish#Complete
    if has('nvim')
      let s:out = []
      call jobstart("fish -c 'echo $fish_function_path'", { 'on_stdout': {j,d,e -> add(s:out, d) }, 'on_exit': {-> <SID>buf_handler(s:out)}})
    else
      let s:bufname = tempname()
      call job_start("fish -c 'echo $fish_function_path'", { 'out_io': 'buffer', 'out_name': s:bufname, 'exit_cb': {-> <SID>buf_handler(s:bufname)}})
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
