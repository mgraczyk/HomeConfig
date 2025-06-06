function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction

call SourceIfExists("/usr/facebook/ops/rc/master.vimrc")
call SourceIfExists("/usr/share/vim/google/google.vim")

let g:ale_completion_enabled = 1

let mapleader = ","

" Load modules.
set nocompatible
packloadall

"----------------------------
" Recommended vim settings

" Allow switching between unsaved buffers
set hidden

" Fix slow highlighting
set re=0

" Better completion
set wildmenu
set wildmode=list:longest

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches
set hlsearch

"----------------------------
" Encouraged/Usability settings


set ruler
set confirm

set backspace=indent,eol,start


" Fast scrolling
set ttyfast
set lazyredraw

" undo between instances
"
" Let's save undo info!
if !isdirectory($HOME."/.vim")
  call mkdir($HOME."/.vim", "", 0770)
endif
if !isdirectory($HOME."/.vim/undo")
  call mkdir($HOME."/.vim/undo", "", 0700)
endif
set undodir=~/.vim/undo/
set undofile

if !isdirectory($HOME."/.vim/backup")
  call mkdir($HOME."/.vim/backup", "", 0700)
endif
set backupdir=~/.vim/backup/

filetype plugin on
filetype plugin indent on

" Indentation settings
set expandtab " Make sure that every file uses real tabs, not spaces
set shiftround  " Round indent to multiple of 'shiftwidth'

" Set the tab width
let s:tabwidth=2
exec 'set tabstop='    .s:tabwidth
exec 'set shiftwidth=' .s:tabwidth
exec 'set softtabstop='.s:tabwidth

syntax on
syntax enable
syntax sync minlines=200
set ffs=unix
set ff=unix
set splitbelow
set splitright
set textwidth=80


" Searching/Moving
set mouse=nv

" Resizing in tmux
if exists('$TMUX') && !has("nvim")
  if has("mouse_sgr")
    set ttymouse=sgr
  else
    set ttymouse=xterm2
  end
endif

set gdefault
set incsearch
set showmatch
set hlsearch

set nomodeline
set ignorecase
set smartcase

if has('unix')
  if has('mac')
    " Nothing
  else
    set clipboard=unnamedplus
  endif
endif

" Training
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>

" Who uses F1?
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Settings from vim-sensible
set complete-=i
set smarttab
set nrformats-=octal
set ttimeout
set ttimeoutlen=100
set laststatus=2
if !empty(&viminfo)
  set viminfo^=!
endif
set sessionoptions-=options

" Colors

if has('gui_running')
   set guioptions-=T " no toolbar
   set guifont=Consolas
endif

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=256
else
  set termguicolors
endif

set background=dark
let g:solarized_italic = 1
colorscheme solarized

" Comments should be in italics
highlight Comment gui=italic 

set completeopt-=preview

" Relative numbers, with current line number at cursor
set relativenumber
set number
highlight clear CursorLineNR
highlight CursorLineNR term=bold cterm=bold ctermfg=012 gui=bold

" Show error signs in the number row to avoid resizing on error.
" Also could use 'yes' to always show the column.
set signcolumn=number

" Run plugins faster than the default of 4000ms after typing stops.
set updatetime=1000

let g:tex_indent_items=0
let g:tex_flavor='latex'

"" Various Personal Remappings

" I'll launch with "vim -E" if I want Ex mode
nnoremap Q <nop>

" Space inserts a space
nmap <Space> i <Esc>r
"Ctrl-c closes buffer but not window
nnoremap <C-c> :bp\|bd # <CR>

"Ctrl-x closes window
nnoremap <C-x> :q <CR>


"Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

inoremap <C-U> <C-G>u<C-U>

" Leader t and Leader T for time strings
" T is UNIX time
nnoremap <Leader>t "=strftime("%FT%T%z")<CR>P
"inoremap <Leader>t <C-R>=strftime("%FT%T%z")<CR>
nnoremap <Leader>T "=strftime("%s")<CR>P
"inoremap <Leader>T <C-R>=strftime("%s")<CR>

