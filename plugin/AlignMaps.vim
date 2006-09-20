" AlignMaps:   Alignment maps based upon <Align.vim>
" Maintainer:  Dr. Charles E. Campbell, Jr. <Charles.Campbell@gsfc.nasa.gov>
" Date:        Sep 08, 2006
" Version:     35
"
" NOTE: the code herein needs vim 6.0 or later
"                       needs <Align.vim> v6 or later
"                       needs <cecutil.vim> v5 or later
" Copyright:    Copyright (C) 1999-2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               AlignMaps.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Usage: {{{1
" Use 'a to mark beginning of to-be-aligned region,   Alternative:  use v
" move cursor to end of region, and execute map.      (visual mode) to mark
" The maps also set up marks 'y and 'z, and retain    region, execute same map.
" 'a at the beginning of region.                      Uses 'a, 'y, and 'z.
"
" Although the comments indicate the maps use a leading backslash,
" actually they use <Leader> (:he mapleader), so the user can
" specify that the maps start how he or she prefers.
"
" Note: these maps all use <Align.vim>.
"
" Romans 1:20 For the invisible things of Him since the creation of the {{{1
" world are clearly seen, being perceived through the things that are
" made, even His everlasting power and divinity; that they may be
" without excuse.
" ---------------------------------------------------------------------

" Load Once: {{{1
if exists("g:loaded_alignmaps") || &cp
 finish
endif
let g:loaded_alignmaps = "v35"
let s:keepcpo          = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" WS: wrapper start map (internal)  {{{1
" Produces a blank line above and below, marks with 'y and 'z
if !hasmapto('<Plug>WrapperStart')
 nmap <unique> <SID>WS	<Plug>AlignMapsWrapperStart
endif
nmap <silent> <script> <Plug>AlignMapsWrapperStart	:set lz<CR>:call AlignWrapperStart()<CR>

" ---------------------------------------------------------------------
" AlignWrapperStart: {{{1
fun! AlignWrapperStart()
"  call Dfunc("AlignWrapperStart()")

  if !exists("s:alignmaps_wrapcnt") || s:alignmaps_wrapcnt <= 0
"   call Decho("wrapper initialization")
   let s:alignmaps_wrapcnt    = 1
   let s:alignmaps_keepgd     = &gdefault
   let s:alignmaps_keepsearch = @/
   let s:alignmaps_keepch     = &ch
   let s:alignmaps_keepmy     = SaveMark("'y")
   let s:alignmaps_keepmz     = SaveMark("'z")
   let s:alignmaps_posn       = SaveWinPosn(0)
   " set up fencepost blank lines
   put =''
   norm! mz'a
   put! =''
   norm! my
   let s:alignmaps_zline      = line("'z")
   exe "'y,'zs/@/\177/ge"
  else
"   call Decho("embedded wrapper")
   let s:alignmaps_wrapcnt    = s:alignmaps_wrapcnt + 1
   norm! 'yjma'zk
  endif

  " change some settings to align-standard values
  set nogd
  set ch=2
  AlignPush
  norm! 'zk
"  call Dret("AlignWrapperStart : alignmaps_wrapcnt=".s:alignmaps_wrapcnt." my=".line("'y")." mz=".line("'z"))
endfun

" ---------------------------------------------------------------------
" WE: wrapper end (internal)   {{{1
" Removes guard lines, restores marks y and z, and restores search pattern
if !hasmapto('<Plug>WrapperEnd')
 nmap <unique> <SID>WE	<Plug>AlignMapsWrapperEnd
endif
nmap <silent> <script> <Plug>AlignMapsWrapperEnd	:call AlignWrapperEnd()<CR>:set nolz<CR>

