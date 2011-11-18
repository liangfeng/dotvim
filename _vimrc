" Author:   Liang Feng <liang.feng98 AT gmail DOT com>
" Brief:    This vimrc supports Mac, Linux and Windows(both GUI & console version).
"           While it is well commented, just in case some commands confuse you,
"           please RTFM by ':help WORD' or ':helpgrep WORD'.
" HomePage: http://github.com/liangfeng/vimrc
" Comments: has('mac') means Mac version only.
"           has('unix') means Mac or Linux version.
"           has('win32') means Windows 32 verion only.
"           has('win64') means Windows 64 verion only.
"           has('gui_win32') means Windows 32 bit GUI version.
"           has('gui_win64') means Windows 64 bit GUI version.
"           has('gui_running') means in GUI mode.
" Last Change: 2011-11-19 00:14:50


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if v:version < 700
    echoerr 'This _vimrc requires Vim 7 or later.'
    quit
endif

" Remove ALL autocommands for the current group.
au!

" Use Vim settings, rather then Vi settings.
" This option must be first, because it changes other options.
set nocompatible

let g:maplocalleader = ","
let g:mapleader = ","

" If vim starts without opening file(s),
" change working directory to $VIM (Windows) or $HOME(Mac, Linux).
if expand('%') == ''
    if has('unix')
        cd $HOME
    elseif has('win32') || has('win64')
        cd $VIM
    endif
endif

" Setup vundle plugin.
" Must be called before filetype on.
if has('unix')
    set runtimepath=$VIMRUNTIME,$HOME/.vim/bundle/vundle
    call vundle#rc()
else
    set runtimepath=$VIMRUNTIME,$VIM/bundle/vundle
    call vundle#rc('$VIM/bundle')
endif

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

if has('mac') && has('gui_running')
    set fuoptions+=maxhorz
    nnoremap <silent> <D-f> :set invfullscreen<CR>
    inoremap <silent> <D-f> <C-o>:set invfullscreen<CR>
endif

" End of Init }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Startup/Exit {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shortmess+=I

if has('gui_win32') || has('gui_win64')
    au GUIEnter * simalt ~x
    command! Res simalt ~r
    command! Max simalt ~x
    nnoremap <silent> <Leader>M :Max<CR>
    nnoremap <silent> <Leader>R :Res<CR>
endif

" XXX: Change it. It's just for my environment.
language messages zh_CN.utf-8

" Locate the cursor at the last edited location when open a file
au BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exec "normal! g`\"" |
    \ endif

if has('unix')
    " XXX: Change it. It's just for my environment.
    set viminfo+=n$HOME/tmp/.viminfo
endif

" End of Startup }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:legacy_encoding = &encoding
let &termencoding = &encoding

set encoding=utf-8
set ambiwidth=double
set fileencodings=ucs-bom,utf-8,default,gb18030,big5,latin1
if g:legacy_encoding != 'latin1'
    let &fileencodings=substitute(
                \&fileencodings, '\<default\>', g:legacy_encoding, '')
else
    let &fileencodings=substitute(
                \&fileencodings, ',default,', ',', '')
endif

" This function is revised from Wu yongwei's _vimrc.
" Function to display the current character code in its 'file encoding'
function! s:EchoCharCode()
    let _char_enc = matchstr(getline('.'), '.', col('.') - 1)
    let _char_fenc = iconv(_char_enc, &encoding, &fileencoding)
    let i = 0
    let _len = len(_char_fenc)
    let _hex_code = ''
    while i < _len
        let _hex_code .= printf('%.2x',char2nr(_char_fenc[i]))
        let i += 1
    endwhile
    echo '<' . _char_enc . '> Hex ' . _hex_code . ' (' .
          \(&fileencoding != '' ? &fileencoding : &encoding) . ')'
endfunction

" Key mapping to display the current character in its 'file encoding'
nmap <silent> gn :call <SID>EchoCharCode()<CR>

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

" Activate 256 colors independently of terminal, except Mac console mode
if !(has('mac') && !has('gui_running'))
    set t_Co=256
