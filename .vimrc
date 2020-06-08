" VIM CONFIG - github.com/mawall/dotfiles

" GENERAL SETTINGS {{{
set nocompatible 		" no vi compatability
filetype off

" mouse
set mouse=a		        " enable mouse
set ttymouse=xterm2	    " enable mouse resizing

" display
set number		        " line numbers
set ruler		        " display row, column and rel. pos.
set noerrorbells	    " no error sounds
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set hidden              " allow editing buffers w/o saving

" indentation
set tabstop=4           " number of visual spaces per TAB
set softtabstop=4       " number of spaces in tab when editing
set expandtab           " tabs are spaces
"}}}

" RUNTIME PATH {{{
set rtp+=~/.vim/bundle/Vundle.vim   " include vundle
set rtp+=~/.fzf                     " include fzf
" }}}

" VUNDLE {{{
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' 	" vundle needs to manage itself

Plugin 'junegunn/fzf.vim'               " fzf for vim
Plugin 'ycm-core/YouCompleteMe'			" code completion
Plugin 'vim-scripts/taglist.vim' 		" source code browser
" Plugin 'vim-airline/vim-airline'		" statusbar
Plugin 'itchyny/lightline.vim'          " statusbar
Plugin 'tpope/vim-fugitive'			    " git wrapper
Plugin 'scrooloose/nerdtree'			" file explorer
Plugin 'sjl/gundo.vim'                  " distplay undo tree

"Plugin 'fenetikm/falcon'		        " color scheme
Plugin 'doums/darcula'                  " color scheme

call vundle#end()
filetype plugin indent on

set laststatus=2                        " show lightline
" }}}

" COLORS {{{
syntax enable
colorscheme darcula
let g:lightline = { 'colorscheme': 'darculaOriginal' }
" }}}

" CUSTOM BINDINGS {{{
" map leader key from / to ,
let mapleader = ","

" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

" toggle gundo
nnoremap <leader>u :GundoToggle<CR>

" toggle nerdtree
nnoremap <leader>t :NERDTreeToggle<CR>

" save session
nnoremap <leader>s :mksession<CR>

" open files with fzf
nnoremap <leader>o :Files<CR>
nnoremap <leader>O :Files!<CR>

" use space to toggle folds
nnoremap <space> za

" map ctrl-c to copy to system clipboard
vnoremap <C-c> "+y

" map ctrl-x to cut to system clipboard
vnoremap <C-x> "+d
" }}}

" vim:foldmethod=marker:foldlevel=0