" ---------------------------------------------------------------------
" AlignWrapperEnd:	{{{1
fun! AlignWrapperEnd()
"  call Dfunc("AlignWrapperEnd() alignmaps_wrapcnt=".s:alignmaps_wrapcnt." my=".line("'y")." mz=".line("'z"))

  " remove trailing white space introduced by whatever in the modification zone
  'y,'zs/\s\+$//e

  " restore AlignCtrl settings
  AlignPop

  let s:alignmaps_wrapcnt= s:alignmaps_wrapcnt - 1
  if s:alignmaps_wrapcnt <= 0
   " initial wrapper ending
   exe "'y,'zs/\177/@/ge"

   " if the 'z line hasn't moved, then go ahead and restore window position
   let zstationary= s:alignmaps_zline == line("'z")

   " remove fencepost blank lines.
   " restore 'a
   norm! 'yjmakdd'zdd

   " restore original 'y, 'z, and window positioning
   call RestoreMark(s:alignmaps_keepmy)
   call RestoreMark(s:alignmaps_keepmz)
   if zstationary > 0
    call RestoreWinPosn(s:alignmaps_posn)
"    call Decho("restored window positioning")
   endif

   " restoration of options
   let &gd= s:alignmaps_keepgd
   let &ch= s:alignmaps_keepch
   let @/ = s:alignmaps_keepsearch

   " remove script variables
   unlet s:alignmaps_keepch
   unlet s:alignmaps_keepsearch
   unlet s:alignmaps_keepmy
   unlet s:alignmaps_keepmz
   unlet s:alignmaps_keepgd
   unlet s:alignmaps_posn
  endif

"  call Dret("AlignWrapperEnd : alignmaps_wrapcnt=".s:alignmaps_wrapcnt." my=".line("'y")." mz=".line("'z"))
endfun

