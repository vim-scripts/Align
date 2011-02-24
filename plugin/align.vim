" Title:        align.vim
" Author:       Zohair Ahmad <zohair dot ahmad at gmail dot com>
" Date:         February 28, 2011
" Description:  Vim script that is useful in aligning the right side of text.

" The spaces will be inserted at the column this functions is called at
function! InsertSpaces(colnr)
  let w:lastpos = col(".")
  let w:diff = a:colnr - w:lastpos

  "call cursor("0", w:lastpos)
  if(w:diff > 0)
    exe "norm!" . w:diff . "i \<esc>"
  endif
endfunction

" This should be called to align to the last semicolon
" Arguments: pat is a one char pattern to be matched
function! AlignToLast()
  "pick up the pattern from the current char
  exe "norm! vy"
  let s:pat = getreg("0")

  "first check if the requested characeter exists on the current line
  let s:matched = match(getline("."), s:pat, 0)
  if(s:matched == -1)
    return -1
  endif

  exe "norm! mo"            | "save the current position
  exe search(s:pat, 'b')    | "search backwards for the last ;
  exe "norm! f" . s:pat     | "position cursor at the ;
  let w:prevcol = col(".")  | "find the column nr.

  exe "norm! `o"            | "return to old line
  "exe "norm! f" . s:pat

  call InsertSpaces(w:prevcol)
endfunction

nmap <silent> ;; :call AlignToLast()<CR>
