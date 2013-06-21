" Author:   Liang Feng <liang.feng98 AT gmail DOT com>
" Brief:    This vimrc supports Mac, Linux and Windows(both GUI & console version).
"           While it is well commented, just in case some commands confuse you,
"           please RTFM by ':help WORD' or ':helpgrep WORD'.
" HomePage: https://github.com/liangfeng/vimrc
" Comments: has('mac') means Mac version only.
"           has('unix') means Mac or Linux version.
"           has('win32') means Windows 32 verion only.
"           has('win64') means Windows 64 verion only.
"           has('gui_win32') means Windows 32 bit GUI version.
"           has('gui_win64') means Windows 64 bit GUI version.
"           has('gui_running') means in GUI mode.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if v:version < 700
    echoerr 'This _vimrc requires Vim 7 or later.'
    quit
endif

" Remove ALL autocommands for the current group
au!

" Use Vim settings, rather then Vi settings.
" This option must be set first, since it changes other options.
set nocompatible

let g:maplocalleader = ','
let g:mapleader = ','

" If vim starts without opening file(s),
" change working directory to $VIM (Windows) or $HOME(Mac, Linux).
if expand('%') == ''
    if has('unix')
        cd $HOME
    elseif has('win32') || has('win64')
        cd $VIM
    endif
endif

" Setup neobundle plugin.
" Must be called before filetype on.
if has('unix')
    set runtimepath=$VIMRUNTIME,$HOME/.vim/bundle/neobundle.vim
    call neobundle#rc()
else
    set runtimepath=$VIMRUNTIME,$VIM/bundle/neobundle.vim
    call neobundle#rc('$VIM/bundle')
endif
" TODO: Change neobundle.vim to put proto setting with neobundle.vim plugin.
let g:neobundle#types#git#default_protocol = 'https'
let g:neobundle#install_max_processes = 15

" Do not load system menu, before ':syntax on' and ':filetype on'.
if has('gui_running')
    set guioptions+=M
endif

" Patch to hide DOS prompt window, when call vim function system().
" See Wu Yongwei's site for detail
" http://wyw.dcweb.cn/
if has('win32') || has('win64')
    let $VIM_SYSTEM_HIDECONSOLE = 1
endif

filetype plugin indent on

" End of Init }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Startup/Exit {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shortmess+=I

if has('gui_win32') || has('gui_win64')
    command! Res simalt ~r
    command! Max simalt ~x
    " Run gvim with max mode by default.
    au GUIEnter * Max

    function! s:ToggleWindowSize()
        if exists('g:does_windows_need_max')
            let g:does_windows_need_max = !g:does_windows_need_max
        else
            " Need to restore window, since gvim run into max mode by default.
            let g:does_windows_need_max = 0
        endif
        if g:does_windows_need_max == 1
            Max
        else
            Res
        endif
    endfunction

    nnoremap <silent> <Leader>W :call <SID>ToggleWindowSize()<CR>
endif

" XXX: Change it. It's just for my environment.
language messages zh_CN.utf-8

if has('unix')
    " XXX: Change it. It's just for my environment.
    set viminfo+=n$HOME/tmp/.viminfo
endif

" Locate the cursor at the last edited location when open a file
au BufReadPost *
    \ if line("'\"") <= line("$") |
    \   exec "normal! g`\"" |
    \ endif

" End of Startup }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let legacy_encoding = &encoding
let &termencoding = &encoding

set encoding=utf-8
set ambiwidth=double
scriptencoding utf-8
set fileencodings=ucs-bom,utf-8,default,gb18030,big5,latin1
if legacy_encoding != 'latin1'
    let &fileencodings=substitute(
                \&fileencodings, '\<default\>', legacy_encoding, '')
else
    let &fileencodings=substitute(
                \&fileencodings, ',default,', ',', '')
endif

" This function is revised from Wu yongwei's _vimrc.
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
    if has('mac')
        set guifont=Monaco:h14
    elseif has('win32') || has('win64')
        set guifont=Consolas:h14:cANSI
        set guifontwide=YaHei\ Consolas\ Hybrid:h14
    else
        set guifont=Monospace:h14
    endif
endif

" TODO: Should test it in xshell console for performance.
" Activate 256 colors independently of terminal, except Mac console mode
if !(has('mac') && !has('gui_running'))
    set t_Co=256
endif

if has('mac') && has('gui_running')
    set fuoptions+=maxhorz
    nnoremap <silent> <D-f> :set invfullscreen<CR>
    inoremap <silent> <D-f> <C-o>:set invfullscreen<CR>
endif

" Switch on syntax highlighting.
" Delete colors_name for _vimrc re-sourcing.
if exists('g:colors_name')
    unlet g:colors_name
endif

syntax on

" End of UI }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editting {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('unix')
    if isdirectory("$HOME/tmp")
        set directory=$HOME/tmp
    else
        set directory=/tmp
    endif
elseif has('win32') || has('win64')
    set directory=$TMP
endif

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set autochdir

set nobackup

" keep 400 lines of command line history
set history=400

set completeopt-=preview

" Disable middlemouse paste
noremap <silent> <MiddleMouse> <LeftMouse>
noremap <silent> <2-MiddleMouse> <Nop>
inoremap <silent> <2-MiddleMouse> <Nop>
map <silent> <3-MiddleMouse> <Nop>
inoremap <silent> <3-MiddleMouse> <Nop>
noremap <silent> <4-MiddleMouse> <Nop>
inoremap <silent> <4-MiddleMouse> <Nop>

" Disable bell on errors
set noerrorbells
set novisualbell
au VimEnter * set vb t_vb=

" remap Y to work properly
nnoremap <silent> Y y$

" Key mapping for confirmed exiting
nnoremap <silent> ZZ :confirm qa<CR>

" Create a new tabpage
nnoremap <silent> <Leader><Tab> :tabnew<CR>

" Quote shell if it contains space and is not quoted
if &shell =~? '^[^"].* .*[^"]'
    let &shell = '"' . &shell . '"'
endif

" Clear up xquote
set shellxquote=

" Redirect command output to standard output and temp file
if has('unix')
    set shellpipe=2>&1\|\ tee
endif

if has('filterpipe')
    set noshelltemp
endif

if has('win32') || has('win64')
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
    call s:Preserve('%s/\s\+$//e')
endfunction

" Remove trailing spaces for all files
au BufWritePre * call s:RemoveTrailingSpaces()

" End of Editting }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching/Matching {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" incremental searching
set incsearch

" highlight the last used search pattern.
set hlsearch

" Use external grep command for performance
" On Windows, cmds from gnuwin32 doesn't work, must install from:
" http://sourceforge.net/projects/unxutils/
set grepprg=grep\ -Hn
nnoremap <silent> <C-n> :cnext<CR>
nnoremap <silent> <C-p> :cprevious<CR>

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

" To make remapping Esc work porperly in console mode by disabling esckeys.
if !has('gui_running')
    set noesckeys
endif
" remap <Esc> to stop searching highlight
nnoremap <silent> <Esc> :nohls<CR><Esc>
imap <silent> <Esc> <C-o><Esc>

nnoremap <silent> <Up> <Nop>
nnoremap <silent> <Down> <Nop>
nnoremap <silent> <Left> <Nop>
nnoremap <silent> <Right> <Nop>
inoremap <silent> <Up> <Nop>
inoremap <silent> <Down> <Nop>
inoremap <silent> <Left> <Nop>
inoremap <silent> <Right> <Nop>

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

nnoremap / /\v
vnoremap / /\v

" Support */# in visual mode
function! s:VSetSearch()
    let temp = @@
    normal! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction

vnoremap <silent> * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap <silent> # :<C-u>call <SID>VSetSearch()<CR>??<CR>

" End of Searching/Matching }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formats/Style {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set smartindent
set display=lastline
set clipboard=unnamed

vnoremap <silent> <Tab> >gv
vnoremap <silent> <S-Tab> <gv

set scrolloff=7

if has('gui_running')
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
    exec "nnoremap <silent> <buffer> J :<C-u>call <SID>JoinWithLeader(v:count, '".leaderText."')<CR>"
endfunction

" End of Formats/Style }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab/Buffer {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
    " Only show short name in gui tab
    set guitablabel=%N\ %t%m%r
endif

