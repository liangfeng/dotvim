" Author:   Liang Feng <liang.feng98 AT gmail DOT com>
" Brief:    This vimrc supports Mac OS, Linux and Windows(both GUI & console version).
"           While it is well commented, just in case some commands confuse you,
"           please RTFM by ':help WORD' or ':helpgrep WORD'.
" HomePage: https://github.com/liangfeng/dotvim.git
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
    echoerr 'Requires Vim 7.4 or later. The current version of Vim is "' . v:version . '".'
    quit
endif

if !has('python')
    echoerr 'Requires Vim compiled with +python/dyn.'
    quit
endif

if !has('lua')
    echoerr 'Requires Vim compiled with +lua/dyn.'
    quit
endif

" End of Check Prerequisite }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remove ALL autocmds for the current group
autocmd!

" Use Vim settings, rather then Vi settings.
" This option must be set first, since it changes other options.
set nocompatible

" Check OS and env.
let s:is_mac = has('mac')
let s:is_unix = has('unix')
let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_gui_running = has('gui_running')

let g:maplocalleader = ' '
let g:mapleader = ' '

" If vim starts without opening file(s),
" change working directory to $HOME(Mac, Linux, Unix) or $VIM (Windows).
if expand('%') == ''
    if s:is_unix
        cd $HOME
    elseif s:is_windows
        cd $VIM
    endif
endif

" Setup neobundle plugin.
" Must be called before filetype on.
if s:is_unix
    set runtimepath=$VIMRUNTIME,$HOME/.vim/bundle/neobundle.vim
    call neobundle#begin()
else
    set runtimepath=$VIMRUNTIME,$VIM/bundle/neobundle.vim
    call neobundle#begin('$VIM/bundle')
endif

" Do not load system menu, before ':syntax on' and ':filetype on'.
if s:is_gui_running
    set guioptions+=M
endif

" Must call this, since use neobundle#begin()
call neobundle#end()

filetype plugin indent on

" End of Init }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Startup/Exit {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shortmess+=I

if s:is_windows && s:is_gui_running
    command! Res simalt ~r
    command! Max simalt ~x
    " Run gvim with max mode by default.
    autocmd GUIEnter * Max

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

if s:is_unix
    " XXX: Change it. It's just for my environment.
    set viminfo+=n$HOME/tmp/.viminfo
endif

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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_gui_running
    if s:is_mac
        set guifont=Monaco:h14
    elseif s:is_windows
        set guifont=Powerline_Consolas:h14:cANSI
        set guifontwide=YaHei_Consolas_Hybrid:h14
    else
        set guifont=Monospace:h14
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
" Delete colors_name for _vimrc re-sourcing.
if exists('g:colors_name')
    unlet g:colors_name
endif

syntax on

" End of UI }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editting {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:is_unix
    if isdirectory("$HOME/tmp")
        set directory=$HOME/tmp
    else
        set directory=/tmp
    endif
elseif s:is_windows
    set directory=$TMP
endif

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup

" keep 400 lines of command line history
set history=400

set completeopt-=preview

" Disable middlemouse paste
noremap <silent> <MiddleMouse> <Nop>
inoremap <silent> <MiddleMouse> <Nop>
noremap <silent> <2-MiddleMouse> <Nop>
inoremap <silent> <2-MiddleMouse> <Nop>
noremap <silent> <3-MiddleMouse> <Nop>
inoremap <silent> <3-MiddleMouse> <Nop>
noremap <silent> <4-MiddleMouse> <Nop>
inoremap <silent> <4-MiddleMouse> <Nop>

" Disable bell on errors
set noerrorbells
set novisualbell
autocmd VimEnter * set vb t_vb=

" remap Y to work properly
nnoremap <silent> Y y$

" Key mapping for confirmed exiting
nnoremap <silent> ZZ :confirm qa<CR>

" Create a new tabpage
nnoremap <silent> <Leader><Tab> :tabnew<CR>

" Use pipe instead of temp file for shell.
set noshelltemp

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
    call s:Preserve('%s/\s\+$//e')
endfunction

" Remove trailing spaces for all files
autocmd BufWritePre * call s:RemoveTrailingSpaces()

function! s:Tabdrop(...)
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

command! -complete=file -nargs=+ Tabdrop call s:Tabdrop(<q-args>)

" End of Editting }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching/Matching {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" incremental searching
set incsearch

" highlight the last used search pattern.
set hlsearch

" Simulate 'autochdir' option to avoid side-effect of this option.
autocmd BufEnter * exec 'chdir ' . escape(expand("%:p:h"), ' ')

