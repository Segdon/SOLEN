#!/bin/sh
# Installerscripts by Angelos Tsiakrilis
# https://github.com/Segdon
# License: GNU GPLv3

#The XSession file location varies between distributions, but is most of the time found in /usr/share/xsessions.
#To add a session for an alternate window manager as superuser:
#Copy the existing Plasma session file
#cp /usr/share/xsessions/plasma.desktop /usr/share/xsessions/plasma-i3.desktop
#Using a text editor, open the file and change the Exec line, and optionally the Descriptioni
printf "[Desktop Entry]\n"\
"Type=XSession\n"\
"Exec=env KDEWM=/usr/bin/i3 /usr/bin/startplasma-x11\n"\
"DesktopNames=KDE\n"\
"Name=Plasma (i3)\n"\
"Comment=Plasma by KDE w/i3\n"\
> /usr/share/xsessions/plasma-i3.desktop

echo "I3 added as an window manager"
echo "It's best to reboot now and choose the correct session on login"
