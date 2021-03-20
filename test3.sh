#!/bin/sh
# This is a script I use to Enhance my solus installation automaticly.
# Since I have little to no scripting-experience, this script is heavilly based on Luke Smith's LARBS-installer
# Luke's Auto Rice Boostrapping Script (LARBS)
# by Luke Smith <luke@lukesmith.xyz>
# License: GNU GPLv3

### OPTIONS AND VARIABLES ###

while getopts ":r:b:p:h" o; do case "${o}" in
	h) printf "Optional arguments for custom use:\\n  -r: Dotfiles repository (local file or url)\\n  -p: Dependencies and programs csv (local file or url)\\n  -a: AUR helper (must have pacman-like syntax)\\n  -h: Show this message\\n" && exit 1 ;;
	r) dotfilesrepo=${OPTARG} && git ls-remote "$dotfilesrepo" || exit 1 ;;
	b) repobranch=${OPTARG} ;;
	p) progsfile=${OPTARG} ;;
	*) printf "Invalid option: -%s\\n" "$OPTARG" && exit 1 ;;
esac done

[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/Segdon/Solus_dots.git"
[ -z "$progsfile" ] && progsfile="https://raw.githubusercontent.com/Segdon/SOLEN/master/progs.csv"
[ -z "$repobranch" ] && repobranch="master"

### FUNCTIONS ###

welcomemsg() { \
	dialog --title "Welcome!" --msgbox "This is my personal SOLus-ENhancer!\\nJust to make Solus even better!\\n\\n-Nostro" 10 60

	dialog --colors --title "Attention!" --yes-label "Ok-go!" --no-label "Back..." --yesno "An internet-connection is necessary.\\nHope you're installing as root." 8 70
	}

getuserandpass() { \
	# Prompts user for new username an password.
	name=$(dialog --inputbox "What user do you want to enhance?" 10 60 3>&1 1>&2 2>&3 3>&1) || exit 1
	while ! echo "$name" | grep -q "^[a-z_][a-z0-9_-]*$"; do
		name=$(dialog --no-cancel --inputbox "This username not is valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	pass1=$(dialog --no-cancel --passwordbox "Enter a password." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype the password." 10 60 3>&1 1>&2 2>&3 3>&1)
	while ! [ "$pass1" = "$pass2" ]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done ;}

adduserandpass() { \
	# Adds user `$name` with password $pass1.
	dialog --infobox "checking user \"$name\"..." 4 50
	usermod -a -G wheel "$name" && chown "$name":"$name" /home/"$name"
	repodir="/home/$name/.local/src"; mkdir -p "$repodir"; chown -R "$name":"$name" "$(dirname "$repodir")"
	echo "$name:$pass1" | chpasswd
	unset pass1 pass2 ;}


installpkg(){ eopkg install -y "$1" >/dev/null 2>&1 ;}

error(){ clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;}

baseinstall(){ eopkg install -y -c system.devel
	}

maininstall() { # Installs all needed programs from main repo.
	dialog --title "Solus Enhancer" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	installpkg "$1"
	}

gitmakeinstall() {
	progname="$(basename "$1" .git)"
	dir="$repodir/$progname"
	dialog --title "Solus Enhancer" --infobox "Installing \`$progname\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2" 5 70
	sudo -u "$name" git clone --depth 1 "$1" "$dir" >/dev/null 2>&1 || { cd "$dir" || return 1 ; sudo -u "$name" git pull --force origin master;}
	cd "$dir" || exit 1
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return 1 ;}

pipinstall() { \
	dialog --title "Solus Enhancer" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
	[ -x "$(command -v "pip")" ] || installpkg python-pip >/dev/null 2>&1
	yes | pip install "$1"
	}

installationloop() { \
	([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep -q "^\".*\"$" && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"G") gitmakeinstall "$program" "$comment" ;;
			"P") pipinstall "$program" "$comment" ;;
			*) maininstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv ;}

putgitrepo() { # Downloads a gitrepo $1 and places the files in $2 only overwriting conflicts
	dialog --infobox "Downloading and installing config files..." 4 60
	[ -z "$3" ] && branch="$repobranch"
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2"
	chown "$name":"$name" "$dir" "$2"
	sudo -u "$name" git clone --recursive -b "$branch" --depth 1 --recurse-submodules "$1" "$dir" >/dev/null 2>&1
	sudo -u "$name" cp -rfT "$dir" "$2"
	}

systembeepoff() { dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
	/sbin/rmmod pcspkr
	echo "blacklist pcspkr" > /etc/modules-load.d/nobeep.conf ;}

newperms() { # Set special sudoers settings for install (or after).
	sed -i "SOLEN/d" /etc/sudoers
	echo "$* #SOLEN" >> /etc/sudoers ;}

finalize(){ \
	dialog --infobox "Preparing welcome message..." 4 50
	dialog --title "All done!" --msgbox "Congrats! Enhancement is all done. Great time to reboot.\\n\\n Nostro" 12 80
	}

##############################################################################################
##############################################################################################
##############################################################################################
### THE ACTUAL SCRIPT ###
##############################################################################################
##############################################################################################
##############################################################################################

### This is how everything happens in an intuitive format and order.

# Check if user is root on Solus distro. Install dialog.
eopkg install -y dialog || error "Are you sure you're running this as the root user, are on an Solus-based distribution and have an internet connection?"

# Welcome user and pick dotfiles.
welcomemsg || error "User exited."

# Get and verify username and password.
getuserandpass || error "User exited."

# Give warning if user already exists.
#usercheck || error "User exited."

# Last chance for user to back out before install.
#preinstallmsg || error "User exited."

#installing build en development-tools
baseinstall

### The rest of the script requires no user input.

for x in curl git; do
	dialog --title "Solus enhancer" --infobox "Installing \`$x\` which is required to install and configure other programs." 5 70
	installpkg "$x"
done

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

# Install the dotfiles in the user's home directory
putgitrepo "$dotfilesrepo" "/home/$name" "$repobranch"
rm -f "/home/$name/README.md" "/home/$name/LICENSE"
# Create default urls file if none exists.
[ ! -f "/home/$name/.config/newsboat/urls" ] && echo "http://lukesmith.xyz/rss.xml
https://www.archlinux.org/feeds/news/" > "/home/$name/.config/newsboat/urls"
# make git ignore deleted LICENSE & README.md files
git update-index --assume-unchanged "/home/$name/README.md" "/home/$name/LICENSE"

# Most important command! Get rid of the beep!
systembeepoff

# Tap to click
[ ! -f /etc/X11/xorg.conf.d/40-libinput.conf ] && printf 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
	# Enable left mouse button by tapping
	Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/40-libinput.conf

# This line, overwriting the `newperms` command above will allow the user to run
# serveral important commands, `shutdown`, `reboot`, updating, etc. without a password.
newperms "%wheel ALL=(ALL) NOPASSWD: ALL #SOLEN"

# Last message! Install complete!
finalize
clear