endif

" Switch on syntax highlighting.
" Delete colors_name for _vimrc re-sourcing.
if exists("g:colors_name")
    unlet g:colors_name
endif
syntax on


" End of UI }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editting {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on

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
map <silent> <2-MiddleMouse> <Nop>
imap <silent> <2-MiddleMouse> <Nop>
map <silent> <3-MiddleMouse> <Nop>
imap <silent> <3-MiddleMouse> <Nop>
map <silent> <4-MiddleMouse> <Nop>
imap <silent> <4-MiddleMouse> <Nop>

" Disable bell on errors
set noerrorbells
set novisualbell
au VimEnter * set vb t_vb=

" remap Y to work properly
nmap Y y$

" Key mapping for confirmed exiting
nnoremap <silent> ZZ :confirm qa<CR>

" Create a new tabpage
nnoremap <silent> <Leader><Tab> :tabnew<CR>

" Redirect command output to standard output and temp file
if has('unix')
    set shellpipe=2>&1\|\ tee
endif

" Quote shell if it contains space and is not quoted
" TODO: check it after re-source _vimrc.
if &shell =~? '^[^"].* .*[^"]'
    let &shell = '"' . &shell . '"'
endif

if has('filterpipe')
    set noshelltemp
endif

" Execute command without disturbing registers and cursor postion.
function! s:Preserve(command)
    " Preparation: save last search, and cursor position.
    let _s=@/
    let _l = line(".")
    let _c = col(".")
    " Do the business.
    execute a:command
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(_l, _c)
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
" On Windows, install 'grep' from:
" http://gnuwin32.sourceforge.net/packages/grep.htm
set grepprg=grep\ -Hn

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

" To make remapping ESC work porperly in console mode by disabling esckeys.
if !has('gui_running')
    set noesckeys
endif
" remap <ESC> to stop searching highlight
nnoremap <silent> <ESC> :nohls<CR><ESC>
imap <silent> <ESC> <C-o><ESC>

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

" move around the quickfix windows
nmap <silent> <C-p> :cp<CR>
nmap <silent> <C-n> :cn<CR>

" Make cursor move smooth
set whichwrap+=<,>,h,l

set ignorecase
set smartcase

set wildmenu

set wildignore+=*.o
set wildignore+=*.obj
set wildignore+=*.bak
set wildignore+=*.exe
set wildignore+=*.swp

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

if has('win32') || has('win64')
    " TODO: should fix vundle plugin to support this option.
    " set shellslash
endif

vmap <Tab> >gv
vmap <S-Tab> <gv

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

set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-6.(%l,%c%V%)\ [%{&ff}]\ %y\ %P
let &statusline = substitute(&statusline,
                            \'%=',
                            \'%=%{winwidth(0)}x%{winheight(0)}   ',
                            \'')
set laststatus=2

set fileformats=unix,dos

" Function to insert the current date
function! s:InsertCurrentDate()
    let _curr_date = strftime('%Y-%m-%d', localtime())
    silent! exec 'normal! gi' .  _curr_date . "\<ESC>a"
endfunction

" Key mapping to insert the current date
imap <silent> <Leader><C-d> <C-o>:call <SID>InsertCurrentDate()<CR>

" Eliminate comment leader when joining comment lines
function! s:JoinWithLeader(count, leaderText)
    let l:linecount = a:count
    " default number of lines to join is 2
    if l:linecount < 2
        let l:linecount = 2
    endif
    echo l:linecount . " lines joined"
    " clear errmsg so we can determine if the search fails
    let v:errmsg = ''

    " save off the search register to restore it later because we will clobber
    " it with a substitute command
    let l:savsearch = @/

    while l:linecount > 1
        " do a J for each line (no mappings)
        normal! J
        " remove the comment leader from the current cursor position
        silent! execute 'substitute/\%#\s*\%('.a:leaderText.'\)\s*/ /'
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
        let l:linecount = l:linecount - 1
    endwhile
    " restore the @/ register
    let @/ = l:savsearch
endfunction