" End of Tab/Buffer }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bash {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" :help ft-bash-syntax
let g:is_bash = 1

" End of Bash }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C/C++ {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:GNUIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
endfunction

function! s:SetSysTags()
    " XXX: change it. It's just for my environment.
    " include system tags, :help ft-c-omni
    if has('unix')
        set tags+=$HOME/.vim/systags
    elseif has('win32') || has('win64')
        " XXX: change it. It's just for my environment.
        set tags+=$TMP/systags
    endif
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
if has('unix')
    au BufEnter /usr/include/* call s:GNUIndent()
elseif has('win32') || has('win64')
    " XXX: change it. It's just for my environment.
    au BufEnter e:/project/g++/* call s:GNUIndent()
    set makeprg=nmake
endif

au FileType c,cpp setlocal commentstring=\ //%s
au FileType c,cpp call s:SetupCppEnv()
au FileType c,cpp call s:MapJoinWithLeaders('//\\|\\')

" End of C/C++ }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Help {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType help nnoremap <buffer> <silent> q :q<CR>
au FileType help setlocal number


" End of help }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" HTML {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Let TOhtml output <PRE> and style sheet
let g:html_use_css = 1
let g:use_xhtml = 1
au FileType html,xhtml setlocal indentexpr=

" End of HTML }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lua {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run the current buffer as lua code
function! s:RunAsLuaCode(s, e)
    pclose!
    silent exec a:s . ',' . a:e . 'y a'
    belowright new
    silent put a
    silent %!lua -
    setlocal previewwindow
    setlocal noswapfile buftype=nofile bufhidden=wipe
    setlocal nobuflisted nowrap cursorline nonumber fdc=0
    setlocal ro nomodifiable
    wincmd p
endfunction

function! s:SetupAutoCmdForRunAsLuaCode()
    nnoremap <buffer> <silent> <Leader>e :call <SID>RunAsLuaCode('1', '$')<CR>
    command! -range Eval :call s:RunAsLuaCode(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :Eval<CR>
endfunction

au FileType lua call s:SetupAutoCmdForRunAsLuaCode()
au FileType lua call s:MapJoinWithLeaders('--\\|\\')

" End of Lua }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Make {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType make setlocal noexpandtab
au FileType make call s:MapJoinWithLeaders('#\\|\\')

" End of make }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Python {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_highlight_all = 1

" Run the current buffer as python code
function! s:RunAsPythonCode(s, e)
    pclose!
    silent exec a:s . ',' . a:e . 'y a'
    belowright new
    silent put a
    silent %!python -
    setlocal previewwindow
    setlocal noswapfile buftype=nofile bufhidden=wipe
    setlocal nobuflisted nowrap cursorline nonumber fdc=0
    setlocal ro nomodifiable
    wincmd p
endfunction

function! s:SetupAutoCmdForRunAsPythonCode()
    nnoremap <buffer> <silent> <Leader>e :call <SID>RunAsPythonCode('1', '$')<CR>
    command! -range Eval :call s:RunAsPythonCode(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :Eval<CR>
endfunction

au FileType python setlocal commentstring=\ #%s
au FileType python call s:SetupAutoCmdForRunAsPythonCode()
au FileType python call s:MapJoinWithLeaders('#\\|\\')

" End of Python }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  VimL {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Run the current buffer as VimL
function! s:RunAsVimL(s, e)
    pclose!
    let lines = getline(a:s, a:e)
    let file = tempname()
    call writefile(lines, file)
    redir @e
    silent exec ':source ' . file_name
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
    nnoremap <buffer> <silent> <Leader>e :call <SID>RunAsVimL('1', '$')<CR>
    command! -range Eval :call s:RunAsVimL(<line1>, <line2>)
    vnoremap <buffer> <silent> <Leader>e :Eval<CR>
endfunction

au FileType vim setlocal commentstring=\ \"%s
au FileType vim call s:SetupAutoCmdForRunAsVimL()
au FileType vim call s:MapJoinWithLeaders('"\\|\\')

let g:vimsyn_noerror = 1

" End of VimL }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  vimrc {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If current buffer is noname and empty, use current buffer.
" Otherwise use new tab
function! s:OpenFileWithProperBuffer(file)
    if bufname('%') == '' && &modified == 0 && &modifiable == 1
        exec 'edit ' . a:file
    else
        exec 'tabedit' . a:file
    endif
endfunction

" Fast editing of vimrc
function! s:OpenVimrc()
    if has('unix')
        call s:OpenFileWithProperBuffer('$HOME/.vimrc')
    elseif has('win32') || has('win64')
        call s:OpenFileWithProperBuffer('$VIM/_vimrc')
    endif
endfunction

nnoremap <silent> <Leader>v :call <SID>OpenVimrc()<CR>

" End of vimrc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - c-syntax {{{
" https://github.com/liangfeng/c-syntax
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'liangfeng/c-syntax', {
    \ 'autoload' : {
    \     'filetypes' : ['c', 'cpp'],
    \    },
    \ }

" End of c-syntax }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - ctrlp.vim {{{
" https://github.com/kien/ctrlp.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" On Windows, cmds from gnuwin32 doesn't work, must install from:
" http://sourceforge.net/projects/unxutils/
" XXX: Need prepend installed directory to PATH env var on Windows.
NeoBundle 'kien/ctrlp.vim', { 'external_commands' : ['find', 'head'] }

nnoremap <silent> <Leader>f :CtrlP<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <silent> <Leader>m :CtrlPMRU<CR>
nnoremap <silent> <Leader>a :CtrlP<CR>

" Clear up default key of g:ctrlpp_map.
let g:ctrlp_map = ''

let g:ctrlp_switch_buffer = 'ETVH'

let g:ctrlp_show_hidden = 1

let g:ctrlp_custom_ignore = {
    \ 'dir':  '\.git$\|\.hg$\|\.svn$',
    \ 'file': '\.exe$\|\.so$\|\.dll$\|\.o$\|\.obj$',
    \ }

" Set the max files.
let g:ctrlp_max_files = 10000

" Optimize file searching
let ctrlp_find_cmd = 'find %s -type f | head -' . g:ctrlp_max_files

" TODO: Should support show hidden files and dirs.
let g:ctrlp_user_command = {
    \ 'types': {
    \ 1: ['.git/', 'cd %s && git ls-files'],
    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
    \ 'fallback': ctrlp_find_cmd,
    \ 'ignore': 0
    \ }

let g:ctrlp_open_new_file = 't'
let g:ctrlp_open_multiple_files = 'tj'

" End of ctrlp.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - delimitMate {{{
" https://github.com/Raimondi/delimitMate
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Raimondi/delimitMate'

au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
au FileType html let b:delimitMate_quotes = "\" '"
au FileType python let b:delimitMate_nesting_quotes = ['"']
let g:delimitMate_expand_cr = 1
let g:delimitMate_balance_matchpairs = 1
let delimitMate_excluded_ft = "mail,txt"

" End of delimitMate }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - DoxygenToolkit.vim {{{
" https://github.com/vim-scripts/DoxygenToolkit.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'DoxygenToolkit.vim'

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

" End of DoxygenToolkit.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FencView.vim {{{
" https://github.com/mbbill/fencview
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'mbbill/fencview', { 'external_commands' : ['tellenc'] }

" End of FencView.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - filetype-completion.vim {{{
" https://github.com/c9s/filetype-completion.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'c9s/filetype-completion.vim'

" End of filetype-completion.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FSwitch {{{
" https://github.com/vim-scripts/FSwitch
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need refining
NeoBundle 'FSwitch'

command! FA :FSSplitAbove

let g:fsnonewfiles = 1

" End of FSwitch }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - Grep {{{
" https://github.com/vim-scripts/grep.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Add 'q' and toggle support.
NeoBundle 'grep.vim', { 'external_commands' : ['grep'] }

" End of Grep }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - LargeFile {{{
" https://github.com/vim-scripts/LargeFile
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'LargeFile'

" End of LargeFile }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - matchit {{{
" https://github.com/vim-scripts/matchit.zip
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Since 'matchit' script is included in standard distribution,
" only need to 'source' it.
:source $VIMRUNTIME/macros/matchit.vim

" End of matchit }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neocomplcache {{{
" https://github.com/Shougo/neocomplcache
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Shougo/neocomplcache'

set showfulltag
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_ignore_case = 0
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 2
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1

if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'


if !exists('g:neocomplcache_context_filetype_lists')
    let g:neocomplcache_context_filetype_lists = {}
endif
let g:neocomplcache_context_filetype_lists.vim =
    \ [{'filetype' : 'python', 'start' : '^\s*python <<\s*\(\h\w*\)', 'end' : '^\1'}]

" <CR>: close popup and save indent.
inoremap <silent> <expr> <CR> neocomplcache#close_popup() . '<C-r>=delimitMate#ExpandReturn()<CR>'

" Set up proper mappings for  <BS> or <C-x>.
inoremap <silent> <expr> <BS> pumvisible() ? '<BS><C-x>' : '<BS>'
inoremap <silent> <expr> <C-h> pumvisible() ? '<C-h><C-x>' : '<C-h>'

" Do NOT popup when enter <C-y> and <C-e>
inoremap <silent> <expr> <C-y> neocomplcache#close_popup() . '<C-y>'
inoremap <silent> <expr> <C-e> neocomplcache#close_popup() . '<C-e>'

" <Tab>: completion.
inoremap <silent> <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<Tab>'

" End of neocomplcache }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neobundle {{{
" https://github.com/Shougo/neobundle.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: check whether to support building docs tags in individual plugin.
NeoBundleFetch 'Shougo/neobundle.vim'

" End of neobundle }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - nerdcommenter {{{
" https://github.com/scrooloose/nerdcommenter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'scrooloose/nerdcommenter'

let g:NERDCreateDefaultMappings = 0
let g:NERDMenuMode = 0
let g:NERDSpaceDelims = 1
nmap <silent> <Leader>cc <plug>NERDCommenterAlignLeft
vmap <silent> <Leader>cc <plug>NERDCommenterAlignLeft
nmap <silent> <Leader>cu <plug>NERDCommenterUncomment
vmap <silent> <Leader>cu <plug>NERDCommenterUncomment

let g:NERDCustomDelimiters = {
    \ 'vim': { 'left': '"' }
    \ }

" End of nerdcommenter }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - nerdtree {{{
" https://github.com/scrooloose/nerdtree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'scrooloose/nerdtree'

" Set the window position
let g:NERDTreeWinPos = "right"
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeWinSize = 50
let g:NERDTreeDirArrows = 1
let g:NERDTreeMinimalUI = 1
let NERDTreeShowHidden=1
let g:NERDTreeIgnore=['^\.git', '^\.hg', '^\.svn', '\~$']

nnoremap <silent> <Leader>n :NERDTreeToggle<CR>
" command 'NERDTree' will refresh current directory.
nnoremap <silent> <Leader>N :NERDTree<CR>

" End of nerdtree }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - nerdtree-tabs {{{
" https://github.com/jistr/vim-nerdtree-tabs
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'jistr/vim-nerdtree-tabs'

let g:nerdtree_tabs_open_on_gui_startup = 0

" End of nerdtree-tabs }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python-mode {{{
" https://github.com/klen/python-mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Refine settings of python-mode.

NeoBundleLazy 'klen/python-mode', {
    \ 'autoload' : {
    \     'filetypes' : ['python'],
    \    },
    \ }

" End of python-mode }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_match.vim {{{
" https://github.com/vim-scripts/python_match.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'python_match.vim', {
    \ 'autoload' : {
    \     'filetypes' : ['python'],
    \    },
    \ }

" End of python_match.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SimpylFold for python {{{
" https://github.com/tmhedberg/SimpylFold
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'tmhedberg/SimpylFold', {
    \ 'autoload' : {
    \     'filetypes' : ['python'],
    \    },
    \ }

" End of SimpylFold for python }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - supertab {{{
" https://github.com/ervandew/supertab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: add function param complete by TAB (like Vim script #1764)
NeoBundle 'ervandew/supertab'

" Since use tags, disable included header files searching to improve
" performance.
set complete-=i
" Only scan current buffer
set complete=.

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabCrMapping = 0

" End of supertab }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SyntaxAttr.vim {{{
" https://github.com/vim-scripts/SyntaxAttr.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'SyntaxAttr.vim'

nnoremap <silent> <Leader>S :call SyntaxAttr()<CR>

" End of SyntaxAttr.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tagbar {{{
" https://github.com/majutsushi/tagbar
" http://ctags.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'majutsushi/tagbar', { 'external_commands' : ['ctags'] }

nnoremap <silent> <Leader>t :TagbarToggle<CR>
let g:tagbar_left = 1
let g:tagbar_width = 30
let g:tagbar_compact = 1

" End of tagbar }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TaskList.vim {{{
" https://github.com/vim-scripts/TaskList.vim
" http://juan.boxfi.com/vim-plugins/
" https://github.com/liangfeng/TaskList.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'liangfeng/TaskList.vim'

let g:tlRememberPosition = 1
nmap <silent> <Leader>T <Plug>ToggleTaskList

" End of TaskList.vim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-colors-solarized {{{
" https://github.com/altercation/vim-colors-solarized
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'altercation/vim-colors-solarized'

if !has('gui_running')
    let g:solarized_termcolors=256
endif
let g:solarized_italic = 0
let g:solarized_hitrail = 1
set background=dark
colorscheme solarized

" End of vim-colors-solarized }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-powerline {{{
" https://github.com/Lokaltog/vim-powerline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Lokaltog/vim-powerline'

" End of vim-powerline }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-repeat {{{
" https://github.com/tpope/vim-repeat
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tpope/vim-repeat'

" End of vim-repeat }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-surround {{{
" https://github.com/tpope/vim-surround
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tpope/vim-surround'

" End of vim-surround }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimcdoc {{{
" https://github.com/vim-scripts/vimcdoc
" http://vimcdoc.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'liangfeng/vimcdoc'

" End of vimcdoc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimprj (my plugin) {{{
" https://github.com/liangfeng/vimprj
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Intergate with ctrlp.vim
" TODO: add workspace support for projectmgr plugin. Such as, ctrlp.vim plugin support multiple ftags.
NeoBundle 'liangfeng/vimprj', { 'external_commands' : ['python', 'cscope'] }

" Since this plugin use python script to do some text precessing jobs,
" add python script path into 'PYTHONPATH' environment variable.
if has('unix')
    let $PYTHONPATH .= $HOME . '/.vim/bundle/vimprj/ftplugin/vimprj/:'
elseif has('win32') || has('win64')
    let $PYTHONPATH .= $VIM . '/bundle/vimprj/ftplugin/vimprj/;'
endif

" XXX: Change it. It's just for my environment.
if has('win32') || has('win64')
    let g:cscope_sort_path = 'C:/Program Files (x86)/cscope'
endif

" Fast editing of my plugin
if has('unix')
    nnoremap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$HOME/.vim/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
elseif has('win32') || has('win64')
    nnoremap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$VIM/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
endif

" End of vimprj }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimproc {{{
" https://github.com/Shougo/vimproc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Shougo/vimproc', {
    \ 'build' : {
    \     'windows' : 'echo "You need compile vimproc manually on Windows."',
    \     'mac' : 'make -f make_mac.mak',
    \     'unix' : 'make -f make_unix.mak',
    \    },
    \ }

" End of vimproc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimshell {{{
" https://github.com/Shougo/vimshell
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Shougo/vimshell'

" End of vimshell }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xmledit {{{
" https://github.com/sukima/xmledit/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Should check whether neobundle support post-install hook. If support,
"       create html.vim as a symbol link to xml.vim.
" TODO: Give Zen Coding a try. https://github.com/mattn/zencoding-vim

NeoBundleLazy 'sukima/xmledit', {
    \ 'autoload' : {
    \     'filetypes' : ['xml', 'html'],
    \    },
    \ }

autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" End of xmledit }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xptemplate {{{
" https://github.com/drmingdrmer/xptemplate
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'drmingdrmer/xptemplate'

au BufRead,BufNewFile *.xpt.vim set filetype=xpt.vim

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
" since use delimitMate Plugin, disable it in xptemplate
let g:xptemplate_brace_complete = 0

" snippet settting
" Do not add space between brace
let g:xptemplate_vars = 'SPop=&SParg='

" End of xptemplate }}}

" vim: set et sw=4 ts=4 fdm=marker ff=unix:
