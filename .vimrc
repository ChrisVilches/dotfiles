let mapleader = " "

set linebreak
set nowrap
set number
set timeoutlen=1000 ttimeoutlen=0
set nocompatible
set ruler
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
set clipboard=unnamedplus
syntax on

"Not sure, kinda sucks
set background=dark

nnoremap <silent> <leader>wt :set wrap!<CR>
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Copy whole file to clipboard
nnoremap <C-c> :%y+<CR>

" Save file with Ctrl+S
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
vnoremap <C-s> <Esc>:w<CR>gv

" Quit the current window with <leader>q
nnoremap <silent> <leader>q :q<CR>
" This one is because of my muscle memory (I tend to want to close all windows)
nnoremap <silent> <leader>Q :qa<CR>

" Jump 6 lines up/down
nnoremap <C-j> 6j
xnoremap <C-j> 6j
nnoremap <C-k> 6k
xnoremap <C-k> 6k

" Move selected lines up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

