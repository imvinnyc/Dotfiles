" -------------------------------
"        BASIC SETTINGS
" -------------------------------

" Enable line numbers
set number

" Use spaces instead of tabs
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Enable auto-indentation
set autoindent
set smartindent

" Enable syntax highlighting
syntax on

" Highlight matching brackets
set showmatch

" Enable incremental search and highlight matches
set incsearch
set hlsearch

" Enable mouse support
set mouse=a

" Use system clipboard
set clipboard=unnamedplus

" Show the line and column number
set ruler

" Make backspace behave normally
set backspace=indent,eol,start

" Disable swap files
set noswapfile

" Hide ~ on empty lines below the buffer
set fillchars=vert:\ ,eob:\ ,fold:\ ,diff:⣿

" Set a color scheme
colorscheme desert

" Optional: Enable relative line numbers
" set relativenumber

" Enable persistent undo
set undofile

" Faster redraw
set lazyredraw

" Reduce command timeout
set timeoutlen=500

" Disable line wrapping
set nowrap

" Make all line number-related UI elements match LineNr (from the colorscheme)
highlight! link CursorLineNr LineNr
highlight! link EndOfBuffer LineNr
highlight! link NonText LineNr
