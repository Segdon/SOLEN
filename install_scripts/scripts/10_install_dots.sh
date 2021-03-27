#!/bin/sh
# Installerscripts by Angelos Tsiakrilis
# https://github.com/Segdon
# License: GNU GPLv3

dotfilesrepo="https://github.com/Segdon/Solus_dots.git"
branch="main"
dir=$(mktemp -d)
dir2=/home/$USER

putgitrepo() { # Downloads a gitrepo $1 and places the files in $2 only overwriting conflicts

	chown "$USER":$USER "$dir" "$dir2"

	sudo -u "$USER" git clone --recursive -b "$branch" --depth 1 --recurse-submodules "$dotfilesrepo" "$dir" >/dev/null 2>&1

	sudo -u "$USER" cp -rfT "$dir" "$dir2"
	}


# Install the dotfiles in the user's home directory
putgitrepo "$dotfilesrepo" "/home/$USER" "$branch"
rm -f "/home/$USER/README.md" "/home/$USER/LICENSE" "/home/$USER/FUNDING.yml"
# Create default urls file if none exists.
[ ! -f "/home/$name/.config/newsboat/urls" ] && echo "https://www.archlinux.org/feeds/news/" > "/home/$USER/.config/newsboat/urls"
# make git ignore deleted LICENSE & README.md files
git update-index --assume-unchanged "/home/$USER/README.md" "/home/$USER/LICENSE"