function! s:MapJoinWithLeaders(leaderText)
    let l:leaderText = escape(a:leaderText, '/')
    " visual mode is easy - just remove comment leaders from beginning of lines
    " before using J normally
    exec "vnoremap <silent> <buffer> J :<C-u>let savsearch=@/<Bar>'<+1,'>".
                \'s/^\s*\%('.
                \l:leaderText.
                \'\)\s*/<Space>/e<Bar>'.
                \'let @/=savsearch<Bar>unlet savsearch<CR>'.
                \'gvJ'
    " normal mode is harder because of the optional count - must use a function
    exec "nnoremap <silent> <buffer> J :<C-u>call <SID>JoinWithLeader(v:count, '".l:leaderText."')<CR>"
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
    " include system tags, :help ft-c-omni
    if has('unix')
        set tags+=$HOME/.vim/systags
    elseif has('win32') || has('win64')
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
    let g:c_no_curly_error = 1
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
    let _lines = getline(a:s, a:e)
    let _file = tempname()
    call writefile(_lines, _file)
    redir @e
    silent exec ':source ' . _file
    call delete(_file)
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

nmap <silent> <Leader>v :call <SID>OpenVimrc()<CR>

" Automatically update change time in vimrc
" TODO: Do not change undo tree.
function! s:UpdateLastChangeTime()
    let _last_change_anchor = '\(" Last Change:\s\+\)\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2}:\d\{2}'
    let _last_change_line = search('\%^\_.\{-}\(^\zs' . _last_change_anchor . '\)',
                               \'n')
    if _last_change_line != 0
        let last_change_time = strftime('%Y-%m-%d %H:%M:%S', localtime())
        let last_change_text = substitute(getline(_last_change_line),
                                       \'^' . _last_change_anchor,
                                       \'\1',
                                       \'') . last_change_time
        call setline(_last_change_line, last_change_text)
    endif
endfunction

au BufWritePre *vimrc call s:UpdateLastChangeTime()

" End of vimrc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - a {{{
" http://github.com/vim-scripts/a.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'a.vim'
let g:alternateExtensions_h = "c,cpp,cc"
let g:alternateExtensions_H = "C,CPP,CC"
let g:alternateExtensions_cpp = "h,hpp"
let g:alternateExtensions_CPP = "H,HPP"
let g:alternateExtensions_c = "h"
let g:alternateExtensions_C = "H"
let g:alternateExtensions_cxx = "h"
let g:alternateSearchPath = 'sfr:.,sfr:../src,sfr:../include'

" End of a }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - colorscheme {{{
" http://github.com/liangfeng/colorscheme
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'liangfeng/colorscheme'
colo miracle

" End of colorscheme }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - bufexplorer {{{
" http://github.com/vim-scripts/bufexplorer.zip
" TODO: find a better one or write one.
" TODO: try this one. http://github.com/LStinson/TagmaBufMgr
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'bufexplorer.zip'
let g:bufExplorerDefaultHelp=0
let g:bufExplorerSortBy='name'
let g:bufExplorerShowDirectories=0
let g:bufExplorerSplitRight=0

" End of bufexplorer }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - delimitMate {{{
" http://github.com/Raimondi/delimitMate
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Raimondi/delimitMate'
au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
au FileType python let b:delimitMate_nesting_quotes = ['"']
au FileType html let b:delimitMate_quotes = "\" '"
let g:delimitMate_expand_cr = 1
let g:delimitMate_balance_matchpairs = 1

" End of delimitMate }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - DoxygenToolkit {{{
" http://github.com/vim-scripts/DoxygenToolkit.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'DoxygenToolkit.vim'
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

" End of DoxygenToolkit }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - eclim {{{
" http://github.com/ervandew/eclim
" http://eclim.org/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:EclimDisabled = 1
let g:EclimTaglistEnabled = 0
if has('mac')
    let g:EclimHome = '/Applications/eclipse/plugins/org.eclim_1.6.0'
    let g:EclimEclipseHome = '/Applications/eclipse'
