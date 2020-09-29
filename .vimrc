syntax on
" language-aware auto-complete shortcut (Visual Studio style)
"inoremap <C-Space> <C-x><C-o>
" conditional auto-complete 
" source: https://vi.stackexchange.com/a/14977
inoremap <expr> <Tab> getline('.')[col('.') - 2] =~ '\a' ? "\<C-p>" : "\<Tab>"
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
" ignore case when performing string searches
set ignorecase
" VS-like build hotkey ------------------------------------------------------{{{
noremap <F7> :call BuildBatch()<CR>
function BuildBatch()
	if exists('g:jobBuild')
		echo 'build job already running!'
		return 1
	endif
	" before writing all buffers to disk, clear the previous contents of the 
	" temp build output buffer
	let bufferWindowNumber = bufwinnr('/tmp/vim_build_job_output')
	if buflisted('/tmp/vim_build_job_output')
		" just close the buffer & discard changes to remove the need to write an 
		" empty temp file
		" @TODO: preserve the "previous" buffer memory so that <C-6> still
		"        takes you back to the correct previous buffer after a build
		if bufferWindowNumber == -1
			" if the buffer isn't open in a window, we can just discard it!
			silent bdelete! /tmp/vim_build_job_output
		else
			" otherwise: 
			"	- switch to the buffer window
			"	- change to a new buffer
			"	- delete the buffer
			"	- switch to the previous window
			execute bufferWindowNumber.'wincmd w'
			silent bNext!
			silent bdelete! /tmp/vim_build_job_output
			wincmd p
		endif
	endif
	" before starting a build, write all the buffers to disk
	silent wall
	" create a new buffer to hold the output of the build job
	silent edit /tmp/vim_build_job_output
	" return to the previous buffer
	silent buffer! #
	" if the build job output buffer was previously in a window before being
	" deleted, let's bring it back
	if bufferWindowNumber != -1
		" go to the split window which contained the build job output buffer
		execute bufferWindowNumber.'wincmd w'
		" open the build job output buffer
		silent buffer /tmp/vim_build_job_output
		" scroll all the way to the bottom of the buffer
		normal! G
		" go back to the previous window
		wincmd p
	endif
	echo 'KML project build job ...'
	" while we're at it, we can just generate the ctags for the project ~
	" @TODO: why can I not just pass "expand('$kml_home_cygpath').'/code*'"
	"        here instead of having to specify each directory individually??
	" @TODO: separate the microsoft includes from KML includes, check to see
	"        if the microsoft includes have been tagged, if they haven't then
	"        make the tag file, otherwise just make the KML tag file by
	"        appending it to the existing microsoft tag file???
	"let includePathList = split(expand('$include_cygpaths'),';')
	let includePathList = 
		\[ expand('$kml_home_cygpath')    . '/code'
		\, expand('$kml_home_cygpath')    . '/code-utilities'
		\, expand('$project_root_cygpath'). '/code' ]
	call job_start(['ctags', '-R', '--totals'] + includePathList)
	" actually start the job which will run the KML build script
	let g:jobBuildExitStatus = 0
	let g:jobBuild = job_start(
		\ 'build.bat', 
		\ {'out_io': 'buffer', 'out_name':'/tmp/vim_build_job_output', 
		\  'close_cb': 'OnJobBuildClose', 'err_cb': 'OnJobBuildError', 
		\  'exit_cb': 'OnJobBuildExit'})
endfunction
" this function seems extremely useless since exitStatus appears to always
" return 0
function OnJobBuildExit(job, exitStatus)
	" echom "Build job exitStatus=".a:exitStatus
endfunction
function OnJobBuildError(channel, message)
	" echom "Build job error message:'".a:message."'"
	" search stderr output for a magic string telling us that KML failed to
	" build, because apparently getting the exit status of the build batch
	" script doesn't seem to work... ugh.
	if stridx(a:message, "KML build failed!") > -1
		" echom "-----------build failure detected!--------------"
		let g:jobBuildExitStatus = 1
	endif
endfunction
function OnJobBuildClose(channel)
	echo "KML project build job ... DONE. (exit status=" . 
		\g:jobBuildExitStatus . ")"
	unlet g:jobBuild
	if g:jobBuildExitStatus == 0
		echo "KML project build job ... COMPLETE!" 
		" play a happy sound once we're done~~~
		" source: https://stackoverflow.com/a/14678671/4526664
		let powershellArg = "(New-Object Media.SoundPlayer " . 
			\ "'c:/Windows/Media/tada.wav').PlaySync();"
	else
		echo "KML project build job ... FAILED... " . 
			\"see '/tmp/vim_build_job_output' buffer for info!" 
		" play a sad sound if build failed :(
		let powershellArg = "(New-Object Media.SoundPlayer " . 
			\ "'c:/Windows/Media/Windows Critical Stop.wav').PlaySync();"
	endif
	call job_start(['powershell','-c',powershellArg])
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
	call job_start(['autohotkey',
		\$KML_HOME . '/misc/debug-in-visual-studio.ahk'])
endfunction
" }}} run program hotkey

