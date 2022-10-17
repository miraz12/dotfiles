
return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'dracula/vim'
  use 'ggandor/leap.nvim'
end)
