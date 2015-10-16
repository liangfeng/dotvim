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
    echomsg 'Requires Vim 7.4 or later. The current version of Vim is "' . v:version . '".'
    echohl None
endif

if !has('python')
    echohl WarningMsg
    echomsg 'Requires Vim compiled with "+python" to use enhanced feature.'
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

" Setup neobundle plugin.
" Must be called before filetype on.
if s:is_unix
    set runtimepath=$HOME/.vim/bundle/neobundle.vim,$VIMRUNTIME
    call neobundle#begin()
else
    set runtimepath=$HOME/vimfiles/bundle/neobundle.vim,$VIMRUNTIME
    call neobundle#begin('$HOME/vimfiles/bundle')
endif

" Put Neobundle.vim settings here.

" If unix style 'rmdir' is installed , it can not handle directory properly,
" must setup rm_command explicitly in Windows to use builtin 'rmdir' cmd.
if s:is_windows
    let g:neobundle#rm_command = 'cmd.exe /C rmdir /S /Q'
endif

let g:neobundle#types#git#default_protocol = 'git'

let g:neobundle#install_max_processes = 15

" YouCompleteMe plugin is too large
let g:neobundle#install_process_timeout = 1800


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
    if s:is_unix
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

" Activate 256 colors independently of terminal, except Mac console mode
if !(!s:is_gui_running && s:is_mac)
    set t_Co=256
endif

if s:is_mac && s:is_gui_running
    set fuoptions+=maxhorz
    nnoremap <silent> <D-f> :set invfullscreen<CR>
    inoremap <silent> <D-f> <C-o>:set invfullscreen<CR>
endif

" Switch on syntax highlighting.
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
" gnone-termaterminal can not handle 'visualbell' properly.
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
" Also manage vimrc by Neobundle.

if s:is_unix
    let g:vim_cfg_dir = '.vim'
elseif s:is_windows
    let g:vim_cfg_dir = 'vimfiles'
endif

NeoBundleFetch 'liangfeng/dotvim', {
                 \ 'base' : '~',
                 \ 'directory' : g:vim_cfg_dir
                 \ }

" For the fast editing of vimrc
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
    NeoBundleLazy 'jeaye/color_coded', {
                    \ 'build': {
                        \ 'unix': 'cmake . && make && make install',
                        \ },
                    \ 'autoload' : {
                        \ 'filetypes' : ['c', 'cpp', 'objc', 'objcpp']
                        \ },
                    \ 'build_commands' : ['cmake', 'make']
                    \ }
endif

" End of color_coded }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - context_filetype {{{
" https://github.com/Shougo/context_filetype.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'Shougo/context_filetype.vim', {
                \ 'autoload' : {
                    \ 'on_source': ['neocomplete.vim'],
                    \ },
                \ }

" End of context_filetype }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - delimitMate {{{
" Origin: https://github.com/Raimondi/delimitMate
" Forked: https://github.com/liangfeng/delimitMate
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'liangfeng/delimitMate', {
                \ 'autoload': {
                    \ 'insert' : 1,
                    \ 'on_source' : ['neocomplete.vim', 'xptemplate'],
                    \ },
                \ }

let s:bundle = neobundle#get('delimitMate')
function! s:bundle.hooks.on_source(bundle)
    let g:delimitMate_expand_cr = 1
    let g:delimitMate_balance_matchpairs = 1
    autocmd FileType vim let b:delimitMate_matchpairs = '(:),[:],{:},<:>'
    " To collaborate with xmledit plugin, remove <:> pairs from default pairs for xml and html
    autocmd FileType xml,html let b:delimitMate_matchpairs = '(:),[:],{:}'
    autocmd FileType html let b:delimitMate_quotes = '\" ''
    autocmd FileType python let b:delimitMate_nesting_quotes = ['"']
    autocmd FileType,BufNewFile,BufRead,BufEnter
                \ * imap <buffer> <silent> <C-g> <Plug>delimitMateJumpMany
endfunction

function! s:bundle.hooks.on_post_source(bundle)
    let g:delimitMate_excluded_ft = 'mail,txt,text,,'
    " To work with 'NeoBundleLazy', must call the following cmd.
    silent! exec 'doautocmd Filetype' &filetype
endfunction

" End of delimitMate }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - deoplete.nvim {{{
" https://github.com/Shougo/deoplete.nvim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_nvim
    NeoBundleLazy 'Shougo/deoplete.nvim', {
                    \ 'autoload': {
                        \ 'insert' : 1,
                        \ },
                    \ }

    let s:bundle = neobundle#get('deoplete.nvim')
    function! s:bundle.hooks.on_source(bundle)
        let g:deoplete#enable_at_startup = 1
        let g:deoplete#enable_smart_case = 1

        " <Tab>: completion.
        inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
        inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'

        " Do NOT popup when enter <C-y> and <C-e>
        inoremap <silent> <expr> <C-y>  deoplete#mappings#close_popup() . '<C-y>'
        inoremap <silent> <expr> <C-e>  deoplete#mappings#cancel_popup() . '<C-e>'

        " <C-h>, <BS>: close popup and delete backword char.
        inoremap <silent> <expr> <C-h> deolete#mappings#smart_close_popup() . '<C-h>'
        inoremap <silent> <expr> <BS> deoplete#mappings#smart_close_popup() . '<C-h>'
    endfunction
endif

" End of deoplete.nvim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - DoxygenToolkit.vim {{{
" https://github.com/vim-scripts/DoxygenToolkit.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'DoxygenToolkit.vim', {
                \ 'autoload' : {
                    \ 'filetypes' : ['c', 'cpp', 'python'],
                    \ },
                \ }

let s:bundle = neobundle#get('DoxygenToolkit.vim')
function! s:bundle.hooks.on_source(bundle)
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

" End of DoxygenToolkit.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - emmet-vim {{{
" https://github.com/mattn/emmet-vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'mattn/emmet-vim', {
                \ 'autoload' : {
                    \ 'filetypes' : ['xml', 'html'],
                    \ },
                \ }

let s:bundle = neobundle#get('emmet-vim')
function! s:bundle.hooks.on_source(bundle)
    let g:use_emmet_complete_tag = 1
endfunction

" End of emmet-vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FencView.vim {{{
" https://github.com/mbbill/fencview
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'mbbill/fencview', {
                \ 'autoload' : {
                    \ 'commands' : ['FencAutoDetect', 'FencView', 'FencManualEncoding'] },
                \ }

" End of FencView.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FSwitch {{{
" https://github.com/derekwyatt/vim-fswitch
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need refining to catch exceptions or just rewrite one?
NeoBundleLazy 'derekwyatt/vim-fswitch', {
                \ 'autoload' : {
                    \ 'filetypes' : ['c', 'cpp'],
                    \ 'commands' : ['FS'],
                    \ },
                \ }

let s:bundle = neobundle#get('vim-fswitch')
function! s:bundle.hooks.on_source(bundle)
    command! FS :FSSplitAbove
    let g:fsnonewfiles = 1
endfunction

" End of FSwitch }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - LargeFile {{{
" Origin: http://www.drchip.org/astronaut/vim/#LARGEFILE
" Forked: https://github.com/liangfeng/LargeFile
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'liangfeng/LargeFile'

" End of LargeFile }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - matchit {{{
" https://github.com/vim-scripts/matchit.zip
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'matchit.zip', {
                \ 'autoload' : {
                    \ 'mappings' : ['%', 'g%'],
                    \ },
                \ }

let s:bundle = neobundle#get('matchit.zip')
function! s:bundle.hooks.on_post_source(bundle)
    silent! exec 'doautocmd Filetype' &filetype
endfunction

" End of matchit }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neocomplete.vim {{{
" https://github.com/Shougo/neocomplete.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: add function param complete by TAB (like Vim script #1764)
if !s:is_nvim
    NeoBundleLazy 'Shougo/neocomplete.vim', {
                    \ 'depends' : 'Shougo/context_filetype.vim',
                    \ 'autoload' : {
                        \ 'insert' : 1,
                        \ },
                    \ }

    let s:bundle = neobundle#get('neocomplete.vim')
    function! s:bundle.hooks.on_source(bundle)
        set showfulltag
        " TODO: The following two settings must be checked during vimprj overhaul.
        " Disable header files searching to improve performance.
        set complete-=i
        " Only scan current buffer
        set complete=.

        let g:neocomplete#enable_at_startup = 1
        let g:neocomplete#enable_smart_case = 1
        " Set minimum syntax keyword length.
        let g:neocomplete#sources#syntax#min_keyword_length = 2

        " Define keyword.
        if !exists('g:neocomplete#keyword_patterns')
            let g:neocomplete#keyword_patterns = {}
        endif
        let g:neocomplete#keyword_patterns['default'] = '\h\w*'

        " <Tab>: completion.
        inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
        inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'

        " <C-h>, <BS>: close popup and delete backword char.
        inoremap <silent> <expr> <C-h> neocomplete#smart_close_popup() . '<C-h>'
        inoremap <silent> <expr> <BS> neocomplete#smart_close_popup() . '<C-h>'
        " Do NOT popup when enter <C-y> and <C-e>
        inoremap <silent> <expr> <C-y> neocomplete#close_popup() . '<C-y>'
        inoremap <silent> <expr> <C-e> neocomplete#cancel_popup() . '<C-e>'

        " Enable heavy omni completion.
        if !exists('g:neocomplete#sources#omni#input_patterns')
            let g:neocomplete#sources#omni#input_patterns = {}
        endif
        let g:neocomplete#sources#omni#input_patterns.php =
                    \ '[^. \t]->\h\w*\|\h\w*::'
        let g:neocomplete#sources#omni#input_patterns.c =
                    \ '[^.[:digit:] *\t]\%(\.\|->\)'
        let g:neocomplete#sources#omni#input_patterns.cpp =
                    \ '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

    endfunction
endif

" End of neocomplete.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neobundle.vim {{{
" https://github.com/Shougo/neobundle.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleFetch 'Shougo/neobundle.vim'

" End of neobundle.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neomru.vim {{{
" https://github.com/Shougo/neomru.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'Shougo/neomru.vim', {
                \ 'autoload' : {
                    \ 'on_source' : ['unite.vim'],
                    \ },
                \ }

" End of neomru.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tcomment_vim {{{
" https://github.com/tomtom/tcomment_vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need try 'vim-commentary'?
NeoBundleLazy 'tomtom/tcomment_vim', {
                \ 'autoload' : {
                    \ 'commands' : ['TComment'],
                    \ 'mappings' : ['<Leader>cc'],
                    \ },
                \ }

let s:bundle = neobundle#get('tcomment_vim')
function! s:bundle.hooks.on_source(bundle)
    map <silent> <Leader>cc :TComment<CR>
endfunction

" End of tcomment_vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_match.vim {{{
" https://github.com/vim-scripts/python_match.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'python_match.vim', {
                \ 'autoload' : {
                    \ 'filetypes' : ['python'],
                    \ },
                \ }

" End of python_match.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - session {{{
" https://github.com/xolox/vim-session
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need check this.
" NeoBundle 'xolox/vim-session'

" End of session }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SimpylFold for python {{{
" https://github.com/tmhedberg/SimpylFold
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'tmhedberg/SimpylFold', {
                \ 'autoload' : {
                    \ 'filetypes' : ['python'],
                    \ },
                \ }

" End of SimpylFold for python }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SyntaxAttr.vim {{{
" https://github.com/vim-scripts/SyntaxAttr.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'SyntaxAttr.vim', {
                \ 'autoload' : {
                    \ 'mappings' : '<Leader>S',
                    \ },
                \ }

let s:bundle = neobundle#get('SyntaxAttr.vim')
function! s:bundle.hooks.on_source(bundle)
    nnoremap <silent> <Leader>S :call SyntaxAttr()<CR>
endfunction

" End of SyntaxAttr.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tagbar {{{
" https://github.com/majutsushi/tagbar
" http://ctags.sourceforge.net/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'majutsushi/tagbar', {
                \ 'external_commands' : 'ctags',
                \ 'autoload' : {
                    \ 'mappings' : '<Leader>b',
                    \ },
                \ }

let s:bundle = neobundle#get('tagbar')
function! s:bundle.hooks.on_source(bundle)
    nnoremap <silent> <Leader>b :TagbarToggle<CR>
    let g:tagbar_left = 1
    let g:tagbar_width = 30
    let g:tagbar_compact = 1
endfunction

" End of tagbar }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TaskList.vim {{{
" http://juan.boxfi.com/vim-plugins/
" Origin: https://github.com/vim-scripts/TaskList.vim
" Forked: https://github.com/liangfeng/TaskList.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'liangfeng/TaskList.vim', {
                \ 'autoload' : {
                    \ 'mappings' : '<Leader>t',
                    \ },
                \ }

let s:bundle = neobundle#get('TaskList.vim')
function! s:bundle.hooks.on_source(bundle)
    let g:tlRememberPosition = 1
    nmap <silent> <Leader>t <Plug>ToggleTaskList
endfunction

" End of TaskList.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - undotree {{{
" https://github.com/mbbill/undotree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'mbbill/undotree'

" End of undotree }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - unite.vim {{{
" https://github.com/Shougo/unite.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" XXX: In Windows, use cmds from 'git for Windows'.
"      Need prepend installed 'bin' directory to PATH env var in Windows.
NeoBundleLazy 'Shougo/unite.vim', {
                \ 'external_commands' : ['find', 'grep'],
                \ 'autoload' : {
                    \ 'mappings' : ['<Leader>'],
                    \ 'commands' : ['Unite', 'Grep'],
                    \ 'on_source' : ['vimfiler.vim'],
                    \ },
                \ }

let s:bundle = neobundle#get('unite.vim')
function! s:bundle.hooks.on_source(bundle)
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
    NeoBundle 'tyru/vim-altercmd'

    let s:bundle = neobundle#get('vim-altercmd')
    function! s:bundle.hooks.on_post_source(bundle)
        command! Shell call s:Shell()
        AlterCommand sh[ell] Shell

        " TODO: Need fix issue in :exec 'shell'
        function! s:Shell()
            exec 'set shelltemp | shell | set noshelltemp'
        endfunction
    endfunction
endif

" End of vim-altercmd }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-airline {{{
" https://github.com/bling/vim-airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'bling/vim-airline'

if !s:is_gui_running
    let g:airline#extensions#tabline#enabled = 1
    " Must to disable this to keep buffer's layout OK.
    let g:airline#extensions#tabline#show_buffers = 0
    let g:airline#extensions#tabline#tab_nr_type = 1
    let g:airline#extensions#tabline#fnamemod = ':p:t'
endif

let g:airline_powerline_fonts = 1
let g:airline_theme = 'powerlineish'
let g:airline#extensions#hunks#hunk_symbols = ['+', '*', '-']

" End of vim-airline }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-colors-solarized {{{
" https://github.com/altercation/vim-colors-solarized
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'altercation/vim-colors-solarized', {'force' : 1}

let g:solarized_italic = 0
let g:solarized_hitrail = 1
set background=dark
colorscheme solarized

" End of vim-colors-solarized }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-easymotion {{{
" https://github.com/Lokaltog/vim-easymotion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Lokaltog/vim-easymotion'

nmap <silent> <Leader>n <Plug>(easymotion-prefix)

" End of vim-easymotion }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-fugitive {{{
" https://github.com/tpope/vim-fugitive
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tpope/vim-fugitive', {
            \ 'external_commands' : 'git',
            \ 'augroup' : 'fugitive'
            \ }

" End of vim-fugitive }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-gitgutter {{{
" https://github.com/airblade/vim-gitgutter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'airblade/vim-gitgutter', {'external_commands' : 'git'}

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
NeoBundleLazy 'fatih/vim-go', {
                \ 'external_commands' : 'go',
                \ 'autoload' : {
                    \ 'filetypes' : ['go'],
                    \ },
                \ }

" End of vim-go }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-gradle {{{
" https://github.com/tfnico/vim-gradle
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'tfnico/vim-gradle', {
                \ 'autoload' : {
                    \ 'filetypes' : ['gradle'],
                    \ },
                \ }

" End of vim-gradle }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-move {{{
" https://github.com/matze/vim-move
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need try this?
" NeoBundle 'matze/vim-move'

" End of vim-move }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-multiple-cursors {{{
" https://github.com/terryma/vim-multiple-cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'terryma/vim-multiple-cursors', {
                \ 'autoload' : {
                    \ 'mappings' : ['n', '<C-n>'],
                    \ },
                \ }

" End of vim-multiple-cursors }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-polyglot {{{
" https://github.com/sheerun/vim-polyglot
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'sheerun/vim-polyglot'

" End of vim-polyglot }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-repeat {{{
" https://github.com/tpope/vim-repeat
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'tpope/vim-repeat', {
                \ 'autoload': {
                    \ 'mappings' : [['n', '.'], ['n','u'], ['n', 'U'], ['n', '<C-r>']],
                    \ },
                \ }

" End of vim-repeat }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-surround {{{
" https://github.com/tpope/vim-surround
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tpope/vim-surround'

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
NeoBundle 'liangfeng/vimcdoc'

" End of vimcdoc }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimfiler {{{
" https://github.com/Shougo/vimfiler.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: polish it!
NeoBundleLazy 'Shougo/vimfiler.vim', {
                \ 'depends' : 'Shougo/unite.vim',
                \ 'autoload' : {
                    \ 'commands' : [{ 'name' : 'VimFiler', 'complete' : 'customlist,vimfiler#complete' },
                                    \ 'VimFilerExplorer', 'Edit', 'Read', 'Source', 'Write'],
                    \ 'mappings' : ['<Plug>(vimfiler_', '<Leader>l'],
                    \ 'explorer' : 1,
                  \ }
                \ }

