if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nolisp

setlocal indentexpr=ReasonIndent(v:lnum)

if exists('*ReasonIndent')
  finish
endif

function! SkipReasonBlanksAndComments(startline)
  let lnum = a:startline
  while lnum > 1
    let lnum = prevnonblank(lnum)
    if getline(lnum) =~ '\*/\s*$'
      while getline(lnum) !~ '/\*' && lnum > 1
        let lnum = lnum - 1
      endwhile
      if getline(lnum) =~ '^\s*/\*'
        let lnum = lnum - 1
      else
        break
      endif
    elseif getline(lnum) =~ '^\s*//'
      let lnum = lnum - 1
    else
      break
    endif
  endwhile
  return lnum
endfunction

function! ReasonIndent(lnum)
  let l:prevlnum = SkipReasonBlanksAndComments(a:lnum-1)
  if l:prevlnum == 0 " We're at top of file
    return 0
  endif

  echom getline(l:prevlnum)

  " Prev and current line with line-comments removed
  let l:prevl = substitute(getline(l:prevlnum), '//.*$', '', '')
  let l:thisl = substitute(getline(a:lnum), '//.*$', '', '')
  let l:previ = indent(l:prevlnum)

  let l:ind = l:previ

  if l:prevl =~ '[({\[]\s*$'
    " Opened a block
    let l:ind += shiftwidth()
  endif

  if l:thisl =~ '^\s*[)}\]]'
    " Closed a blocked
    let l:ind -= shiftwidth()
  endif

  return l:ind
endfunction