" Slight modification to TOhtml so that the solarized colorscheme
" is used in the generated html CSS
let g:cterm_color = {
    \   0: "#073642", 1: "#dc322f", 2: "#859900", 3: "#b58900",
    \   4: "#268bd2", 5: "#d33682", 6: "#2aa198", 7: "#eee8d5",
    \   8: "#002b36", 9: "#cb4b16", 10: "#586e75", 11: "#657b83",
    \   12: "#839496", 13: "#6c71c4", 14: "#93a1a1", 15: "#fdf6e3"
    \ }

let g:ale_fixers = {
\  'javascript': ['biome'],
\  'typescript': ['biome'],
\  'typescriptreact': ['biome'],
\  'python': ['ruff', 'ruff_format'],
\  'html': [],
\  'xml': ['xmllint'],
\  'c': ['clang-format'],
\  'cpp': ['clang-format'],
\  'toml': ['dprint'],
\  'json': ['biome'],
\  'jsonl': ['biome'],
\}
let g:ale_linters = {
\   'javascript': ['biome'],
\   'typescript': ['biome', 'tsserver'],
\   'typescriptreact': ['biome', 'tsserver'],
\   'python': ['pyright', 'ruff'],
\   'c': [],
\   'cpp': [],
\}

let g:ale_c_clangformat_use_local_file = 1

" map Leader-h to html-ify a given document, and Leader-H for a range
map <silent><Leader>h :TOhtml<CR>

" Expand and contract json
" TODO(mgraczyk): Fix to remove multiple newlines
map <silent><Leader>j :%!python3 -mjson.tool<CR><CR>
map <silent><Leader>J :%s/[\n \t]\+//<CR>

" n is name
nnoremap <Leader>n aMichael Graczyk<Esc>
nnoremap <Leader>N amgraczyk<Esc>

" Toggle paste and line numbers
nnoremap <Leader>p :set invpaste paste?<CR>:set expandtab<CR>:set paste?<CR>
nnoremap <Leader>l :set invnumber invrelativenumber<CR>

" Toggle hex view
nnoremap <Leader>x :syntax off<CR> :%!xxd<CR>
nnoremap <Leader>X :%!xxd -r<CR> :syntax on<CR>

" Run make with ,m
nnoremap <leader>m :silent make\|redraw!\|cc<CR>

" Run buffer with ,r
nnoremap <leader>r :!%:p<Enter>

" Save
nnoremap <leader>w :w <CR> :bp\|bd # <CR>

" https://stackoverflow.com/a/45897194/1301879
nnoremap <leader>u a<CR><ESC>:.-1read !python3 -c 'from uuid import uuid4; import sys; sys.stdout.write(str(uuid4()))'<CR>I<BS><ESC>j0i<BS><ESC>l
nnoremap <leader>U a<CR><ESC>:.-1read !python3 -c 'import os; from base64 import urlsafe_b64encode; import sys; sys.stdout.write(urlsafe_b64encode(os.urandom(16)).decode().rstrip("="))'<CR>I<BS><ESC>j0i<BS><ESC>l

" Fix indentation.
nnoremap <leader>i :setl noai nocin nosi inde=<CR>

" delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" replace currently selected text with default register
" without yanking it
vnoremap <leader>p "_dP

nnoremap <leader>g :ALEGoToDefinition<CR>
nnoremap <leader>s :ALEFindReferences<CR>

function! s:ToggleCopilot() abort
  " Ask Copilot for its status and capture the reply
  let l:status = execute('Copilot status')

  " If the reply contains “Ready” it’s currently ON → turn it OFF
  if l:status =~# 'Ready'
    silent! Copilot disable
    echo 'GitHub Copilot disabled'
  else
    " Any other state means it’s OFF → turn it ON
    silent! Copilot enable
    echo 'GitHub Copilot enabled'
  endif
endfunction

nnoremap <silent> <leader>c :call <SID>ToggleCopilot()<CR>