let s:bundle = neobundle#get('vimfiler.vim')
function! s:bundle.hooks.on_source(bundle)
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

" End of vimfiler }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimprj (my plugin) {{{
" https://github.com/liangfeng/vimprj
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Intergate with global(gtags).
" TODO: Add workspace support for projectmgr plugin. Such as, unite.vim plugin support multiple ftags.
" TODO: Rewrite vimprj with prototype-based OO method.
NeoBundleLazy 'liangfeng/vimprj', {
                \ 'external_commands' : ['python', 'cscope'],
                \ 'autoload' : {
                    \ 'filetypes' : ['vimprj'],
                    \ 'commands' : ['Preload', 'Pupdate', 'Pstatus', 'Punload'],
                    \ }
                \ }

let s:bundle = neobundle#get('vimprj')
function! s:bundle.hooks.on_source(bundle)
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

" End of vimprj }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimproc.vim {{{
" https://github.com/Shougo/vimproc.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'Shougo/vimproc.vim', {
                \ 'build' : {
                    \ 'windows' : 'echo "You need compile vimproc manually on Windows."',
                    \ 'mac' : 'make -f make_mac.mak',
                    \ 'unix' : 'make -f make_unix.mak',
                    \ },
                \ 'autoload' : {
                    \ 'on_source' : ['unite.vim', 'vimfiler.vim', 'vimshell'],
                    \ },
                \ }

" End of vimproc.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimshell {{{
" https://github.com/Shougo/vimshell
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'Shougo/vimshell', {
                \ 'depends' : 'Shougo/vimproc.vim',
                \ 'autoload' : {
                    \ 'commands' : [{ 'name' : 'VimShell', 'complete' : 'customlist,vimshell#complete'},
                                    \ 'VimShellExecute', 'VimShellInteractive', 'VimShellTerminal', 'VimShellPop'],
                    \ 'mappings' : ['<Plug>(vimshell_'],
                    \ },
                \ }

" End of vimshell }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xmledit {{{
" https://github.com/sukima/xmledit
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'sukima/xmledit', {
                \ 'autoload' : {
                    \ 'filetypes' : ['xml', 'html'],
                    \ },
                \ }

" End of xmledit }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xptemplate {{{
" https://github.com/drmingdrmer/xptemplate
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: setup proper snippets for c, c++, python, java, js
" FIXME: NeoBundle do not copy subdir in doc to .neobundle/doc
NeoBundleLazy 'drmingdrmer/xptemplate', {
                \ 'autoload' : {
                    \ 'insert' : 1,
                    \ },
                \ }

let s:bundle = neobundle#get('xptemplate')
function! s:bundle.hooks.on_source(bundle)
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
    if neobundle#is_installed('delimitMate') &&
        \ neobundle#is_sourced('delimitMate')
        let g:xptemplate_brace_complete = 0
    endif

    " snippet settting
    " Do not add space between brace
    let g:xptemplate_vars = 'SPop=&SParg='
endfunction

" End of xptemplate }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - YankRing {{{
" https://github.com/vim-scripts/YankRing.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need a try.
" NeoBundle 'YankRing.vim'

" End of YankRing }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - YCM-Generator {{{
" https://github.com/rdnetto/YCM-Generator
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_unix
    NeoBundleLazy 'rdnetto/YCM-Generator', {
                    \ 'autoload' : {
                        \ 'on_source' : ['YouCompleteMe'],
                        \ },
                    \ }
endif

" End of YCM-Generator }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - YouCompleteMe {{{
" https://github.com/Valloric/YouCompleteMe
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_unix
    NeoBundleLazy 'Valloric/YouCompleteMe', {
                    \ 'build' : {
                        \ 'mac'  : './install.py --clang-completer --system-libclang',
                        \ 'unix' : './install.py --clang-completer --system-libclang'
                        \ },
                    \ 'autoload' : {
                        \ 'filetypes' : ['c', 'cpp', 'python'],
                        \ },
                    \ 'augroup': 'youcompletemeStart'
                    \ }

    let g:ycm_filetype_whitelist = { 'c': 1, 'cpp': 1, 'python' : 1 }
    let g:ycm_confirm_extra_conf = 0
    let g:ycm_complete_in_comments_and_strings = 1
    let g:ycm_global_ycm_extra_conf = '~/' . g:vim_cfg_dir . '/ycm_extra_conf.py'
endif

" End of YouCompleteMe }}}


" Call this finally, since use neobundle#begin()
call neobundle#end()

filetype plugin indent on

" vim: set et sw=4 ts=4 fdm=marker ff=unix:
