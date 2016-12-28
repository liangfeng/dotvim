" Author:   Liang Feng <liang.feng98 AT gmail DOT com>
" Brief:    This vimrc supports Mac OS, Linux(Ubuntu) and Windows(both GUI & console version).
"           While it is well commented, just in case some commands confuse you,
"           please RTFM by ':help WORD' or ':helpgrep WORD'.
" HomePage: https://github.com/liangfeng/dotvim
" Comments: has('mac') means Mac only.
"           has('unix') means Mac, Linux or Unix only.
"           has('win16') means Windows 16 only.
"           has('win32') means Windows 32 only.
"           has('win64') means Windows 64 only.
"           has('gui_running') means in GUI mode.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Check Prerequisite {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if v:version < 704
    echohl WarningMsg
    echomsg 'Requires Vim 7.4 or above or Neovim. The current version of Vim is "' . v:version . '".'
    echohl None
endif

if !has('python')
    echohl WarningMsg
    echomsg 'Requires Vim/Neovim compiled with "+python" to use enhanced feature.'
    echohl None
endif

if !has('nvim')
    if !has('lua')
        echohl WarningMsg
        echomsg 'Requires Vim compiled with "+lua" to use enhanced feature.'
        echohl None
    endif
endif

" End of Check Prerequisite }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remove ALL autocmds for the current group
autocmd!

" Use Vim settings, rather then Vi settings.
" This option must be set first, since it changes other option's behavior.
set nocompatible

" Check OS and env.
let s:is_mac = has('mac')
let s:is_unix = has('unix')
let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_gui_running = has('gui_running')
let s:is_nvim = has('nvim')

let g:maplocalleader = "\<Space>"
let g:mapleader = "\<Space>"

" In Windows, If vim starts without opening file(s),
" change working directory to '$HOME/vimfiles'
if s:is_windows
    if expand('%') == ''
        cd $HOME/vimfiles
    endif
endif

" Setup dein plugin.
" Must be called before filetype on.
if s:is_unix
    set runtimepath+=$HOME/.vim/bundle/repos/github.com/Shougo/dein.vim
    call dein#begin('$HOME/.vim/bundle')
else
    " TODO: Support dein.vim on Windows
    set runtimepath=$HOME/vimfiles/bundle/repos/github.com/Shougo/dein.vim,$VIMRUNTIME
    call dein#begin('$HOME/vimfiles/bundle')
endif

" Let dein manage dein
call dein#add('Shougo/dein.vim')

" If unix style 'rmdir' is installed , it can not handle directory properly,
" must setup rm_command explicitly in Windows to use builtin 'rmdir' cmd.
if s:is_windows
    let g:neobundle#rm_command = 'cmd.exe /C rmdir /S /Q'
    let g:neobundle#install_max_processes = 15
    " YouCompleteMe plugin is too large
    let g:neobundle#install_process_timeout = 1800
endif

" Do not load system menu, before ':syntax on' and ':filetype on'.
if s:is_gui_running
    set guioptions+=M
endif

" End of Init }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Startup/Exit {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shortmess+=I

if s:is_gui_running
    if s:is_unix && !s:is_mac
        " Install wmctrl first, 'sudo apt-get install wmctrl'
        function! s:MaxWindowSize()
            call system('wmctrl -ir ' . v:windowid . ' -b add,maximized_vert,maximized_horz')
        endfunction

        function! s:RestoreWindowSize()
            call system('wmctrl -ir ' . v:windowid . ' -b remove,maximized_vert,maximized_horz')
        endfunction

        function! s:ToggleWindowSize()
            call system('wmctrl -ir ' . v:windowid . ' -b toggle,maximized_vert,maximized_horz')
        endfunction

    elseif s:is_windows
        function! s:MaxWindowSize()
            simalt ~x
        endfunction

        function! s:RestoreWindowSize()
            simalt ~r
        endfunction

        function! s:ToggleWindowSize()
            if exists('g:does_windows_need_max')
                let g:does_windows_need_max = !g:does_windows_need_max
            else
                " Need to restore window, since gvim run into max mode by default.
                let g:does_windows_need_max = 0
            endif
            if g:does_windows_need_max == 1
                " Use call-style for using in mappings.
                :call s:MaxWindowSize()
            else
                " Use call-style for using in mappings.
                :call s:RestoreWindowSize()
            endif
        endfunction
    endif

    command! Max call s:MaxWindowSize()
    command! Res call s:RestoreWindowSize()
    command! Tog call s:ToggleWindowSize()

    " Run gvim with max mode by default.
    autocmd GUIEnter * Max

    nnoremap <silent> <Leader>W :Tog<CR>
endif

language messages en_US.utf-8

" XXX: Change it. It's just for my environment.
if !isdirectory($HOME . '/tmp')
    call mkdir($HOME . '/tmp')
endif

let $TMP = expand('~/tmp')

set viminfo+=n$HOME/tmp/.viminfo

" Locate the cursor at the last edited location when open a file
autocmd BufReadPost *
    \ if line("'\"") <= line("$") |
    \   exec "normal! g`\"" |
    \ endif

" End of Startup }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let &termencoding = &encoding
let legacy_encoding = &encoding
set encoding=utf-8
scriptencoding utf-8

set fileencodings=ucs-bom,utf-8,default,gb18030,big5,latin1
if legacy_encoding != 'latin1'
    let &fileencodings=substitute(
                \&fileencodings, '\<default\>', legacy_encoding, '')
else
    let &fileencodings=substitute(
                \&fileencodings, ',default,', ',', '')
endif

" This function is revised from Wu yongwei's vimrc.
" Function to display the current character code in its 'file encoding'
function! s:EchoCharCode()
    let char_enc = matchstr(getline('.'), '.', col('.') - 1)
    let char_fenc = iconv(char_enc, &encoding, &fileencoding)
    let i = 0
    let char_len = len(char_fenc)
    let hex_code = ''
    while i < char_len
        let hex_code .= printf('%.2x',char2nr(char_fenc[i]))
        let i += 1
    endwhile
    echo '<' . char_enc . '> Hex ' . hex_code . ' (' .
          \(&fileencoding != '' ? &fileencoding : &encoding) . ')'
