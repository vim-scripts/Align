" AlignPlugin: tool to align multiple fields based on one or more separators
"   Author:	 Charles E. Campbell, Jr.
"   Date:    Jul 18, 2006
" GetLatestVimScripts: 294 1 :AutoInstall: Align.vim
" GetLatestVimScripts: 1066 1 cecutil.vim
" Copyright:    Copyright (C) 1999-2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               Align.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
"   Usage: Functions {{{1
"   AlignCtrl(style,..list..)
"
"        "default" : Sets AlignCtrl to its default values and clears stack
"                    AlignCtrl "Ilp1P1=<" '='
"
"         Separators
"              "=" : all alignment demarcation patterns (separators) are
"                    equivalent and simultaneously active.  The list of
"                    separators is composed of such patterns
"                    (regular expressions, actually).
"              "C" : cycle through alignment demarcation patterns
"              "<" : separators aligned to left   if of differing lengths
"              ">" : separators aligned to right  if of differing lengths
"              "|" : separators aligned to center if of differing lengths
"
"         Alignment/Justification
"              "l" : left justify  (no list needed)
"              "r" : right justify (no list needed)
"              "c" : center        (no list needed)
"                    Justification styles are cylic: ie. "lcr" would
"                    mean first field is left-justifed,
"                        second field is centered,
"                        third  field is right-justified,
"                        fourth field is left-justified, etc.
"              "-" : skip this separator+ws+field
"              "+" : repeat last alignment/justification indefinitely
"              ":" : no more alignment/justifcation
"
"         Map Support
"              "m" : next call to Align will AlignPop at end.
"                    AlignCtrl will AlignPush first.
"
"         Padding
"              "p" : current argument supplies pre-field-padding parameter;
"                    ie. that many blanks will be applied before
"                    the field separator. ex. call AlignCtrl("p2").
"                    Can have 0-9 spaces.  Will be cycled through.
"              "P" : current argument supplies post-field-padding parameter;
"                    ie. that many blanks will be applied after
"                    the field separator. ex. call AlignCtrl("P3")
"                    Can have 0-9 spaces.  Will be cycled through.
"
"         Initial White Space
"              "I" : preserve first line's leading whitespace and re-use
"                    subsequently
"              "W" : preserve leading whitespace on every line
"              "w" : don't preserve leading whitespace
"
"         Selection Patterns
"              "g" : restrict alignment to pattern
"              "v" : restrict alignment to not-pattern
"
"              If no arguments are supplied, AlignCtrl() will list
"              current settings.
"
"   [range]Align(..list..)
"              Takes a range and performs the specified alignment on the
"              text.  The range may be :line1,line2 etc, or visually selected.
"              The list is a list of patterns; the current s:AlignCtrl
"              will be used ('=' or 'C').
"
"   Usage: Commands	{{{1
"   AlignCtrl                : lists current alignment settings
"   AlignCtrl style ..list.. : set alignment separators
"   AlignCtrl {gv} pattern   : apply alignment only to lines which match (g)
"                              or don't match (v) the given pattern
"   [range]Align ..list..    : applies Align() over the specified range
"                              The range may be specified via
"                              visual-selection as well as the usual
"                              [range] specification.  The ..list..
"                              is a list of alignment separators.
"
" Romans 1:16,17a : For I am not ashamed of the gospel of Christ, for it is {{{1
" the power of God for salvation for everyone who believes; for the Jew first,
" and also for the Greek.  For in it is revealed God's righteousness from
" faith to faith.
" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_alignPlugin")
 finish
endif
let g:loaded_alignPlugin = 1
let s:keepcpo            = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Public Interface: {{{1
com! -range -nargs=* Align <line1>,<line2>call Align#Align(<f-args>)
com! -range -nargs=0 AlignReplaceQuotedSpaces <line1>,<line2>call Align#AlignReplaceQuotedSpaces()
com!        -nargs=* AlignCtrl call Align#AlignCtrl(<f-args>)
com!        -nargs=0 AlignPush call Align#AlignPush()
com!        -nargs=0 AlignPop  call Align#AlignPop()

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
