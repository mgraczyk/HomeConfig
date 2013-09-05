"----------------------------
" Recommended vim settings

" Allow switching between unsaved buffers
set hidden

" Better completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches
set hlsearch

"----------------------------
" Encouraged/Usability settings

set ignorecase
set smartcase

set ruler
set confirm
set visualbell

" Line numbers
set number


filetype plugin on
set nocompatible
syntax on
if has("autocmd")
	filetype plugin indent on
endif

" Indentation settings
set shiftwidth=3
set tabstop=3

syntax enable
set wildmenu
set ffs=unix
set ff=unix
set splitbelow
set splitright

" Colors
if has('gui_running')
	set guifont=Ubuntu\ Mono\ 12
	set guioptions-=T " no toolbar
endif

if has('gui_running')
	colorscheme solarized
	set background=dark
else
	set background=light
endif

" Space inserts a space
nmap <Space> i_<Esc>r


