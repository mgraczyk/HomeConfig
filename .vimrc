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


" Relative numbers, with current line number at cursor
set relativenumber
set number

" undo between instances
set undofile

if has("autocmd")
	filetype plugin indent on
endif

" Indentation settings
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

syntax on
syntax enable
set ffs=unix
set ff=unix
set splitbelow
set splitright


" Searching/Moving
set mouse=nv
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>

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

" Colors

if has('gui_running')
	set guioptions-=T " no toolbar
   set guifont=Consolas
endif

set background=dark
let g:solarized_italic = 1
colorscheme solarized

" Comments should be in italics
highlight Comment gui=italic 


set completeopt-=preview


"" Various Personal Remappings
let mapleader = ","

" Space inserts a space
nmap <Space> i_<Esc>r
"Ctrl-c closes buffer but not window
nnoremap <C-c> :bp\|bd # <CR>

" Leader t and Leader T for time strings
" T is UNIX time
nnoremap <Leader>t "=strftime("%FT%T%z")<CR>P
"inoremap <Leader>t <C-R>=strftime("%FT%T%z")<CR>
nnoremap <Leader>T "=strftime("%s")<CR>P
"inoremap <Leader>T <C-R>=strftime("%s")<CR>

" map Leader-h to html-ify a given document, and Leader-H for a range
map <silent><Leader>h :so $VIMRUNTIME/syntax/2html.vim<CR>
map <silent><Leader>H :TOhtml<CR>

" n is name
nnoremap <Leader>n iMichael Graczyk<Esc>
nnoremap <Leader>N iMichael<Esc>

" Automatically reload folds
au BufWinLeave ?* mkview
au BufWinEnter ?* silent loadview

au BufRead,BufNewFile,BufEnter */dev/arch/src/* setlocal noet sw=2 ts=2 sts=2

