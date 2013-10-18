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
set visualbell

set backspace=indent,eol,start


" Fast scrolling
set ttyfast


" No Line numbers, relative numbers instead
set relativenumber

" undo between instances
set undofile

if has("autocmd")
	filetype plugin indent on
endif

" Indentation settings
set shiftwidth=3
set tabstop=3
set softtabstop=3

syntax on
syntax enable
set ffs=unix
set ff=unix
set splitbelow
set splitright


" Searching/Moving
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


"