" ---------------------------------------------------------------------
" Complex C-code alignment maps: {{{1
map <silent> <Leader>a?    <SID>WS:AlignCtrl mIp1P1lC ? : : : : <CR>:'a,.Align<CR>:'a,'z-1s/\(\s\+\)? /?\1/e<CR><SID>WE
map <silent> <Leader>a,    <SID>WS:'y,'zs/\(\S\)\s\+/\1 /ge<CR>'yjma'zk<Leader>jnr,<CR>:silent 'y,'zg/,/call <SID>FixMultiDec()<CR>'z<Leader>adec<SID>WE
map <silent> <Leader>a<    <SID>WS:AlignCtrl mIp1P1=l << >><CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>a=    <SID>WS:AlignCtrl mIp1P1=l<CR>:AlignCtrl g :=<CR>:'a,'zAlign :\==<CR><SID>WE
map <silent> <Leader>abox  <SID>WS:let g:alignmaps_iws=substitute(getline("'a"),'^\(\s*\).*$','\1','e')<CR>:'a,'z-1s/^\s\+//e<CR>:'a,'z-1s/^.*$/@&@/<CR>:AlignCtrl m=p01P0w @<CR>:'a,.Align<CR>:'a,'z-1s/@/ * /<CR>:'a,'z-1s/@$/*/<CR>'aYP:s/./*/g<CR>0r/'zkYp:s/./*/g<CR>0r A/<Esc>:exe "'a-1,'z-1s/^/".g:alignmaps_iws."/e"<CR><SID>WE
map <silent> <Leader>acom  <SID>WS:'a,.s/\/[*/]\/\=/@&@/e<CR>:'a,.s/\*\//@&/e<CR>:'y,'zs/^\( *\) @/\1@/e<CR>'zk<Leader>tW@:'y,'zs/^\(\s*\) @/\1/e<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <Leader>adcom <SID>WS:'a,.v/^\s*\/[/*]/s/\/[*/]\*\=/@&@/e<CR>:'a,.v/^\s*\/[/*]/s/\*\//@&/e<CR>:'y,'zv/^\s*\/[/*]/s/^\( *\) @/\1@/e<CR>'zk<Leader>tdW@:'y,'zv/^\s*\/[/*]/s/^\(\s*\) @/\1/e<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <Leader>aocom :AlignPush<CR>:AlignCtrl g /[*/]<CR><Leader>acom:AlignPop<CR>
map <silent> <Leader>ascom <SID>WS:'a,.s/\/[*/]/@&@/e<CR>:'a,.s/\*\//@&/e<CR>:silent! 'a,.g/^\s*@\/[*/]/s/@//ge<CR>:AlignCtrl v ^\s*\/[*/]<CR>:AlignCtrl g \/[*/]<CR>'zk<Leader>tW@:'y,'zs/^\(\s*\) @/\1/e<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <Leader>adec  <SID>WS:'a,'zs/\([^ \t/(]\)\([*&]\)/\1 \2/e<CR>:'y,'zv/^\//s/\([^ \t]\)\s\+/\1 /ge<CR>:'y,'zv/^\s*[*/]/s/\([^/][*&]\)\s\+/\1/ge<CR>:'y,'zv/^\s*[*/]/s/^\(\s*\%(\K\k*\s\+\%([a-zA-Z_*(&]\)\@=\)\+\)\([*(&]*\)\s*\([a-zA-Z0-9_()]\+\)\s*\(\(\[.\{-}]\)*\)\s*\(=\)\=\s*\(.\{-}\)\=\s*;/\1@\2#@\3\4@\6@\7;@/e<CR>:'y,'zv/^\s*[*/]/s/\*\/\s*$/@*\//e<CR>:'y,'zv/^\s*[*/]/s/^\s\+\*/@@@@@* /e<CR>:'y,'zv/^\s*[*/]/s/^@@@@@\*\(.*[^*/]\)$/&@*/e<CR>'yjma'zk:AlignCtrl v ^\s*[*/#]<CR><Leader>t@:'y,'zv/^\s*[*/]/s/@ //ge<CR>:'y,'zv/^\s*[*/]/s/\(\s*\);/;\1/e<CR>:'y,'zv/^#/s/# //e<CR>:'y,'zv/^\s\+[*/#]/s/\([^/*]\)\(\*\+\)\( \+\)/\1\3\2/e<CR>:'y,'zv/^\s\+[*/#]/s/\((\+\)\( \+\)\*/\2\1*/e<CR>:'y,'zv/^\s\+[*/#]/s/^\(\s\+\) \*/\1*/e<CR>:'y,'zv/^\s\+[*/#]/s/[ \t@]*$//e<CR>:'y,'zs/^[*]/ */e<CR><SID>WE
map <silent> <Leader>adef  <SID>WS:AlignPush<CR>:AlignCtrl v ^\s*\(\/\*\<bar>\/\/\)<CR>:'a,.v/^\s*\(\/\*\<bar>\/\/\)/s/^\(\s*\)#\(\s\)*define\s*\(\I[a-zA-Z_0-9(),]*\)\s*\(.\{-}\)\($\<Bar>\/\*\)/#\1\2define @\3@\4@\5/e<CR>:'a,.v/^\s*\(\/\*\<bar>\/\/\)/s/\($\<Bar>\*\/\)/@&/e<CR>'zk<Leader>t@'yjma'zk:'a,.v/^\s*\(\/\*\<bar>\/\/\)/s/ @//g<CR><SID>WE
map <silent> <Leader>afnc  :set lz<CR>:silent call <SID>Afnc()<CR>:set nolz<CR>
if exists("g:alignmaps_usanumber")
 map <silent> <Leader>anum  <SID>WS:'a,'zs/\(\d\)\s\+\(-\=\d\)/\1@\2/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [.@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(\.\)\(\s\+\)\([-0-9.,e]\+\)/\1\3\2/ge<CR><SID>WE
elseif exists("g:alignmaps_euronumber")
 map <silent> <Leader>anum  <SID>WS:'a,'zs/\(\d\)\s\+\(-\=\d\)/\1@\2/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [,@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(,\)\(\s\+\)\([-0-9.,e]\+\)/\1\3\2/ge<CR><SID>WE
else
 map <silent> <Leader>anum  <SID>WS:'a,'zs/\(\d\)\s\+\(-\=[.,]\=\d\)/\1@\2/ge<CR>:AlignCtrl mp0P0<CR>:'a,'zAlign [.,@]<CR>:'a,'zs/\([-0-9.,]*\)\(\s*\)\([.,]\)/\2\1\3/g<CR>:'a,'zs/@/ /ge<CR><SID>WE
endif
map <silent> <Leader>aunum  <SID>WS:'a,'zs/\(\d\)\s\+\(-\=\d\)/\1@\2/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [.@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(\.\)\(\s\+\)\([-0-9.,e]\+\)/\1\3\2/ge<CR><SID>WE
map <silent> <Leader>aenum  <SID>WS:'a,'zs/\(\d\)\s\+\(-\=\d\)/\1@\2/ge<CR>:AlignCtrl mp0P0r<CR>:'a,'zAlign [,@]<CR>:'a,'zs/@/ /ge<CR>:'a,'zs/\(,\)\(\s\+\)\([-0-9.,e]\+\)/\1\3\2/ge<CR><SID>WE

" ---------------------------------------------------------------------
" html table alignment	{{{1
map <silent> <Leader>Htd <SID>WS:'y,'zs%<[tT][rR]><[tT][dD][^>]\{-}>\<Bar></[tT][dD]><[tT][dD][^>]\{-}>\<Bar></[tT][dD]></[tT][rR]>%@&@%g<CR>'yjma'zk:AlignCtrl m=Ilp1P0 @<CR>:'a,.Align<CR>:'y,'zs/ @/@/<CR>:'y,'zs/@ <[tT][rR]>/<[tT][rR]>/ge<CR>:'y,'zs/@//ge<CR><SID>WE

" ---------------------------------------------------------------------
" character-based right-justified alignment maps {{{1
map <silent> <Leader>T| <SID>WS:AlignCtrl mIp0P0=r <Bar><CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>T#   <SID>WS:AlignCtrl mIp0P0=r #<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>T,   <SID>WS:AlignCtrl mIp0P1=r ,<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>Ts,  <SID>WS:AlignCtrl mIp0P1=r ,<CR>:'a,.Align<CR>:'a,.s/\(\s*\),/,\1/ge<CR><SID>WE
map <silent> <Leader>T:   <SID>WS:AlignCtrl mIp1P1=r :<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>T;   <SID>WS:AlignCtrl mIp0P0=r ;<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>T<   <SID>WS:AlignCtrl mIp0P0=r <<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>T=   <SID>WS:'a,'z-1s/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'z-1s@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'z-1s/; */;@/e<CR>:'a,'z-1s/==/\="\<Char-0xff>\<Char-0xff>"/ge<CR>:'a,'z-1s/!=/\x="!\<Char-0xff>"/ge<CR>:AlignCtrl mIp1P1=r = @<CR>:AlignCtrl g =<CR>:'a,'z-1Align<CR>:'a,'z-1s/; *@/;/e<CR>:'a,'z-1s/; *$/;/e<CR>:'a,'z-1s@\([*/+\-%<Bar>&\~^]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1s/\( \+\);/;\1/ge<CR>:'a,'z-1s/\xff/=/ge<CR><SID>WE<Leader>acom
map <silent> <Leader>T?   <SID>WS:AlignCtrl mIp0P0=r ?<CR>:'a,.Align<CR>:'y,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <Leader>T@   <SID>WS:AlignCtrl mIp0P0=r @<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>Tab  <SID>WS:'a,.s/^\(\t*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\t','@','g'),'\')/<CR>:AlignCtrl mI=r @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <Leader>Tsp  <SID>WS:'a,.s/^\(\s*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\s\+','@','g'),'\')/<CR>:AlignCtrl mI=r @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <Leader>T~   <SID>WS:AlignCtrl mIp0P0=r ~<CR>:'a,.Align<CR>:'y,'zs/ \( *\);/;\1/ge<CR><SID>WE

" ---------------------------------------------------------------------
" character-based left-justified alignment maps {{{1
map <silent> <Leader>t| <SID>WS:AlignCtrl mIp0P0=l <Bar><CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>t#   <SID>WS:AlignCtrl mIp0P0=l #<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>t,   <SID>WS:AlignCtrl mIp0P1=l ,<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>ts,  <SID>WS:AlignCtrl mIp0P1=l ,<CR>:'a,.Align<CR>:'a,.s/\(\s*\),/,\1/ge<CR><SID>WE
map <silent> <Leader>t:   <SID>WS:AlignCtrl mIp1P1=l :<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>t;   <SID>WS:AlignCtrl mIp0P0=l ;<CR>:'a,.Align<CR>:.,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <Leader>t<   <SID>WS:AlignCtrl mIp0P0=l <<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>t=   <SID>WS:'a,'zs/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'zs@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'zs/==/\="\<Char-0xff>\<Char-0xff>"/ge<CR>:'a,'zs/!=/\="!\<Char-0xff>"/ge<CR>'zk:AlignCtrl mIp1P1=l =<CR>:AlignCtrl g =<CR>:'a,'z-1Align<CR>:'a,'z-1s@\([*/+\-%<Bar>&\~^!=]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1s/\( \+\);/;\1/ge<CR>:'a,'z-1v/^\s*\/[*/]/s/\/[*/]/@&@/e<CR>:'a,'z-1v/^\s*\/[*/]/s/\*\//@&/e<CR>'zk<Leader>t@:'y,'zs/^\(\s*\) @/\1/e<CR>:'a,'z-1s/\xff/=/ge<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <Leader>w=   <SID>WS:'a,'zg/=/s/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'zg/=/s@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'zg/=/s/==/\="\<Char-0xff>\<Char-0xff>"/ge<CR>:'a,'zg/=/s/!=/\="!\<Char-0xff>"/ge<CR>'zk:AlignCtrl mWp1P1=l =<CR>:AlignCtrl g =<CR>:'a,'z-1g/=/Align<CR>:'a,'z-1g/=/s@\([*/+\-%<Bar>&\~^!=]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1g/=/s/\( \+\);/;\1/ge<CR>:'a,'z-1v/^\s*\/[*/]/s/\/[*/]/@&@/e<CR>:'a,'z-1v/^\s*\/[*/]/s/\*\//@&/e<CR>'zk<Leader>t@:'y,'zs/^\(\s*\) @/\1/e<CR>:'a,'z-1g/=/s/\xff/=/ge<CR>:'y,'zg/=/s/ @//eg<CR><SID>WE
map <silent> <Leader>t?   <SID>WS:AlignCtrl mIp0P0=l ?<CR>:'a,.Align<CR>:.,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <Leader>t~   <SID>WS:AlignCtrl mIp0P0=l ~<CR>:'a,.Align<CR>:'y,'zs/ \( *\);/;\1/ge<CR><SID>WE
map <silent> <Leader>m=   <SID>WS:'a,'zs/\s\+\([*/+\-%<Bar>&\~^]\==\)/ \1/e<CR>:'a,'zs@ \+\([*/+\-%<Bar>&\~^]\)=@\1=@ge<CR>:'a,'zs/==/\="\<Char-0xff>\<Char-0xff>"/ge<CR>:'a,'zs/!=/\="!\<Char-0xff>"/ge<CR>'zk:AlignCtrl mIp1P1=l =<CR>:AlignCtrl g =<CR>:'a,'z-1Align<CR>:'a,'z-1s@\([*/+\-%<Bar>&\~^!=]\)\( \+\)=@\2\1=@ge<CR>:'a,'z-1s/\( \+\);/;\1/ge<CR>:'a,'z-s/%\ze[^=]/ @%@ /e<CR>'zk<Leader>t@:'y,'zs/^\(\s*\) @/\1/e<CR>:'a,'z-1s/\xff/=/ge<CR>:'y,'zs/ @//eg<CR><SID>WE
map <silent> <Leader>tab  <SID>WS:'a,.s/^\(\t*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\t','@','g'),'\')/<CR>:AlignCtrl mI=l @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <Leader>tml  <SID>WS:AlignCtrl mWp1P0=l \\\@<!\\\s*$<CR>:'a,.Align<CR><SID>WE
map <silent> <Leader>tsp  <SID>WS:'a,.s/^\(\s*\)\(.*\)/\=submatch(1).escape(substitute(submatch(2),'\s\+','@','g'),'\')/<CR>:AlignCtrl mI=lp0P0 @<CR>:'a,.Align<CR>:'y+1,'z-1s/@/ /g<CR><SID>WE
map <silent> <Leader>tsq  <SID>WS:'a,.AlignReplaceQuotedSpaces<CR>:'a,.s/^\(\s*\)\(.*\)/\=submatch(1).substitute(submatch(2),'\s\+','@','g')/<CR>:AlignCtrl mIp0P0=l @<CR>:'a,.Align<CR>:'y+1,'z-1s/[%@]/ /g<CR><SID>WE
map <silent> <Leader>tt   <SID>WS:AlignCtrl mIp1P1=l \\\@<!& \\\\<CR>:'a,.Align<CR><SID>WE

" ---------------------------------------------------------------------
" plain Align maps; these two are used in <Leader>acom..\afnc	{{{1
map <silent> <Leader>t@   :AlignCtrl mIp1P1=l @<CR>:'a,.Align<CR>
map <silent> <Leader>tW@  :AlignCtrl mWp1P1=l @<CR>:'a,.Align<CR>
map <silent> <Leader>tdW@ :AlignCtrl v ^\s*/[/*]<CR>:AlignCtrl mWp1P1=l @<CR>:'a,.Align<CR>

" ---------------------------------------------------------------------
" Joiner : maps used above	{{{1
map <silent> <Leader>jnr=  :call <SID>CharJoiner("=")<CR>
map <silent> <Leader>jnr,  :call <SID>CharJoiner(",")<CR>

" ---------------------------------------------------------------------
" visual-line mode variants: {{{1
vmap <silent> <Leader>T|	:<BS><BS><BS><CR>ma'><Leader>T|
vmap <silent> <Leader>T,	:<BS><BS><BS><CR>ma'><Leader>T,
vmap <silent> <Leader>Ts,	:<BS><BS><BS><CR>ma'><Leader>Ts,
vmap <silent> <Leader>T:	:<BS><BS><BS><CR>ma'><Leader>T:
vmap <silent> <Leader>T<	:<BS><BS><BS><CR>ma'><Leader>T<
vmap <silent> <Leader>T=	:<BS><BS><BS><CR>ma'><Leader>T=
vmap <silent> <Leader>T@	:<BS><BS><BS><CR>ma'><Leader>T@
vmap <silent> <Leader>Tsp	:<BS><BS><BS><CR>ma'><Leader>Tsp
vmap <silent> <Leader>a?	:<BS><BS><BS><CR>ma'><Leader>a?
vmap <silent> <Leader>a,	:<BS><BS><BS><CR>ma'><Leader>a,
vmap <silent> <Leader>a<	:<BS><BS><BS><CR>ma'><Leader>a<
vmap <silent> <Leader>a=	:<BS><BS><BS><CR>ma'><Leader>a=
vmap <silent> <Leader>abox	:<BS><BS><BS><CR>ma'><Leader>abox
vmap <silent> <Leader>acom	:<BS><BS><BS><CR>ma'><Leader>acom
vmap <silent> <Leader>aocom	:<BS><BS><BS><CR>ma'><Leader>aocom
vmap <silent> <Leader>ascom	:<BS><BS><BS><CR>ma'><Leader>ascom
vmap <silent> <Leader>adec	:<BS><BS><BS><CR>ma'><Leader>adec
vmap <silent> <Leader>adef	:<BS><BS><BS><CR>ma'><Leader>adef
vmap <silent> <Leader>afnc	:<BS><BS><BS><CR>ma'><Leader>afnc
vmap <silent> <Leader>anum	:<BS><BS><BS><CR>ma'><Leader>anum
vmap <silent> <Leader>t|	:<BS><BS><BS><CR>ma'><Leader>t|
vmap <silent> <Leader>t,	:<BS><BS><BS><CR>ma'><Leader>t,
vmap <silent> <Leader>ts,	:<BS><BS><BS><CR>ma'><Leader>ts,
vmap <silent> <Leader>t:	:<BS><BS><BS><CR>ma'><Leader>t:
vmap <silent> <Leader>t;	:<BS><BS><BS><CR>ma'><Leader>t;
vmap <silent> <Leader>t<	:<BS><BS><BS><CR>ma'><Leader>t<
vmap <silent> <Leader>t=	:<BS><BS><BS><CR>ma'><Leader>t=
vmap <silent> <Leader>t?	:<BS><BS><BS><CR>ma'><Leader>t?
vmap <silent> <Leader>t@	:<BS><BS><BS><CR>ma'><Leader>t@
vmap <silent> <Leader>tab	:<BS><BS><BS><CR>ma'><Leader>tab
vmap <silent> <Leader>tml	:<BS><BS><BS><CR>ma'><Leader>tml
vmap <silent> <Leader>tsp	:<BS><BS><BS><CR>ma'><Leader>tsp
vmap <silent> <Leader>tsq	:<BS><BS><BS><CR>ma'><Leader>tsq
vmap <silent> <Leader>tp@	:<BS><BS><BS><CR>ma'><Leader>tp@
vmap <silent> <Leader>tt	:<BS><BS><BS><CR>ma'><Leader>tt
vmap <silent> <Leader>Htd	:<BS><BS><BS><CR>ma'><Leader>Htd
vmap <silent> <Leader>anum  :B s/\(\d\)\s\+\(-\=[.,]\=\d\)/\1@\2/ge<CR>:AlignCtrl mp0P0<CR>gv:Align [.,@]<CR>:'<,'>s/\([-0-9.,]*\)\(\s\+\)\([.,]\)/\2\1\3/ge<CR>:'<,'>s/@/ /ge<CR>

" ---------------------------------------------------------------------
" CharJoiner: joins lines which end in the given character (spaces {{{1
"             at end are ignored)
fun! <SID>CharJoiner(chr)
"  call Dfunc("CharJoiner(chr=".a:chr.")")
  let aline = line("'a")
  let rep   = line(".") - aline
  while rep > 0
  	norm! 'a
  	while match(getline(aline),a:chr . "\s*$") != -1 && rep >= 0
  	  " while = at end-of-line, delete it and join with next
  	  norm! 'a$
  	  j!
  	  let rep = rep - 1
  	endwhile
  	" update rep(eat) count
  	let rep = rep - 1
  	if rep <= 0
  	  " terminate loop if at end-of-block
  	  break
  	endif
  	" prepare for next line
  	norm! jma
  	let aline = line("'a")
  endwhile
"  call Dret("CharJoiner")
endfun

" ---------------------------------------------------------------------
" Afnc: useful for splitting one-line function beginnings {{{1
"            into one line per argument format
fun! <SID>Afnc()
"  call Dfunc("Afnc()")

  " keep display quiet
  let chkeep = &ch
  let gdkeep = &gd
  let vekeep = &ve
  set ch=2 nogd ve=

  " will use marks y,z ; save current values
  let mykeep = SaveMark("'y")
  let mzkeep = SaveMark("'z")

  " Find beginning of function -- be careful to skip over comments
  let cmmntid  = synIDtrans(hlID("Comment"))
  let stringid = synIDtrans(hlID("String"))
  exe "norm! ]]"
  while search(")","bW") != 0
"   call Decho("line=".line(".")." col=".col("."))
   let parenid= synIDtrans(synID(line("."),col("."),1))
   if parenid != cmmntid && parenid != stringid
   	break
   endif
  endwhile
  norm! %my
  s/(\s*\(\S\)/(\r  \1/e
  exe "norm! `y%"
  s/)\s*\(\/[*/]\)/)\r\1/e
  exe "norm! `y%mz"
  'y,'zs/\s\+$//e
  'y,'zs/^\s\+//e
  'y+1,'zs/^/  /

  " insert newline after every comma only one parenthesis deep
  sil! exe "norm! `y\<right>h"
  let parens   = 1
  let cmmnt    = 0
  let cmmntline= -1
  while parens >= 1
"   call Decho("parens=".parens." @a=".@a)
   exe 'norm! ma "ay`a '
   if @a == "("
    let parens= parens + 1
   elseif @a == ")"
    let parens= parens - 1

   " comment bypass:  /* ... */  or //...
   elseif cmmnt == 0 && @a == '/'
    let cmmnt= 1
   elseif cmmnt == 1
	if @a == '/'
	 let cmmnt    = 2   " //...
	 let cmmntline= line(".")
	elseif @a == '*'
	 let cmmnt= 3   " /*...
	else
	 let cmmnt= 0
	endif
   elseif cmmnt == 2 && line(".") != cmmntline
	let cmmnt    = 0
	let cmmntline= -1
   elseif cmmnt == 3 && @a == '*'
	let cmmnt= 4
   elseif cmmnt == 4
	if @a == '/'
	 let cmmnt= 0   " ...*/
	elseif @a != '*'
	 let cmmnt= 3
	endif

   elseif @a == "," && parens == 1 && cmmnt == 0
	exe "norm! i\<CR>\<Esc>"
   endif
  endwhile
  norm! `y%mz%
  sil! 'y,'zg/^\s*$/d

  " perform substitutes to mark fields for Align
  sil! 'y+1,'zv/^\//s/^\s\+\(\S\)/  \1/e
  sil! 'y+1,'zv/^\//s/\(\S\)\s\+/\1 /eg
  sil! 'y+1,'zv/^\//s/\* \+/*/ge
  "                                                 func
  "                    ws  <- declaration   ->    <-ptr  ->   <-var->    <-[array][]    ->   <-glop->      <-end->
  sil! 'y+1,'zv/^\//s/^\s*\(\(\K\k*\s*\)\+\)\s\+\([(*]*\)\s*\(\K\k*\)\s*\(\(\[.\{-}]\)*\)\s*\(.\{-}\)\=\s*\([,)]\)\s*$/  \1@#\3@\4\5@\7\8/e
  sil! 'y+1,'z+1g/^\s*\/[*/]/norm! kJ
  sil! 'y+1,'z+1s%/[*/]%@&@%ge
  sil! 'y+1,'z+1s%*/%@&%ge
  AlignCtrl mIp0P0=l @
  sil! 'y+1,'zAlign
  sil! 'y,'zs%@\(/[*/]\)@%\t\1 %e
  sil! 'y,'zs%@\*/% */%e
  sil! 'y,'zs/@\([,)]\)/\1/
  sil! 'y,'zs/@/ /
  AlignCtrl mIlrp0P0= # @
  sil! 'y+1,'zAlign
  sil! 'y+1,'zs/#/ /
  sil! 'y+1,'zs/@//
  sil! 'y+1,'zs/\(\s\+\)\([,)]\)/\2\1/e

  " Restore
  call RestoreMark(mykeep)
  call RestoreMark(mzkeep)
  let &ch= chkeep
  let &gd= gdkeep
  let &ve= vekeep

"  call Dret("Afnc")
endfun

" ---------------------------------------------------------------------
"  FixMultiDec: converts a   type arg,arg,arg;   line to multiple lines {{{1
fun! s:FixMultiDec()
"  call Dfunc("FixMultiDec()")

  " save register x
  let xkeep   = @x
  let curline = getline(".")
"  call Decho("curline<".curline.">")

  " Get the type.  I'm assuming one type per line (ie.  int x; double y;   on one line will not be handled properly)
  let @x=substitute(curline,'^\(\s*[a-zA-Z_ \t][a-zA-Z0-9_ \t]*\)\s\+[(*]*\h.*$','\1','')
"  call Decho("@x<".@x.">")

  " transform line
  exe 's/,/;\r'.@x.' /ge'

  "restore register x
  let @x= xkeep

"  call Dret("FixMultiDec : my=".line("'y")." mz=".line("'z"))
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" ------------------------------------------------------------------------------
" vim: ts=4 nowrap fdm=marker
