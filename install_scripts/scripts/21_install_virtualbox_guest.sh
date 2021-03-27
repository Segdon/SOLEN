#!/bin/sh
# Installerscripts by Angelos Tsiakrilis
# https://github.com/Segdon
# License: GNU GPLv3

#bring system up to date
sudo eopkg upgrade -y

#install all (not for lts-kernel)
sudo eopkg install virtualbox-guest-common -y

# Share folders let you access files from the host system from within a guest machine.
# Note: auto-mounted shared folders are mounted into the /media directory, along with the prefix sf_. For example, the shared folder myfiles would be mounted to /media/sf_myfiles.
# Access to the shared folders is only granted to the user group vboxsf on the Guest operating system.

# Execute these commands to set the permissions and add yourself to the group
sudo gpasswd -a $USER vboxsf
