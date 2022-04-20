#!/bin/bash
pacman -S xorg plasma konsole dolphin neovim emacs git firefox openssh base-devel kdeconnect
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
git clone /opt/ && cd /opt/yay/ && makepkg -si
yay -S nvim-packer-git
# Setup Links
ln -s ~/.dotfiles/doom.d ~/.doom.d
ln -s ~/.dotfiles/nvim ~/.config/nvim
# Install doom
~/.emacs.d/bin/doom install


