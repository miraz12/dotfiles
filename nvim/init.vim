" Its VIM, not vi
set nocompatible
syntax on
filetype plugin indent on

lua require('plugins')
lua require('leap').add_default_mappings()

" Airline
let g:airline_theme='dracula'
let g:airline_powerline_fonts = 1