" Use external grep command for performance
" XXX: On Windows, cmds from gnuwin32 doesn't work, must install from:
" http://sourceforge.net/projects/unxutils/
" Need prepend installed directory to PATH env var on Windows.
set grepprg=grep\ -Hni

" TODO: Since vim-multiple-cursors use <C-n> mapping, change the followings.
nnoremap <silent> <C-n> :cnext<CR>
nnoremap <silent> <C-p> :cprevious<CR>

" auto center
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz

" Replace all matched items in the line.
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
if !s:is_gui_running
    set noesckeys
endif

" Assume fast terminal connection.
set ttyfast

" Remap <Esc> to stop highlighting searching result.
nnoremap <silent> <Esc> :nohls<CR><Esc>
imap <silent> <Esc> <C-o><Esc>

" Disalbe arrow keys.
noremap <silent> <Up> <Nop>
noremap <silent> <Down> <Nop>
noremap <silent> <Left> <Nop>
noremap <silent> <Right> <Nop>
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

" Search highlighted text, when press slash in visual mode.
vmap / y/<C-R>"<CR>

" End of Searching/Matching }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formats/Style {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
    if s:is_unix
        set tags+=$HOME/.vim/systags
    elseif s:is_windows
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
if s:is_unix
    autocmd BufEnter /usr/include/* call s:GNUIndent()
elseif s:is_windows
    " XXX: change it. It's just for my environment.
    autocmd BufEnter e:/project/g++/* call s:GNUIndent()
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
autocmd FileType lua call s:SetupAutoCmdForEvalCodes('lua52')
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
"  Language - VimL {{{
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
"  Language - xml {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" End of xml }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  vimrc {{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If current buffer is noname and empty, use current buffer.
" Otherwise use new tab
function! s:OpenFileWithProperBuffer(file)
    call s:Tabdrop(a:file)
endfunction

" Fast editing of vimrc
function! s:OpenVimrc()
    if s:is_unix
        call s:OpenFileWithProperBuffer('$HOME/.vimrc')
    elseif s:is_windows
        call s:OpenFileWithProperBuffer('$VIM/_vimrc')
    endif
endfunction

nnoremap <silent> <Leader>v :call <SID>OpenVimrc()<CR>

" End of vimrc }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - c-syntax {{{
" https://github.com/liangfeng/c-syntax.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'liangfeng/c-syntax', {
                \ 'autoload' : {
                    \ 'filetypes' : ['c', 'cpp'],
                    \ },
                \ }

" End of c-syntax }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - context_filetype {{{
" https://github.com/Shougo/context_filetype.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'Shougo/context_filetype.vim', {
                \ 'autoload' : {
                    \ 'on_source': ['neocomplete.vim'],
                    \ },
                \}

" End of context_filetype }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - delimitMate {{{
" https://github.com/Raimondi/delimitMate.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: fix issue: 'on_source' parm of 'autoload' option does not work with 'xptemplate'
NeoBundleLazy 'Raimondi/delimitMate', {
                \ 'autoload': {
                    \ 'insert' : 1,
                    \ 'on_source' : ['neocomplete.vim'],
                    \ },
                \ }

let s:bundle = neobundle#get('delimitMate')
function! s:bundle.hooks.on_source(bundle)
    let g:delimitMate_excluded_ft = 'mail,txt,text'
    let execluded_ft_list = split(g:delimitMate_excluded_ft, ',')
    for ft in execluded_ft_list
        if ft ==# &filetype
            return
        endif
    endfor
    imap <silent> <C-g> <Plug>delimitMateJumpMany
    let g:delimitMate_expand_cr = 1
    let g:delimitMate_balance_matchpairs = 1
    autocmd FileType vim let b:delimitMate_matchpairs = '(:),[:],{:},<:>'
    " To collaborate with xmledit plugin, remove <:> pairs from default pairs for xml and html
    autocmd FileType xml,html let b:delimitMate_matchpairs = '(:),[:],{:}'
    autocmd FileType html let b:delimitMate_quotes = '\" ''
    autocmd FileType python let b:delimitMate_nesting_quotes = ['"']
endfunction

" End of delimitMate }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - DoxygenToolkit.vim {{{
" https://github.com/vim-scripts/DoxygenToolkit.vim.git
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
" https://github.com/mattn/emmet-vim.git
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
" https://github.com/mbbill/fencview.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'mbbill/fencview', {
                \ 'external_commands' : 'tellenc',
                \ 'autoload' : {
                    \ 'commands' : ['FencAutoDetect', 'FencView', 'FencManualEncoding'] },
                \ }

" End of FencView.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FSwitch {{{
" https://github.com/derekwyatt/vim-fswitch.git
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
" http://www.drchip.org/astronaut/vim/#LARGEFILE
" https://github.com/liangfeng/LargeFile.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'liangfeng/LargeFile'

" End of LargeFile }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - matchit {{{
" https://github.com/vim-scripts/matchit.zip.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need to figure out the method of source macro by lazy loading.
NeoBundleLazy 'matchit.zip', {
                \ 'autoload' : {
                    \ 'mappings' : ['%', 'g%'],
                    \ },
                \}

let bundle = neobundle#get('matchit.zip')
function! bundle.hooks.on_post_source(bundle)
    silent! exec 'doautocmd Filetype' &filetype
endfunction

" End of matchit }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neocomplete.vim {{{
" https://github.com/Shougo/neocomplete.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: add function param complete by TAB (like Vim script #1764)
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

    " if use delimitMate Plugin, remap <CR> with it.
    if neobundle#is_installed('delimitMate') &&
        \ neobundle#is_sourced('delimitMate')
        " <CR>: close popup and save indent.
        inoremap <silent> <expr> <CR> neocomplete#close_popup()
                    \ . '<C-r>=delimitMate#ExpandReturn()<CR>'

    endif

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

" End of neocomplete.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neobundle.vim {{{
" https://github.com/Shougo/neobundle.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleFetch 'Shougo/neobundle.vim', {'external_commands' : 'rm'}

" Since unix style 'rmdir' is installed and can not handle directory properly,
" must setup rm_command explicitly on Windows to use internal 'rmdir' cmd.
if s:is_windows
    let g:neobundle#rm_command = 'cmd.exe /C rmdir /S /Q'
endif

let g:neobundle#install_max_processes = 15

" End of neobundle.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neomru.vim {{{
" https://github.com/Shougo/neomru.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'Shougo/neomru.vim'

" End of neomru.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tcomment_vim {{{
" https://github.com/tomtom/tcomment_vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
" Plugin - nerdtree {{{
" https://github.com/scrooloose/nerdtree.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Replace nerdtree with vimfiler?
NeoBundleLazy 'scrooloose/nerdtree', {
                \ 'autoload' : {
                    \ 'commands' : ['NERDTreeToggle','NERDTree','NERDTreeFind'],
                    \ 'mappings' : ['<Leader>n','<Leader>N'],
                    \ }
                \}

let s:bundle = neobundle#get('nerdtree')
function! s:bundle.hooks.on_source(bundle)
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

endfunction

" End of nerdtree }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_match.vim {{{
" https://github.com/vim-scripts/python_match.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'python_match.vim', {
                \ 'autoload' : {
                    \ 'filetypes' : ['python'],
                    \ },
                \ }

" End of python_match.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - session {{{
" https://github.com/xolox/vim-session.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need check this.
" NeoBundle 'xolox/vim-session'

" End of session }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SimpylFold for python {{{
" https://github.com/tmhedberg/SimpylFold.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'tmhedberg/SimpylFold', {
                \ 'autoload' : {
                    \ 'filetypes' : ['python'],
                    \ },
                \ }

" End of SimpylFold for python }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SyntaxAttr.vim {{{
" https://github.com/vim-scripts/SyntaxAttr.vim.git
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
" https://github.com/majutsushi/tagbar.git
" http://ctags.sourceforge.net/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'majutsushi/tagbar', {
                \ 'external_commands' : 'ctags',
                \ 'autoload' : {
                    \ 'mappings' : '<Leader>a',
                    \ },
                \ }

let s:bundle = neobundle#get('tagbar')
function! s:bundle.hooks.on_source(bundle)
    nnoremap <silent> <Leader>a :TagbarToggle<CR>
    let g:tagbar_left = 1
    let g:tagbar_width = 30
    let g:tagbar_compact = 1
endfunction

" End of tagbar }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TaskList.vim {{{
" https://github.com/vim-scripts/TaskList.vim.git
" http://juan.boxfi.com/vim-plugins/
" https://github.com/liangfeng/TaskList.vim.git
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
" Plugin - unite.vim {{{
" https://github.com/Shougo/unite.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" XXX: On Windows, cmds from gnuwin32 doesn't work, must install from:
" http://sourceforge.net/projects/unxutils/
" Need prepend installed directory to PATH env var on Windows.
NeoBundleLazy 'Shougo/unite.vim', {
                \ 'external_commands' : ['find', 'grep'],
                \ 'autoload' : {
                    \ 'mappings' : ['<Space>'],
                    \ 'commands' : ['Unite', 'Grep'],
                    \ 'on_source' : ['vimfiler.vim'],
                    \ },
                \ }

let s:bundle = neobundle#get('unite.vim')
function! s:bundle.hooks.on_source(bundle)
    call s:unite_variables()

    " Use the rank sorter for everything.
    call unite#filters#sorter_default#use(['sorter_rank'])

    " Enable 'ignorecase' for the following profiles.
    call unite#custom#profile('source/mapping, source/history/yank', 'ignorecase', 1)

    " Enable 'smartcase' for the following profiles.
    call unite#custom#profile('files, source/mapping, source/history/yank', 'smartcase', 1)

    " Use 'my_tabdrop', since 'tabdrop' not supported in terminal mode.
    if !s:is_gui_running
        call unite#custom#action('file, buffer', 'my_tabdrop', s:my_tabdrop)
    endif

    call s:unite_mappings()
endfunction

function! s:unite_variables()
    let g:unite_source_history_yank_enable = 1
    let g:unite_source_rec_max_cache_files = 0
    let g:unite_prompt = '» '
    if s:is_windows
        let g:unite_source_rec_async_command = 'find'
    endif
    " Setup variables for 'grep' source.
    let g:unite_source_grep_encoding = 'utf-8'
    let g:unite_source_grep_max_candidates = 200
endfunction

function! s:unite_mappings()
    nmap <Space> [unite]
    nnoremap [unite] <Nop>

    " Frequent shortcuts.
    " When searching buffer enter normal mode by default.
    nnoremap <silent> [unite]b :Unite -toggle -auto-resize
                                \ -buffer-name=buffers -profile-name=files
                                \ buffer<CR>

    " Shortcut for searching mru file.
    nnoremap <silent> [unite]r :Unite -start-insert -toggle -auto-resize
                                \ -buffer-name=recent -profile-name=files
                                \ file_mru<CR>

    " Shortcut for searching files in current directory recursively.
    nnoremap <silent> [unite]f :Unite -start-insert -toggle -auto-resize
                                \ -buffer-name=files -profile-name=files
                                \ file_rec/async:!<CR>

    " Shortcut for searching (buffers, mru files, file in curr dir).
    nnoremap <silent> [unite]<Space> :Unite -start-insert -toggle -auto-resize
                                      \ -buffer-name=mixed -profile-name=files
                                      \ buffer file_mru file_rec/async:!<CR>

    " Unfrequent shortcuts.
    " Shortcut for mappings searching.
    nnoremap <silent> [unite]y :Unite -toggle -auto-resize
                                \ -buffer-name=yanks
                                \ history/yank<CR>
    nnoremap <silent> [unite]m :Unite -toggle -auto-resize
                                \ -buffer-name=mappings
                                \ mapping<CR>

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

" To fix the issue of 'tabdrop' can not work on console.
if !s:is_gui_running
    let s:my_tabdrop = {
                \ 'description' : 'my tab drop',
                \ 'is_selectable' : 1,
                \ }
    function! s:my_tabdrop.func(candidates)
        let bufpath = unite#util#substitute_path_separator(expand('%:p'))

        for candidate in a:candidates
            if bufpath !=# candidate.action__path
                call unite#util#smart_execute_command('Tabdrop',
                            \ candidate.action__path)

                call unite#remove_previewed_buffer_list(
                            \ bufnr(unite#util#escape_file_searching(
                            \       candidate.action__path)))
            endif
        endfor
    endfunction
endif

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
    if s:is_gui_running
        noremap <silent> <buffer> <expr> t unite#do_action('tabdrop')
        imap <silent> <buffer> <expr> <C-t> unite#do_action('tabdrop')
    else
        noremap <silent> <buffer> <expr> t unite#do_action('my_tabdrop')
        imap <silent> <buffer> <expr> <C-t> unite#do_action('my_tabdrop')
        inoremap <silent> <buffer> <expr> <C-o> '<C-o>'
    endif
    " Do not exit unite buffer when call '<Plug>(unite_delete_backward_char)'.
    inoremap <silent> <expr> <buffer> <Plug>(unite_delete_backward_char)
                                      \ unite#helper#get_input() == '' ?
                                      \ '' : '<C-h>'
endfunction

autocmd FileType unite call s:unite_ui_settings()

" End of unite.vim }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-altercmd {{{
" https://github.com/tyru/vim-altercmd.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tyru/vim-altercmd'

let s:bundle = neobundle#get('vim-altercmd')
function! s:bundle.hooks.on_source(bundle)
    command! Shell call s:Shell()
    AlterCommand sh[ell] Shell
endfunction

" TODO: Need fix issue in :exec 'shell'
if s:is_windows
    function! s:Shell()
        exec 'set shelltemp | shell | set noshelltemp'
    endfunction
endif

" End of vim-altercmd }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-airline {{{
" https://github.com/bling/vim-airline.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'bling/vim-airline'

if !s:is_gui_running
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#tab_nr_type = 1
    let g:airline#extensions#tabline#fnamemod = ':p:t'
endif

let g:airline_powerline_fonts = 1
let g:airline_theme = 'powerlineish'

" End of vim-airline }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-colors-solarized {{{
" https://github.com/altercation/vim-colors-solarized.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'altercation/vim-colors-solarized'

let g:solarized_italic = 0
let g:solarized_hitrail = 1
set background=dark

if neobundle#is_installed('vim-colors-solarized') &&
    \ neobundle#is_sourced('vim-colors-solarized')
    colorscheme solarized
endif

" End of vim-colors-solarized }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-fugitive {{{
" https://github.com/tpope/vim-fugitive.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tpope/vim-fugitive'

autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>

" End of vim-fugitive }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-multiple-cursors {{{
" https://github.com/terryma/vim-multiple-cursors.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need to check whether be lazy loaded or not ?
NeoBundle 'terryma/vim-multiple-cursors'

let bundle = neobundle#get('vim-multiple-cursors')
function! bundle.hooks.on_source(bundle)
endfunction

" End of vim-multiple-cursors }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-repeat {{{
" https://github.com/tpope/vim-repeat.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'tpope/vim-repeat', {
                \ 'autoload': {
                    \ 'mappings' : [['n', '.'], ['n','u'], ['n', 'U'], ['n', '<C-r>']],
                    \ },
                \ }

" End of vim-repeat }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-surround {{{
" https://github.com/tpope/vim-surround.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundle 'tpope/vim-surround'

let g:surround_no_insert_mappings = 1

" End of vim-surround }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimcdoc {{{
" https://github.com/vim-scripts/vimcdoc.git
" http://vimcdoc.sourceforge.net/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: setup 'keywordprg' for linux?
NeoBundle 'liangfeng/vimcdoc'

" End of vimcdoc }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimfiler {{{
" https://github.com/Shougo/vimfiler.vim.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'Shougo/vimfiler.vim', {
                \ 'depends' : 'Shougo/unite.vim',
                \ 'autoload' : {
                    \ 'commands' : [{ 'name' : 'VimFiler', 'complete' : 'customlist,vimfiler#complete' },
                                    \ 'VimFilerExplorer', 'Edit', 'Read', 'Source', 'Write'],
                    \ 'mappings' : ['<Plug>(vimfiler_'],
                    \ 'explorer' : 1,
                  \ }
                \ }

let s:bundle = neobundle#get('vimfiler.vim')
function! s:bundle.hooks.on_source(bundle)
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_split_rule = 'botright'
    let g:vimfiler_ignore_pattern = '^\%(.svn\|.git\|.DS_Store\)$'
endfunction

" End of vimfiler }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimprj (my plugin) {{{
" https://github.com/liangfeng/vimprj.git
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
        let $PYTHONPATH .= $VIM . '/bundle/vimprj/ftplugin/vimprj/;'
    endif

    " XXX: Change it. It's just for my environment.
    if s:is_windows
        let g:cscope_sort_path = 'C:/Program Files (x86)/cscope'
    endif
endfunction

" Fast editing of my plugin
if s:is_unix
    nnoremap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$HOME/.vim/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
elseif s:is_windows
    nnoremap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$VIM/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
endif

" End of vimprj }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimproc.vim {{{
" https://github.com/Shougo/vimproc.vim.git
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
" https://github.com/Shougo/vimshell.git
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
" https://github.com/liangfeng/xmledit.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
NeoBundleLazy 'liangfeng/xmledit', {
                \ 'autoload' : {
                    \ 'filetypes' : ['xml', 'html'],
                    \ },
                \ }

" End of xmledit }}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xptemplate {{{
" https://github.com/drmingdrmer/xptemplate.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: setup proper snippets for c, c++, python, java, js
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
" Plugin - YouCompleteMe {{{
" https://github.com/Valloric/YouCompleteMe.git
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: Need a try.

" End of YouCompleteMe }}}


" vim: set et sw=4 ts=4 fdm=marker ff=unix:
