#!/bin/sh
# Installerscripts by Angelos Tsiakrilis
# https://github.com/Segdon
# License: GNU GPLv3


#hier moet ik nog aan toevoegen dit enkel te doen indien het bestand bestaat
sudo /opt/VirtualBox/uninstall.sh

#bring system up to date
sudo eopkg upgrade -y

#install all (not for lts-kernel)
sudo eopkg install virtualbox-current virtualbox-common -y

# If you want to use USB 2.0 or 3.0 in your virtual machine (and your hardware supports it), you have to install the extension pack.
# Note: Access to USB is granted by the user group vboxusers on the Host operating system. You can add yourself to this group with the following command
sudo gpasswd -a $USER vboxusers