elseif has('win32') || has('win64')
    let g:EclimHome = 'D:/eclipse/plugins/org.eclim_1.6.0'
    let g:EclimEclipseHome = 'D:/eclipse'
endif

" End of eclim }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - FencView {{{
" http://github.com/vim-scripts/FencView.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'FencView.vim'

" End of FencView }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - filetype-completion {{{
" http://github.com/c9s/filetype-completion.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'c9s/filetype-completion.vim'

" End of filetype-completion }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - genutils {{{
" http://github.com/vim-scripts/genutils
" TODO: remove it?
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'genutils'

" End of genutils }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - LargeFile {{{
" http://github.com/vim-scripts/LargeFile
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'LargeFile'

" End of LargeFile }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - lookupfile {{{
" http://github.com/vim-scripts/lookupfile
" TODO: try Command-T plugin
" TODO: remove it?
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'lookupfile'
let g:LookupFile_DisableDefaultMap = 1
let g:LookupFile_UsingSpecializedTags = 1
let g:LookupFile_MinPatLength = 2
let g:LookupFile_AllowNewFiles = 0
let g:LookupFile_AlwaysAcceptFirst = 1
let g:LookupFile_OpenWithTab = 1
let g:LookupFile_FileExplorerOpenMode = 2
let g:LookupFile_FileExplorerOpenCmd = "NERDTree\nwincmd p"

nmap <silent> <Leader>f :LookupFile<CR>
nmap <silent> <Leader>la :LUArgs<CR>
nmap <silent> <Leader>lb :LUBufs<CR>
nmap <silent> <Leader>lp :LUPath<CR>
nmap <silent> <Leader>lt :LUTags<CR>
nmap <silent> <Leader>lw :LUWalk<CR>

" End of lookupfile }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - matchit {{{
" http://github.com/vim-scripts/matchit.zip
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Since 'matchit' script is included in standard distribution,
" only need to 'source' it.
:source $VIMRUNTIME/macros/matchit.vim

" End of matchit }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - mru {{{
" http://github.com/vim-scripts/mru.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'mru.vim'
let g:MRU_Add_Menu = 0

" XXX: Change it. It's just for my environment.
" TODO: Should use $TMP as exclude pattern
if has('mac')
    let g:MRU_Exclude_Files = '^/private/var/folders/.*'
elseif has('win32') || has('win64')
    let g:MRU_Exclude_Files = '^\(h\|H\):\(/\|\\\)temp\(/\|\\\).*'
else
    let g:MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*'
endif

nnoremap <silent> <Leader>m :MRU<CR>

" End of mru }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - neocomplcache {{{
" http://github.com/Shougo/neocomplcache
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Shougo/neocomplcache'
set showfulltag
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_ignore_case = 0
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 2
let g:neocomplcache_plugin_disable = {'snippets_complete' : 1}
inoremap <expr> <CR> neocomplcache#smart_close_popup()."\<C-R>=delimitMate#ExpandReturn()\<CR>"
inoremap <expr> <C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr> <BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr> <C-y> neocomplcache#close_popup()
inoremap <expr> <C-e> neocomplcache#cancel_popup()

if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.c = '.*\.\|->'
let g:neocomplcache_omni_patterns.cpp = '.*\.\|->\|::'

" End of neocomplcache }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - nerdcommenter {{{
" http://github.com/scrooloose/nerdcommenter
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'scrooloose/nerdcommenter'
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
" http://github.com/scrooloose/nerdtree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'scrooloose/nerdtree'
" Set the window position
let g:NERDTreeWinPos = "right"
" Exit vim, if only the NERDTree window is present. If there is more than one tab
" present, close current tab.
let g:NERDTreeExitOnlyWindow = 1
" Whether to open NERDtree or not in new tab, when user presses 't' or 'T' on
" a file or bookmark.
let g:NERDTreeFollowOpenInNewTab = 0
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeWinSize = 50
let NERDTreeDirArrows = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore=['^\.svn', '\~$']

nmap <silent> <Leader>n :NERDTreeToggle<CR>
" command 'NERDTree' will refresh current directory.
nmap <silent> <Leader>N :NERDTree<CR>

" End of nerdtree }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python folding {{{
" http://habamax.ru/blog/2009/05/python-folding-in-vim/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO: improve the performance of this plugin
let g:python_fold_block = "def"
let g:python_fold_keep_empty_lines = "all"
let g:python_fold_comments = 0
let g:python_fold_docstrings = 0
let g:python_fold_imports = 0

" End of python folding }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_match {{{
" http://github.com/vim-scripts/python_match.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'python_match.vim'

" End of python_match }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - python_syntax {{{
" http://github.com/vim-scripts/python.vim--Vasiliev
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'python.vim--Vasiliev'

" End of python_syntax }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-repeat {{{
" http://github.com/tpope/vim-repeat
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'tpope/vim-repeat'

" End of vim-repeat }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - supertab {{{
" http://github.com/ervandew/supertab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'ervandew/supertab'
" Since use tags, disable included header files searching to improve
" performance.
set complete-=i
" Only scan current buffer
set complete=.

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabCrMapping = 0
let g:SuperTabLeadingSpaceCompletion = 0

" End of supertab }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vim-surround {{{
" http://github.com/tpope/vim-surround
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'tpope/vim-surround'

" End of vim-surround }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - SyntaxAttr {{{
" http://github.com/vim-scripts/SyntaxAttr.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'SyntaxAttr.vim'
nmap <silent> <Leader>S :call SyntaxAttr()<CR>

" End of SyntaxAttr }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - tagbar {{{
" http://github.com/majutsushi/tagbar
" http://ctags.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'majutsushi/tagbar'
nmap <silent> <Leader>t :TagbarToggle<CR>
let g:tagbar_left = 1
let g:tagbar_width = 30
let g:tagbar_compact = 1

" End of tagbar }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - TaskList {{{
" http://github.com/vim-scripts/TaskList.vim
" http://juan.axisym3.net/vim-plugins/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'TaskList.vim'
map <silent> <Leader>T <Plug>TaskList

" End of TaskList }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimcdoc {{{
" http://github.com/vim-scripts/vimcdoc
" http://vimcdoc.sourceforge.net/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'liangfeng/vimcdoc'

" End of vimcdoc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimprj (my plugin) {{{
" http://github.com/liangfeng/vimprj
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'liangfeng/vimprj'

" Since this plugin use python script to do some text precessing jobs,
" add python script path into 'PYTHONPATH' environment variable.
if has('unix')
    let $PYTHONPATH .= $HOME . '/.vim/bundle/vimprj/ftplugin/vimprj/:'
elseif has('win32') || has('win64')
    let $PYTHONPATH .= $VIM . '/bundle/vimprj/ftplugin/vimprj/;'
endif

" XXX: Change it. It's just for my environment.
if has('win32') || has('win64')
    let g:cscope_sort_path = 'd:/cscope'
endif

" Fast editing of my plugin
if has('unix')
    nmap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$HOME/.vim/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
elseif has('win32') || has('win64')
    nmap <silent> <Leader>p :call <SID>OpenFileWithProperBuffer('$VIM/bundle/vimprj/ftplugin/vimprj/projectmgr.vim')<CR>
endif

" End of vimprj }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimproc {{{
" http://github.com/Shougo/vimproc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Shougo/vimproc'

" End of vimproc }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vimshell {{{
" http://github.com/Shougo/vimshell
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'Shougo/vimshell'

" End of vimshell }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - vundle {{{
" http://github.com/gmarik/vundle
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'gmarik/vundle'

" End of vundle }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xml {{{
" http://github.com/othree/xml.vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" XXX: Since the original repo dos not suit vundle, use vim-scripts instead.
" TODO: Should check whether vundle support post-install hook. If support ,uss
"       original repo, create html.vim as symbol link to xml.vim.
Bundle 'xml.vim'

" End of xml }}}


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin - xptemplate {{{
" http://github.com/drmingdrmer/xptemplate
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'drmingdrmer/xptemplate'

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
