" The bare necessities
runtime bundle/vim-pathogen/autoload/pathogen.vim

filetype off
execute pathogen#infect()
filetype plugin on
set nocompatible


"----------------------------
" Recommended vim settings

" Allow switching between unsaved buffers
set hidden

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


" Relative numbers, with current line number at cursor
set relativenumber
set number

" undo between instances
set undofile

if has("autocmd")
	filetype plugin indent on
endif

" Indentation settings
set expandtab " Make sure that every file uses real tabs, not spaces
set shiftround  " Round indent to multiple of 'shiftwidth'
set smartindent " Do smart indenting when starting a new line
set autoindent  " Copy indent from current line, over to the new line

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

set ignorecase
set smartcase

" Training
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

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
  set t_Co=16
endif

set background=dark
let g:solarized_italic = 1
colorscheme solarized

" Comments should be in italics
highlight Comment gui=italic 


set completeopt-=preview

let g:tex_indent_items=0
let g:tex_flavor='latex'

"" Various Personal Remappings
let mapleader = ","

" I'll launch with "vim -E" if I want Ex mode
nnoremap Q <nop>

" Space inserts a space
nmap <Space> i_<Esc>r
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

let g:clang_format#style_options = {
            \ "Standard" : "C++11"}
let g:yapf_style = "google"

" map Leader-h to html-ify a given document, and Leader-H for a range
map <silent><Leader>h :TOhtml<CR>

" Expand and contract json
" TODO(mgraczyk): Fix to remove multiple newlines
map <silent><Leader>j :%!python -mjson.tool<CR><CR>
map <silent><Leader>J :%s/[\n \t]\+//<CR>

" n is name
nnoremap <Leader>n iMichael Graczyk<Esc>
nnoremap <Leader>N imgraczyk<Esc>

" Toggle paste and line numbers
nnoremap <Leader>p :set invpaste paste?<CR>
nnoremap <Leader>l :set invnumber number?<CR> :set invrelativenumber relativenumber?<CR>

" Toggle hex view
nnoremap <Leader>x :syntax off<CR> :%!xxd<CR>
nnoremap <Leader>X :%!xxd -r<CR> :syntax on<CR>

" Run make with ,m
nnoremap <leader>m :silent make\|redraw!\|cc<CR>

" Run buffer with ,r
nnoremap <leader>r :!%:p<Enter>

" Format code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>f :ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>f :ClangFormat<CR>
autocmd FileType python map <buffer><Leader>f :call yapf#YAPF()<cr>
autocmd FileType python imap <buffer><Leader>f <c-o>:call yapf#YAPF()<cr>
"autocmd FileType python set formatprg=yapf

" Automatically reload folds
au BufWinLeave ?* mkview
au BufWinEnter ?* silent loadview

au BufRead,BufNewFile,BufEnter *.m setlocal et sw=2 ts=2 sts=2
au BufRead,BufNewFile,BufEnter *.py setlocal et sw=2 ts=2 sts=2 textwidth=100

if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
