syntax on
" language-aware auto-complete shortcut (Visual Studio style)
inoremap <C-Space> <C-x><C-o>
" easy buffer cycling with C-PageUp & C-PageDown
nnoremap <C-PageUp> :bp!<cr>
nnoremap <C-PageDown> :bn!<cr>
" \b => easier buffer swapping
" source: https://vi.stackexchange.com/a/2187
nnoremap <Leader>b :ls<CR>:b!<Space>
" easily escape from INSERT mode without reaching to the ESC key
:map! jk <ESC>
" swap : & ; so I don't have to keep pressing shift all the time
nnoremap ; :
nnoremap : ;
" close buffer without closing a split window
" source: https://stackoverflow.com/a/29179159/4526664
command Bd bp<bar>bd #
" \w => close buffer without closing split window
:nnoremap <Leader>w :Bd<cr>
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
call matchadd('StrangeWhitespace', '[\x0b\x0c\r\x1c\x1d\x1e\x1f\x85\u1680' . 
	\ '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a' . 
	\ '\u2028\u2029\u202f\u205f\u3000]')
" MISC. settings...
set scrolloff=5
set undolevels=1000
set nocompatible
set autoindent smartindent
set smarttab
set number relativenumber
set tabstop=4 shiftwidth=4
" VS-like build hotkey ------------------------------------------------------{{{
noremap <F7> :call BuildBatch()<CR>
function BuildBatch()
	if exists('g:jobBuild')
		echo 'build job already running!'
		return 1
	endif
	" before writing all buffers to disk, clear the previous contents of the 
	" temp build output buffer
	if bufexists('/tmp/vim_build_job_output')
		" @TODO: just close the buffer & discard changes if the buffer is not
		"        currently open in a window to remove the need to write an
		"        empty temp file
		let alreadyInBuildOutput = (@% ==# '/tmp/vim_build_job_output')
		if !alreadyInBuildOutput
			silent buffer! /tmp/vim_build_job_output
		endif
		silent %delete
		if !alreadyInBuildOutput
			silent buffer! #
		endif
	endif
	" before starting a build, write all the buffers to disk
	silent wall
	echo 'KML project build job ...'
	" while we're at it, we can just generate the ctags for the project ~
	call job_start('ctags -R $kml_home_cygpath/code* ' . 
		\ '$project_root_cygpath/code*')
	" actually start the job which will run the KML build script
	let g:jobBuild = job_start(
		\ "build.bat", 
		\ {'out_io': 'buffer', 'out_name':'/tmp/vim_build_job_output', 
		\  'close_cb': 'OnJobBuildClose'})
endfunction
function OnJobBuildClose(channel)
	echo 'KML project build job ... DONE.'
	unlet g:jobBuild
endfunction
" }}} build hotkey
" VSCode-like display of the build job's output -----------------------------{{{
noremap <C-`> :silent call ToggleBuildJobOutput()<CR>
function ToggleBuildJobOutput()
	let bufferWindowNumber = bufwinnr('/tmp/vim_build_job_output')
	if bufferWindowNumber == -1
		split
		resize 10
		edit /tmp/vim_build_job_output
		" scroll all the way to the bottom of the buffer
		normal! G
		" return to the previous window 
		"execute "normal! \<c-w>p"
		wincmd p
	else
		" go to the split window containing the build job output buffer
		execute bufferWindowNumber.'wincmd w'
		" ...and close it without losing buffer contents
		close!
	endif
endfunction
" }}} toggle build job output
" VS-like RUN hotkey --------------------------------------------------------{{{
noremap <F5> :call RunBuild()<CR>
function RunBuild()
	" @TODO: figure out if it's possible to just start the application inside
	" the visual studio debugger...
	call job_start($project_root_cygpath . "/build/" . 
		\ $kmlApplicationName . ".exe") 
endfunction
" }}} run program hotkey