let g:typescript_compiler_binary = 'node_modules/typescript/bin/tsc'
let g:prettier#exec_cmd_async = 1

augroup ReactFiletypes
  autocmd!
  autocmd BufRead,BufNewFile *.jsx set filetype=javascriptreact
  autocmd BufRead,BufNewFile *.tsx set filetype=typescriptreact
augroup END

augroup PrettierFileDetect
  autocmd BufNewFile,BufReadPost tsconfig.json setfiletype jsonc
augroup end

" Format code
autocmd FileType go nnoremap <buffer><Leader>f :GoFmt<CR>
autocmd FileType rust nnoremap <buffer><Leader>f :silent! RustFmt<CR>
autocmd FileType rust vnoremap <buffer><Leader>f :silent! RustFmt<CR>
autocmd FileType python setlocal indentkeys-=<:>
autocmd FileType python setlocal indentkeys-=:
autocmd FileType python setlocal formatoptions=crnqj
autocmd FileType terraform nnoremap <Leader>f :%!terraform fmt -<CR>

autocmd FileType python nnoremap <leader>f :ALEImport<Cr> :ALEFix<Cr>
autocmd FileType python nnoremap <leader>F :ALEImport<Cr> :ALEFix<Cr>
autocmd FileType python vnoremap <leader>f :ALEImport<Cr> :ALEFix<Cr>
autocmd FileType python vnoremap <leader>F :ALEImport<Cr> :ALEFix<Cr>

autocmd FileType xml,c,cpp,objc nnoremap <leader>f :ALEFix<Cr>
autocmd FileType xml,c,cpp,objc nnoremap <leader>F :ALEFix<Cr>
autocmd FileType xml,c,cpp,objc vnoremap <leader>f :ALEFix<Cr>
autocmd FileType xml,c,cpp,objc vnoremap <leader>F :ALEFix<Cr>

autocmd FileType css,html,json,jsonc,javascript,typescript,typescriptreact,solidity nnoremap <leader>f :ALEFix<Cr>
autocmd FileType css,html,json,jsonc,javascript,typescript,typescriptreact,solidity nnoremap <leader>F :ALEFix<Cr>
autocmd FileType css,html,json,jsonc,javascript,typescript,typescriptreact,solidity vnoremap <leader>f :ALEFix<Cr>
autocmd FileType css,html,json,jsonc,javascript,typescript,typescriptreact,solidity vnoremap <leader>F :ALEFix<Cr>

" Automatically reload folds
au BufWinLeave ?* mkview
au BufWinEnter ?* silent loadview

au BufRead,BufNewFile,BufEnter * setlocal et sw=2 ts=2 sts=2
au BufRead,BufNewFile,BufEnter *.m setlocal et sw=2 ts=2 sts=2
au BufRead,BufNewFile,BufEnter *.py setlocal et sw=2 ts=2 sts=2 textwidth=100
au BufRead,BufNewFile,BufEnter *.pyx setlocal et sw=2 ts=2 sts=2 textwidth=100
au BufRead,BufNewFile,BufEnter *.pxd setlocal et sw=2 ts=2 sts=2 textwidth=100
au BufRead,BufNewFile,BufEnter *.go setlocal noet sw=4 ts=4 sts=4 textwidth=100
au BufRead,BufNewFile,BufEnter *.sol setlocal et sw=4 ts=4 sts=4 textwidth=100

au BufRead,BufNewFile,BufEnter **/fbsource/**.py setlocal et sw=4 ts=4 sts=4 textwidth=88
au BufRead,BufNewFile,BufEnter **/instagram-server/**.py setlocal et sw=4 ts=4 sts=4 textwidth=88
au BufRead,BufNewFile,BufEnter **/chia-blockchain/**.py setlocal et sw=4 ts=4 sts=4 textwidth=100

au BufRead,BufNewFile,BufEnter **/exomind/**.py setlocal et sw=2 ts=2 sts=2 textwidth=120

call SourceIfExists(glob("~/.vimrc.local"))