endfunction

" Key mapping to display the current character in its 'file encoding'
nnoremap <silent> gn :call <SID>EchoCharCode()<CR>

" End of Encoding }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_gui_running
    if s:is_mac
        set guifont=Monaco:h12
    elseif s:is_windows
        set guifont=Powerline_Consolas:h12:cANSI
        set guifontwide=YaHei_Consolas_Hybrid:h12
    else
        set guifont=Ubuntu\ Mono\ for\ Powerline\ 15
    endif
endif

if s:is_mac && s:is_gui_running
    set fuoptions+=maxhorz
    nnoremap <silent> <D-f> :set invfullscreen<CR>
    inoremap <silent> <D-f> <C-o>:set invfullscreen<CR>
endif

" Turn on syntax highlighting.
" Delete colors_name for vimrc re-sourcing.
if exists('g:colors_name')
    unlet g:colors_name
endif

syntax on

" End of UI }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editting {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set directory=$TMP

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup

" keep 400 lines of command line history
set history=400

set completeopt-=preview

" Enable mouse only in 'normal' mode for scrolling
set mouse=n

" Disable middlemouse paste
noremap <silent> <MiddleMouse> <Nop>
inoremap <silent> <MiddleMouse> <Nop>
noremap <silent> <2-MiddleMouse> <Nop>
inoremap <silent> <2-MiddleMouse> <Nop>
noremap <silent> <3-MiddleMouse> <Nop>
inoremap <silent> <3-MiddleMouse> <Nop>
noremap <silent> <4-MiddleMouse> <Nop>
inoremap <silent> <4-MiddleMouse> <Nop>

" Disable bell on errors except for neovim on gnome-terminal, since
" gnone-terminal can not handle 'visualbell' properly.
if !(s:is_nvim && $COLORTERM == 'gnome-terminal')
    autocmd VimEnter * set visualbell t_vb=
endif

" remap Y to work properly
nnoremap <silent> Y y$

" Key mapping for confirmed exiting
nnoremap <silent> ZZ :confirm qa<CR>

" Create a new tabpage
nnoremap <silent> <Leader><Tab> :tabnew<CR>

if s:is_windows
    set shellslash
endif

" Execute command without disturbing registers and cursor postion.
function! s:Preserve(command)
    " Preparation: save last search, and cursor position.
    let s = @/
    let l = line(".")
    let c = col(".")
    " Do the business.
    exec a:command
    " Clean up: restore previous search history, and cursor position
    let @/ = s
    call cursor(l, c)
endfunction

function! s:RemoveTrailingSpaces()
    if &filetype != 'markdown'
        call s:Preserve('%s/\s\+$//e')
    endif
endfunction

" Remove trailing spaces for all files
autocmd BufWritePre * call s:RemoveTrailingSpaces()

" When buffer exists, go to the buffer.
" When buffer does NOT exists,
"   if current buffer is noname and empty, use current buffer. Otherwise use new tab
function! s:TabSwitch(...)
    for file in a:000
        let file_expanded = expand(file)
        if bufexists(file_expanded)
            exec 'sb ' . file_expanded
            continue
        endif
        if bufname('%') == '' && &modified == 0 && &modifiable == 1
            exec 'edit ' . file_expanded
        else
            exec 'tabedit ' . file_expanded
        endif
    endfor
endfunction

command! -complete=file -nargs=+ TabSwitch call s:TabSwitch(<q-args>)

" End of Editting }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching/Matching {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" incremental searching
set incsearch

" highlight the last used search pattern.
set hlsearch

" Simulate 'autochdir' option to avoid side-effect of this option.
autocmd BufEnter * if expand('%:p') !~ '://' | cd %:p:h | endif

" Use external grep command for performance
" XXX: In Windows, use cmds from 'git for Windows'.
"      Need prepend installed 'bin' directory to PATH env var in Windows.
set grepprg=grep\ -Hni

" auto center
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz

" Replace all matched items in the same line.
set gdefault

" Find buffer more friendly
set switchbuf=usetab

" :help CTRL-W_gf
" :help CTRL-W_gF
nnoremap <silent> gf <C-w>gf
nnoremap <silent> gF <C-w>gF

" Quick moving between tabs
nnoremap <silent> <C-Tab> gt

" Quick moving between windows
nnoremap <silent> <Leader>w <C-w>w

" Assume fast terminal connection.
set ttyfast

" Remap <Esc> to stop highlighting searching result.
if s:is_nvim || s:is_gui_running
    nnoremap <silent> <Esc> :nohls<CR><Esc>
    imap <silent> <Esc> <Esc><Esc>
endif

if !s:is_nvim && !s:is_gui_running
    " Use <nowait> to fast escape for nohls
    autocmd BufEnter * nnoremap <silent> <nowait> <buffer> <Esc> :nohls<CR><Esc>
    autocmd BufEnter * imap <silent> <nowait> <buffer> <Esc> <Esc><Esc>

    " fast escape from cmd mode to normal mode
    set ttimeoutlen=10

    " Enable arrow keys for terminal.
    nnoremap <silent> <Esc>OA <Up>
    nnoremap <silent> <Esc>OB <Down>
    nnoremap <silent> <Esc>OC <Right>
    nnoremap <silent> <Esc>OD <Left>
    inoremap <silent> <Esc>OA <Up>
    inoremap <silent> <Esc>OB <Down>
    inoremap <silent> <Esc>OC <Right>
    inoremap <silent> <Esc>OD <Left>

    " Eable 'Home' and 'End' keys for terminal.
    nnoremap <silent> <Esc>OH <Home>
    inoremap <silent> <Esc>OH <Home>
    nnoremap <silent> <Esc>OF <End>
    inoremap <silent> <Esc>OF <End>
endif

" move around the visual lines
nnoremap <silent> j gj
nnoremap <silent> k gk

" Make cursor move smooth
set whichwrap+=<,>,h,l

set ignorecase
set smartcase

set wildmenu

" Ignore files when completing.
set wildignore+=*.o
set wildignore+=*.obj
set wildignore+=*.bak
set wildignore+=*.exe
set wildignore+=*.swp
set wildignore+=*.pyc

nmap <silent> <Tab> %
nmap <silent> <S-Tab> g%

" Enable very magic mode for searching.
noremap / /\v
vnoremap / /\v

nnoremap ? ?\v
vnoremap ? ?\v

" Support */# in visual mode
function! s:VSetSearch()
    let temp = @@
    normal! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction

vnoremap <silent> * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap <silent> # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" Open another tabpage to view help.
nnoremap <silent> K :tab h <C-r><C-w><CR>
vnoremap <silent> K "ay:<C-u>tab h <C-r>a<CR>

" End of Searching/Matching }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formats/Style {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set autoindent
set smartindent
set display=lastline
set clipboard=unnamed,unnamedplus

vnoremap <silent> <Tab> >gv
vnoremap <silent> <S-Tab> <gv

set scrolloff=7

if s:is_gui_running
    set guioptions-=m
    set guioptions-=T
    set guioptions+=c
endif
set titlelen=0

" Make vim CJK-friendly
set formatoptions+=mM

" Show line number
set number

set cursorline

set laststatus=2

set fileformats=unix,dos

" Function to insert the current date
function! s:InsertCurrentDate()
    let curr_date = strftime('%Y-%m-%d', localtime())
    silent! exec 'normal! gi' .  curr_date . "\<Esc>a"
endfunction

" Key mapping to insert the current date
inoremap <silent> <C-d><C-d> <C-o>:call <SID>InsertCurrentDate()<CR>

" Eliminate comment leader when joining comment lines
function! s:JoinWithLeader(count, leaderText)
    let linecount = a:count
    " default number of lines to join is 2
    if linecount < 2
        let linecount = 2
    endif
    echo linecount . " lines joined"
    " clear errmsg so we can determine if the search fails
    let v:errmsg = ''

    " save off the search register to restore it later because we will clobber
    " it with a substitute command
    let savsearch = @/

    while linecount > 1
        " do a J for each line (no mappings)
        normal! J
        " remove the comment leader from the current cursor position
        silent! exec 'substitute/\%#\s*\%('.a:leaderText.'\)\s*/ /'
        " check v:errmsg for status of the substitute command
        if v:errmsg=~'E486'
            " just means the line wasn't a comment - do nothing
        elseif v:errmsg!=''
            echo "Problem with leader pattern for s:JoinWithLeader()!"
        else
            " a successful substitute will move the cursor to line beginning,
            " so move it back
            normal! ``
        endif
        let linecount = linecount - 1
    endwhile
    " restore the @/ register
    let @/ = savsearch
endfunction

function! s:MapJoinWithLeaders(leaderText)
    let leaderText = escape(a:leaderText, '/')
    " visual mode is easy - just remove comment leaders from beginning of lines
    " before using J normally
    exec "vnoremap <silent> <buffer> J :<C-u>let savsearch=@/<Bar>'<+1,'>".
                \'s/^\s*\%('.
                \leaderText.
                \'\)\s*/<Space>/e<Bar>'.
                \'let @/=savsearch<Bar>unlet savsearch<CR>'.
                \'gvJ'
    " normal mode is harder because of the optional count - must use a function
    exec "nnoremap <silent> <buffer> J :call <SID>JoinWithLeader(v:count, '".leaderText."')<CR>"
endfunction

" End of Formats/Style }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab/Buffer {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_gui_running
    " Only show short name in gui tab
    set guitablabel=%N\ %t%m%r
endif

" End of Tab/Buffer }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Scripts eval {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run the current buffer with interp.
function! s:EvalCodes(s, e, interp)
    pclose!
    silent exec a:s . ',' . a:e . 'y a'
    belowright new
    silent put a
    silent exec '%!' . a:interp . ' -'
    setlocal previewwindow
    setlocal noswapfile buftype=nofile bufhidden=wipe
    setlocal nobuflisted nowrap cursorline nonumber fdc=0
    setlocal ro nomodifiable
    wincmd p
endfunction

function! s:SetupAutoCmdForEvalCodes(interp)
    exec "nnoremap <buffer> <silent> <Leader>e :call <SID>EvalCodes('1', '$', '"
                \ . a:interp . "')<CR>"
    exec "command! -range Eval :if visualmode() ==# 'V' | call s:EvalCodes(<line1>,"
                \ . "<line2>, '" . a:interp . "') | endif"
    vnoremap <buffer> <silent> <Leader>e :<C-u>Eval<CR>
endfunction

" End of Scripts eval }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - Bash {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" :help ft-bash-syntax
let g:is_bash = 1

" End of Bash }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - C/C++ {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:GNUIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
endfunction

function! s:SetSysTags()
    " XXX: change it. It's just for my environment.
    " include system tags, :help ft-c-omni
    set tags+=$TMP/systags
endfunction

function! s:HighlightSpaceErrors()
    " Highlight space errors in C/C++ source files.
    " :help ft-c-syntax
    let g:c_space_errors = 1
endfunction

function! s:TuneCHighlight()
    " Tune for C highlighting
    " :help ft-c-syntax
    let g:c_gnu = 1
    " XXX: It's maybe a performance penalty.
    let g:c_curly_error = 1
endfunction

" Setup my favorite C/C++ indent
function! s:SetCPPIndent()
    setlocal cinoptions=(0,t0,w1 shiftwidth=4 tabstop=4
endfunction

" Setup basic C/C++ development envionment
function! s:SetupCppEnv()
    call s:SetSysTags()
    call s:HighlightSpaceErrors()
    call s:TuneCHighlight()
    call s:SetCPPIndent()
endfunction

" Setting for files following the GNU coding standard
if s:is_unix
    autocmd BufEnter /usr/include/* call s:GNUIndent()
elseif s:is_windows
    " XXX: change it. It's just for my environment.
    autocmd BufEnter ~/projects/g++/* call s:GNUIndent()
    set makeprg=nmake
endif

autocmd FileType c,cpp setlocal commentstring=\ //%s
autocmd FileType c,cpp call s:SetupCppEnv()
autocmd FileType c,cpp call s:MapJoinWithLeaders('//\\|\\')

" End of C/C++ }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - CSS {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS

" End of CSS }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - Help {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType help nnoremap <buffer> <silent> q :q<CR>
autocmd FileType help setlocal readonly nomodifiable number


" End of help }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - HTML {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Let TOhtml output <PRE> and style sheet
let g:html_use_css = 1
let g:use_xhtml = 1
autocmd FileType html,xhtml setlocal indentexpr=
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags

" End of HTML }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - javascript {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" End of Lua }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - Lua {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType lua call s:SetupAutoCmdForEvalCodes('luajit')
autocmd FileType lua call s:MapJoinWithLeaders('--\\|\\')

" End of Lua }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - Make {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType make setlocal noexpandtab
autocmd FileType make call s:MapJoinWithLeaders('#\\|\\')

" End of make }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - Python {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_highlight_all = 1

autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal commentstring=\ #%s
autocmd FileType python call s:SetupAutoCmdForEvalCodes('python')
autocmd FileType python call s:MapJoinWithLeaders('#\\|\\')

" End of Python }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - VimL {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run the current buffer as VimL
function! s:EvalVimL(s, e)
    pclose!
    let lines = getline(a:s, a:e)
    let file = tempname()
    call writefile(lines, file)
    redir @e
    silent exec ':source ' . file
    call delete(file)
    redraw
    redir END

    if strlen(getreg('e')) > 0
        belowright new
        redraw
        setlocal previewwindow
        setlocal noswapfile buftype=nofile bufhidden=wipe
        setlocal nobuflisted nowrap cursorline nonumber fdc=0
        syn match ErrorLine +^E\d\+:.*$+
        hi link ErrorLine Error
        silent put e
        setlocal ro nomodifiable
        wincmd p
    endif
endfunction

function! s:SetupAutoCmdForRunAsVimL()
    nnoremap <buffer> <silent> <Leader>e :call <SID>EvalVimL('1', '$')<CR>
    command! -range EvalVimL :call s:EvalVimL(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :<C-u>EvalVimL<CR>
endfunction

autocmd FileType vim setlocal commentstring=\ \"%s
autocmd FileType vim call s:SetupAutoCmdForRunAsVimL()
autocmd FileType vim call s:MapJoinWithLeaders('"\\|\\')

let g:vimsyn_noerror = 1

" End of VimL }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language - xml {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" End of xml }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vimrc {{{
" https://github.com/liangfeng/dotvim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_unix
    let g:vim_cfg_dir = '.vim'
elseif s:is_windows
    let g:vim_cfg_dir = 'vimfiles'
endif

" TODO: dein needs to support different base path.
" call dein#add('liangfeng/dotvim', {'rtp' : ''})

" For the fast editing
function! s:OpenVimrc()
    if s:is_unix
        call s:TabSwitch('$HOME/.vim/vimrc')
    elseif s:is_windows
        call s:TabSwitch('$HOME/vimfiles/vimrc')
    endif
endfunction

nnoremap <silent> <Leader>v :call <SID>OpenVimrc()<CR>

" End of vimrc }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - color_coded {{{
" https://github.com/jeaye/color_coded
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !s:is_nvim && !s:is_windows
    call dein#add('jeaye/color_coded', {
                \ 'lazy' : 1,
                \ 'on_ft' : ['c', 'cpp', 'objc', 'objcpp'],
                \ 'build' : 'make',
                \ })
endif

" End of color_coded }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - context_filetype {{{
" https://github.com/Shougo/context_filetype.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('Shougo/context_filetype.vim', {
            \ 'lazy' : 1,
            \ 'on_source' : ['deoplete.nvim']
            \ })

" End of context_filetype }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - delimitMate {{{
" https://github.com/Raimondi/delimitMate
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('Raimondi/delimitMate', {
            \ 'lazy' : 1,
            \ 'on_event' : 'InsertEnter',
            \ 'on_source' : ['deoplete.nvim', 'xptemplate']
            \ })

let plugin_name = 'delimitMate'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    let g:delimitMate_excluded_ft = 'mail,txt,text,,'
    let g:delimitMate_expand_cr = 1
    let g:delimitMate_balance_matchpairs = 1
    autocmd FileType vim let b:delimitMate_matchpairs = '(:),[:],{:},<:>'
    " To collaborate with xmledit plugin, remove <:> pairs from default pairs for xml and html
    autocmd FileType xml,html let b:delimitMate_matchpairs = '(:),[:],{:}'
    autocmd FileType html let b:delimitMate_quotes = '\" ''
    autocmd FileType python let b:delimitMate_nesting_quotes = ['"']
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of delimitMate }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - deoplete.nvim {{{
" https://github.com/Shougo/deoplete.nvim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_nvim
    call dein#add('Shougo/deoplete.nvim', {
                \ 'lazy' : 1,
                \ 'on_event' : 'InsertEnter'
                \ })

    let plugin_name = 'deoplete.nvim'
    let normalized_plugin_name = dein#get(plugin_name).normalized_name

    function! s:hook_source_{normalized_plugin_name}() abort
        let g:deoplete#enable_at_startup = 1
        let g:deoplete#enable_smart_case = 1

        " <Tab>: completion.
        inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
        inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'

        " Do NOT popup when enter <C-y> and <C-e>
        inoremap <silent> <expr> <C-y>  deoplete#mappings#close_popup() . '<C-y>'
        inoremap <silent> <expr> <C-e>  deoplete#mappings#cancel_popup() . '<C-e>'

    endfunction

    call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))
endif

" End of deoplete.nvim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - DoxygenToolkit.vim {{{
" https://github.com/vim-scripts/DoxygenToolkit.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('DoxygenToolkit.vim', {
            \ 'lazy' : 1,
            \ 'on_ft' : ['c', 'cpp', 'objc', 'objcpp', 'python']
            \ })

let plugin_name = 'DoxygenToolkit.vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
     " Load doxygen syntax file for c/cpp/idl files
     let g:load_doxygen_syntax = 1
     let g:DoxygenToolkit_commentType = "C++"
     let g:DoxygenToolkit_dateTag = ""
     let g:DoxygenToolkit_authorName = "liangfeng"
     let g:DoxygenToolkit_versionString = ""
     let g:DoxygenToolkit_versionTag = ""
     let g:DoxygenToolkit_briefTag_pre = "@brief:  "
     let g:DoxygenToolkit_fileTag = "@file:   "
     let g:DoxygenToolkit_authorTag = "@author: "
     let g:DoxygenToolkit_blockTag = "@name: "
     let g:DoxygenToolkit_paramTag_pre = "@param:  "
     let g:DoxygenToolkit_returnTag = "@return:  "
     let g:DoxygenToolkit_classTag = "@class: "
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of DoxygenToolkit.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - emmet-vim {{{
" https://github.com/mattn/emmet-vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('mattn/emmet-vim', {
            \ 'lazy' : 1,
            \ 'on_ft' : ['xml', 'html']
            \ })

let plugin_name = 'emmet-vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
     let g:use_emmet_complete_tag = 1
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of emmet-vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FencView.vim {{{
" https://github.com/mbbill/fencview
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('mbbill/fencview', {
            \ 'lazy' : 1,
            \ 'on_cmd' : ['FencAutoDetect', 'FencView', 'FencManualEncoding']
            \ })

" End of FencView.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FSwitch {{{
" https://github.com/derekwyatt/vim-fswitch
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need refining to catch exceptions or just rewrite one?
call dein#add('derekwyatt/vim-fswitch', {
            \ 'lazy' : 1,
            \ 'on_ft' : ['c', 'cpp'],
            \ 'on_cmd' : ['FS']
            \ })

let plugin_name = 'vim-fswitch'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    command! FS :FSSplitAbove
    let g:fsnonewfiles = 1
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of FSwitch }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - LargeFile {{{
" Origin: http://www.drchip.org/astronaut/vim/#LARGEFILE
" Forked: https://github.com/liangfeng/LargeFile
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('liangfeng/LargeFile')

" End of LargeFile }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - matchit {{{
" https://github.com/vim-scripts/matchit.zip
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"call dein#add('matchit.zip', {
"            \ 'lazy' : 1,
"            \ 'on_map' : ['%', 'g%']
"            \ })
"
"let plugin_name = 'matchit.zip'
"let normalized_plugin_name = dein#get(plugin_name).normalized_name
"
"function! s:hook_post_source_{normalized_plugin_name}() abort
"    silent! exec 'doautocmd Filetype' &filetype
"endfunction
"call dein#set_hook(plugin_name, 'hook_post_source', function('s:hook_post_source_' . normalized_plugin_name))

" End of matchit }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neomru.vim {{{
" https://github.com/Shougo/neomru.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('Shougo/neomru.vim', {
            \ 'lazy' : 1,
            \ 'on_source' : ['unite.vim']
            \ })

" End of neomru.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tcomment_vim {{{
" https://github.com/tomtom/tcomment_vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need try 'vim-commentary'?
call dein#add('tomtom/tcomment_vim', {
            \ 'lazy' : 1,
            \ 'on_cmd' : 'TComment',
            \ 'on_map' : '<Leader>cc'
            \ })

let plugin_name = 'tcomment_vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    map <silent> <Leader>cc :TComment<CR>
endfunction
call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of tcomment_vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_match.vim {{{
" https://github.com/vim-scripts/python_match.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('python_match.vim', {
            \ 'lazy' : 1,
            \ 'on_ft' : ['python']
            \ })

" End of python_match.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - session {{{
" https://github.com/xolox/vim-session
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need check this.
" call dein#add('xolox/vim-session')

" End of session }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SimpylFold for python {{{
" https://github.com/tmhedberg/SimpylFold
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('tmhedberg/SimpylFold', {
            \ 'lazy' : 1,
            \ 'on_ft' : 'python'
            \ })

" End of SimpylFold for python }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SyntaxAttr.vim {{{
" https://github.com/vim-scripts/SyntaxAttr.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('SyntaxAttr.vim', {
            \ 'lazy' : 1,
            \ 'on_map' : '<Leader>S',
            \ })

let plugin_name = 'SyntaxAttr.vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    nnoremap <silent> <Leader>S :call SyntaxAttr()<CR>
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of SyntaxAttr.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tagbar {{{
" https://github.com/majutsushi/tagbar
" http://ctags.sourceforge.net/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" XXX: Need 'brew install ctags' on Mac OS.
call dein#add('majutsushi/tagbar', {
            \ 'lazy' : 1,
            \ 'on_map' : '<Leader>b'
            \ })

let plugin_name = 'tagbar'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    nnoremap <silent> <Leader>b :TagbarToggle<CR>
    let g:tagbar_left = 1
    let g:tagbar_width = 30
    let g:tagbar_compact = 1
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of tagbar }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TaskList.vim {{{
" http://juan.boxfi.com/vim-plugins/
" Origin: https://github.com/vim-scripts/TaskList.vim
" Forked: https://github.com/liangfeng/TaskList.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('liangfeng/TaskList.vim', {
            \ 'lazy' : 1,
            \ 'on_map' : '<Leader>t',
            \ })

let plugin_name = 'TaskList.vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    let g:tlRememberPosition = 1
    nmap <silent> <Leader>t <Plug>ToggleTaskList
endfunction
call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of TaskList.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - undotree {{{
" https://github.com/mbbill/undotree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('mbbill/undotree')

" End of undotree }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - unite.vim {{{
" https://github.com/Shougo/unite.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" XXX: In Windows, use cmds from 'git for Windows'.
"      Need prepend installed 'bin' directory to PATH env var in Windows.
call dein#add('Shougo/unite.vim', {
            \ 'lazy' : 1,
            \ 'on_map' : '<Leader>',
            \ 'on_cmd' : ['Unite', 'Grep'],
            \ 'on_source' : 'vimfiler.vim',
            \ })

let plugin_name = 'unite.vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name
function! s:hook_source_{normalized_plugin_name}() abort
    call s:unite_variables()

    " Prompt choices.
    call unite#custom#profile('default', 'context', { 'prompt': '» ', })

    " Use the rank sorter for everything.
    call unite#filters#sorter_default#use(['sorter_rank'])

    " Enable 'smartcase' for the following profiles.
    call unite#custom#profile('files, source/mapping, source/history/yank', 'context.smartcase', 1)

    call s:unite_mappings()
endfunction

function! s:unite_variables()
    let g:unite_source_history_yank_enable = 1
    let g:unite_source_rec_max_cache_files = 0
    let g:unite_source_file_async_command = 'find'

    let g:unite_source_grep_encoding = 'utf-8'
    let g:unite_source_grep_max_candidates = 200
    " Use ag in unite grep source.
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts =
        \ '-i --line-numbers --nocolor --nogroup --hidden --ignore ' .
        \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
    let g:unite_source_grep_recursive_opt = ''
endfunction

function! s:unite_mappings()
    nnoremap [unite] <Nop>
    nmap <Leader> [unite]

    " Frequent shortcuts.
    " Searching buffer in normal mode by default.
    nnoremap <silent> [unite]fb :Unite -toggle -auto-resize
                                \ -buffer-name=buffers -profile-name=files
                                \ buffer<CR>

    " Shortcut for searching MRU file.
    nnoremap <silent> [unite]fr :Unite -start-insert -toggle -auto-resize
                                \ -buffer-name=recent -profile-name=files
                                \ file_mru<CR>

    " Shortcut for searching files in current directory recursively.
    if s:is_nvim
        nnoremap <silent> [unite]f. :Unite -start-insert -toggle -auto-resize
                                    \ -buffer-name=files -profile-name=files
                                    \ file_rec/neovim:!<CR>
    else
        nnoremap <silent> [unite]f. :Unite -start-insert -toggle -auto-resize
                                    \ -buffer-name=files -profile-name=files
                                    \ file_rec/async:!<CR>
    endif

    " Shortcut for searching (buffers, mru files, file in current dir recursively).
    if s:is_nvim
        nnoremap <silent> [unite]ff :Unite -start-insert -toggle -auto-resize
                                          \ -buffer-name=mixed -profile-name=files
                                          \ buffer file_mru file_rec/neovim:!<CR>
    else
        nnoremap <silent> [unite]ff :Unite -start-insert -toggle -auto-resize
                                          \ -buffer-name=mixed -profile-name=files
                                          \ buffer file_mru file_rec/async:!<CR>
    endif

    " Unfrequent shortcuts.
    " Shortcut for yank history searching.
    nnoremap <silent> [unite]fy :Unite -toggle -auto-resize
                                \ -buffer-name=yanks
                                \ history/yank<CR>

    " Shortcut for mappings searching.
    nnoremap <silent> [unite]fm :Unite -toggle -auto-resize
                                \ -buffer-name=mappings
                                \ mapping<CR>

    " Shortcut for messages searching.
    nnoremap <silent> [unite]fs :Unite -toggle -auto-resize
                                \ -buffer-name=messages
                                \ output:message<CR>

    " Shortcut for grep.
    nnoremap <silent> [unite]g :Grep<CR>
endfunction

" Interactive shortcut for searching context in files located in current directory recursively.
function! s:fire_grep_cmd(...)
    let params = a:000

    " options
    let added_options = ''
    " grep pattern
    let grep_pattern = ''
    " target directory
    " TODO: should support list, if the number of target_dirs is large than 1.
    let target_dir = ''

    if len(params) >= 3
        let added_options = params[0]
        let grep_pattern = params[1]
        let target_dir = params[2]
    endif

    if len(params) == 2
        let grep_pattern = params[0]
        let target_dir = params[1]
    endif

    let unite_cmd = 'Unite -toggle -auto-resize -buffer-name=contents grep:' .
                \ target_dir . ":" . added_options . ":" . grep_pattern
    exec unite_cmd
endfunction
command! -nargs=* Grep call s:fire_grep_cmd(<f-args>)

" Setup UI actions.
function! s:unite_ui_settings()
    setlocal number
    nmap <silent> <buffer> <C-j> <Plug>(unite_loop_cursor_down)
    nmap <silent> <buffer> <C-k> <Plug>(unite_loop_cursor_up)
    imap <silent> <buffer> <C-j> <Plug>(unite_select_next_line)
    imap <silent> <buffer> <C-k> <Plug>(unite_select_previous_line)
    imap <silent> <buffer> <Tab> <Plug>(unite_select_next_line)
    imap <silent> <buffer> <S-Tab> <Plug>(unite_select_previous_line)
    imap <silent> <buffer> <expr> <C-x> unite#do_action('split')
    imap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
    nmap <silent> <buffer> <expr> t unite#do_action('tabswitch')
    imap <silent> <buffer> <expr> <C-t> unite#do_action('tabswitch')
    " Do not exit unite buffer when call '<Plug>(unite_delete_backward_char)'.
    inoremap <silent> <expr> <buffer> <Plug>(unite_delete_backward_char)
                                      \ unite#helper#get_input() == '' ?
                                      \ '' : '<C-h>'
endfunction

autocmd FileType unite call s:unite_ui_settings()

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of unite.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-altercmd {{{
" https://github.com/tyru/vim-altercmd
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Only source this plugin in VIM Windows GUI version.
if !s:is_nvim && s:is_windows && s:is_gui_running
    " Use pipe instead of temp file for shell to avoid popup dos window.
    set noshelltemp

    " TODO: use lazy mode
   call dein#add('tyru/vim-altercmd', {
               \ 'lazy' : 1,
               \ 'on_cmd' : 'Shell'
               \ })

    let plugin_name = 'vim-altercmd'
    let normalized_plugin_name = dein#get(plugin_name).normalized_name
    function! s:hook_source_{normalized_plugin_name}() abort
        command! Shell call s:Shell()
        AlterCommand sh[ell] Shell

        " TODO: Need fix issue in :exec 'shell'
        function! s:Shell()
            exec 'set shelltemp | shell | set noshelltemp'
        endfunction
    endfunction
    call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))
endif

" End of vim-altercmd }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-airline {{{
" https://github.com/vim-airline/vim-airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('vim-airline/vim-airline')

if !s:is_gui_running
    let g:airline#extensions#tabline#enabled = 1
    " Must to disable this to keep buffer's layout OK.
    let g:airline#extensions#tabline#show_buffers = 0
    let g:airline#extensions#tabline#tab_nr_type = 1
    let g:airline#extensions#tabline#fnamemod = ':p:t'
endif

let g:airline#extensions#hunks#hunk_symbols = ['+', '*', '-']

" End of vim-airline }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-airline-themes {{{
" https://github.com/vim-airline/vim-airline-themes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('vim-airline/vim-airline-themes')

let g:airline_theme = 'powerlineish'

" End of vim-airline-themes }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-colors-solarized {{{
" https://github.com/altercation/vim-colors-solarized
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('altercation/vim-colors-solarized')
call dein#source('vim-colors-solarized')

let g:solarized_italic = 0
let g:solarized_hitrail = 1
set background=dark
colorscheme solarized

" End of vim-colors-solarized }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-easymotion {{{
" https://github.com/Lokaltog/vim-easymotion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOOD: make it work!
call dein#add('Lokaltog/vim-easymotion', {
            \ 'lazy' : 1,
            \ 'on_map' : '<Leader>n',
            \ })

let plugin_name = 'vim-easymotion'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    nmap <silent> <Leader>n <Plug>(easymotion-prefix)
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of vim-easymotion }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-fugitive {{{
" https://github.com/tpope/vim-fugitive
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('tpope/vim-fugitive', {
            \ 'lazy' : 1,
            \ 'augroup' : 'fugitive'
            \ })

" End of vim-fugitive }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-gitgutter {{{
" https://github.com/airblade/vim-gitgutter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('airblade/vim-gitgutter')

let g:gitgutter_sign_modified = '*'
let g:gitgutter_sign_modified_removed = '*_'
let g:gitgutter_max_signs = 10000

nmap <F7> <Plug>GitGutterPrevHunk
nmap <F8> <Plug>GitGutterNextHunk

" End of vim-gitgutter }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-go {{{
" https://github.com/fatih/vim-go
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('fatih/vim-go', {
            \ 'lazy' : 1,
            \ 'on_ft' : 'go',
            \ })

" End of vim-go }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-gradle {{{
" https://github.com/tfnico/vim-gradle
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('tfnico/vim-gradle', {
            \ 'lazy' : 1,
            \ 'on_ft' : 'gradle',
            \ })

" End of vim-gradle }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-move {{{
" https://github.com/matze/vim-move
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need try this?
" call dein#add('matze/vim-move')

" End of vim-move }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-multiple-cursors {{{
" https://github.com/terryma/vim-multiple-cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('terryma/vim-multiple-cursors', {
            \ 'lazy' : 1,
            \ 'on_map' : ['n', '<C-n>']
            \ })

" End of vim-multiple-cursors }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-polyglot {{{
" https://github.com/sheerun/vim-polyglot
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('sheerun/vim-polyglot')

" End of vim-polyglot }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-repeat {{{
" https://github.com/tpope/vim-repeat
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('tpope/vim-repeat', {
            \ 'lazy': 1,
            \ 'on_map' : [['n', '.'], ['n','u'], ['n', 'U'], ['n', '<C-r>']],
            \ })

" End of vim-repeat }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-surround {{{
" https://github.com/tpope/vim-surround
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('tpope/vim-surround')

let g:surround_no_insert_mappings = 1

" End of vim-surround }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-visualstar {{{
" https://github.com/thinca/vim-visualstar
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need a try?
" NeoBundle 'thinca/vim-visualstar'

" End of vim-visualstar }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimcdoc {{{
" http://vimcdoc.sourceforge.net/
" Origin: https://github.com/vim-scripts/vimcdoc
" Forked: https://github.com/liangfeng/vimcdoc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('liangfeng/vimcdoc')

" End of vimcdoc }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimfiler {{{
" https://github.com/Shougo/vimfiler.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: polish it!
call dein#add('Shougo/vimfiler.vim', {
            \ 'lazy' : 1,
            \ 'depends' : 'unite.vim',
            \ 'on_cmd' : ['VimFiler', 'VimFilerExplorer', 'Edit', 'Read', 'Source', 'Write'],
            \ 'on_map' : ['<Plug>(vimfiler_', '<Leader>l'],
            \ })

let plugin_name = 'vimfiler.vim'
let normalized_plugin_name = dein#get(plugin_name).normalized_name
function! s:hook_source_{normalized_plugin_name}() abort
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_split_rule = 'botright'
    let g:vimfiler_ignore_pattern = '^\%(.svn\|.git\|.DS_Store\)$'

    autocmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') | q | endif
    nnoremap <silent> <Leader>l :VimFilerExplorer<CR>
endfunction

" Setup vimfiler actions
function! s:setup_vimfiler_actions()
    nmap <silent> <buffer> <Leader>l :VimFilerExplorer<CR>
    nmap <silent> <buffer> <nowait> c <Plug>(vimfiler_cd_or_edit)
    nmap <silent> <buffer> u <Plug>(vimfiler_switch_to_parent_directory)
    nmap <silent> <buffer> <expr> t vimfiler#do_action('tabswitch')
    unmap <silent> <buffer> h
    unmap <silent> <buffer> l
    unmap <silent> <buffer> v
    unmap <silent> <buffer> <C-v>
endfunction

autocmd FileType vimfiler call s:setup_vimfiler_actions()

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of vimfiler }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimprj (my plugin) {{{
" https://github.com/liangfeng/vimprj
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Intergate with global(gtags).
" TODO: Add workspace support for projectmgr plugin. Such as, unite.vim plugin support multiple ftags.
" TODO: Rewrite vimprj with prototype-based OO method.
call dein#add('liangfeng/vimprj', {
            \ 'lazy' : 1,
            \ 'on_ft' : ['vimprj'],
            \ 'on_cmd' : ['Preload', 'Pupdate', 'Pstatus', 'Punload'],
            \ })

let plugin_name = 'vimprj'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    " Since this plugin use python script to do some text precessing jobs,
    " add python script path into 'PYTHONPATH' environment variable.
    if s:is_unix
        let $PYTHONPATH .= $HOME . '/.vim/bundle/vimprj/ftplugin/vimprj/:'
    elseif s:is_windows
        let $PYTHONPATH .= $HOME . '/vimfiles/bundle/vimprj/ftplugin/vimprj/;'
    endif

    " XXX: Change it. It's just for my environment.
    if s:is_windows
        let g:cscope_sort_path = 'C:/Program Files (x86)/cscope'
    endif
endfunction

" For the fast editing of vimprj plugin
function! s:OpenVimprj()
    if s:is_unix
        call s:TabSwitch('$HOME/.vim/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')
    elseif s:is_windows
        call s:TabSwitch('$HOME/vimfiles/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')
    endif
endfunction

nnoremap <silent> <Leader>p :call <SID>OpenVimprj()<CR>

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of vimprj }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimproc.vim {{{
" https://github.com/Shougo/vimproc.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('Shougo/vimproc.vim', {
            \ 'lazy' : 1,
            \ 'on_source' : ['unite.vim', 'vimfiler.vim', 'vimshell'],
            \ 'build' : 'make'
            \ })

" End of vimproc.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimshell {{{
" https://github.com/Shougo/vimshell
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('Shougo/vimshell', {
            \ 'lazy' : 1,
            \ 'depends' : 'vimproc.vim',
            \ 'on_cmd' : ['VimShell', 'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop'],
            \ 'on_map' : '<Plug>(vimshell_'
            \ })

" End of vimshell }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xmledit {{{
" https://github.com/sukima/xmledit
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call dein#add('sukima/xmledit', {
            \ 'lazy' : 1,
            \ 'on_ft' : ['xml', 'html']
            \ })

" End of xmledit }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xptemplate {{{
" https://github.com/drmingdrmer/xptemplate
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: setup proper snippets for c, c++, python, java, js
call dein#add('drmingdrmer/xptemplate', {
            \ 'lazy' : 1,
            \ 'on_event' : 'InsertEnter',
            \ })

let plugin_name = 'xptemplate'
let normalized_plugin_name = dein#get(plugin_name).normalized_name

function! s:hook_source_{normalized_plugin_name}() abort
    autocmd BufRead,BufNewFile *.xpt.vim set filetype=xpt.vim
    " trigger key
    let g:xptemplate_key = '<C-l>'
    " navigate key
    let g:xptemplate_nav_next = '<C-j>'
    let g:xptemplate_nav_prev = '<C-k>'
    let g:xptemplate_fallback = ''
    let g:xptemplate_strict = 1
    let g:xptemplate_minimal_prefix = 1

    let g:xptemplate_pum_tab_nav = 1
    let g:xptemplate_move_even_with_pum = 1

    " if use delimitMate Plugin, disable it in xptemplate
    if dein#is_sourced('delimitMate') &&
        \ dein#tap('delimitMate')
        let g:xptemplate_brace_complete = 0
    endif

    " snippet settting
    " Do not add space between brace
    let g:xptemplate_vars = 'SPop=&SParg='
endfunction

call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))

" End of xptemplate }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - YankRing {{{
" https://github.com/vim-scripts/YankRing.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need a try.
call dein#add('YankRing.vim')

" End of YankRing }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - YCM-Generator {{{
" https://github.com/rdnetto/YCM-Generator
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_unix
    call dein#add('rdnetto/YCM-Generator', {
                \ 'lazy' : 1,
                \ 'on_source' : ['YouCompleteMe'],
                \ })
endif

" End of YCM-Generator }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - YouCompleteMe {{{
" https://github.com/Valloric/YouCompleteMe
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_unix
    call dein#add('Valloric/YouCompleteMe', {
                \ 'lazy' : 1,
                \ 'build' : './install.py --clang-completer --system-libclang',
                \ 'on_ft' : ['c', 'cpp', 'python'],
                \ 'augroup': 'youcompletemeStart'
                \ })

    let plugin_name = 'YouCompleteMe'
    let normalized_plugin_name = dein#get(plugin_name).normalized_name

    function! s:hook_source_{normalized_plugin_name}() abort
        let g:ycm_filetype_whitelist = { 'c': 1, 'cpp': 1, 'python' : 1 }
        let g:ycm_confirm_extra_conf = 0
        let g:ycm_complete_in_comments_and_strings = 1
        let g:ycm_global_ycm_extra_conf = '~/' . g:vim_cfg_dir . '/ycm_extra_conf.py'
    endfunction

    call dein#set_hook(plugin_name, 'hook_source', function('s:hook_source_' . normalized_plugin_name))
endif

" End of YouCompleteMe }}}


" Call this finally, since use dein#begin()
call dein#end()

filetype plugin indent on

" vim: set et sw=4 ts=4 fdm=marker ff=unix:
