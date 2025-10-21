# Neovim program configuration
# This file configures neovim with basic settings

{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    
    # Use a custom neovim configuration
    defaultEditor = true;
    
    # Basic configuration
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set smartindent
      set wrap
      set linebreak
      set showbreak=+++
      set textwidth=100
      set showmatch
      set visualbell
      set hlsearch
      set smartcase
      set ignorecase
      set incsearch
      set autoindent
      set copyindent
      set preserveindent
      set softtabstop=0
      set shiftround
      set fileformats=unix
      set encoding=utf-8
      set fileencoding=utf-8
      set ruler
      set undolevels=1000
      set backspace=indent,eol,start
      
      " Color scheme
      colorscheme default
      syntax on
      
      " Key mappings
      let mapleader = " "
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>x :x<CR>
      nnoremap <leader>h :nohlsearch<CR>
      
      " File type specific settings
      autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
      autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType css setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab
    '';
    
    # Plugins (basic set)
    plugins = with pkgs.vimPlugins; [
      # Essential plugins
      vim-nix
      vim-fugitive
      vim-surround
      vim-commentary
      vim-repeat
      
      # File navigation
      fzf-vim
      nerdtree
      
      # Syntax highlighting
      vim-polyglot
      
      # Status line
      lightline-vim
    ];
  };
}
