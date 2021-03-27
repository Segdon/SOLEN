#!/bin/sh
# Installerscripts by Angelos Tsiakrilis
# https://github.com/Segdon
# License: GNU GPLv3


#Just to be sure
sudo eopkg rm vi vim

#And then the installation itself
sudo eopkg install neovim
ln -s /usr/bin/nvim /usr/bin/vim
ln -s /usr/bin/nvim /usr/bin/vi

