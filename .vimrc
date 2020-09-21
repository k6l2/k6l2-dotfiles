syntax on
" language-aware auto-complete shortcut (Visual Studio style)
inoremap <C-Space> <C-x><C-o>
" easily escape from INSERT mode without reaching to the ESC key
:map! jk <ESC>
" swap : & ; so I don't have to keep pressing shift all the time
nnoremap ; :
nnoremap : ;
" close buffer without closing a split window
" source: https://stackoverflow.com/a/29179159/4526664
command Bd bp<bar>bd #
" open a vertical split window of the current working directory
command Dir vert sp<bar>E<bar>vert resize 40
" highlight everything past column 80
" source: https://stackoverflow.com/a/13731714/4526664
highlight ColorColumn ctermbg=DarkRed
"let &colorcolumn=join(range(81,999),",")
" source: https://stackoverflow.com/a/3765575/4526664
set colorcolumn=81
" set whitespace character glyphs 
" (turn on : ":set list")
" (turn off: ":set nolist")
" source: https://stackoverflow.com/a/29787362/4526664
" set listchars=eol:¬,tab:>_,trail:~,extends:>,precedes:<,space:␣
" source: https://stackoverflow.com/a/51195979/4526664
set listchars=tab:│\ ,nbsp:·
set list
highlight StrangeWhitespace guibg=Red ctermbg=Red
" The list is from https://stackoverflow.com/a/37903645 
" (with `\t`, `\n`, ` `, `\xa0` removed):
call matchadd('StrangeWhitespace', '[\x0b\x0c\r\x1c\x1d\x1e\x1f\x85\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000]')
" MISC. settings...
set scrolloff=5
set undolevels=1000
set nocompatible
set autoindent smartindent
set smarttab
set number relativenumber
set tabstop=4 shiftwidth=4
