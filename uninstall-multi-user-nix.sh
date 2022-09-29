#!/bin/bash

if [ "x${1}" != "xlogged" ]; then
	readonly LOGFILE=$(basename $0 .sh).log
	# Restart the script through 'script' with parameter 'logged'
	# to do the work:
	script -e -c "$0 logged $@" $LOGFILE
	exit $?
fi
shift
trap 'exit' SIGINT

if [ "x$(which nix)" != "x" ]; then
	echo
	echo "!!!INFO: found '$(nix --version)'!!!"
#	echo "Found installed: $(nix --version)"
else
	echo
	echo "!!!INFO: 'nix' not found (nothing to do)!!!"
	echo
	exit 0
fi
echo
echo "!!!WARNING!!!"
echo "This script is going to completely remove multi-user Nix package manager"
echo "installation, including NIX store and its database!"
echo
echo -n "Do you really want to proceed (y/n)? "
read INPUT
echo
if [ "x${INPUT}" != "xy" ]; then
	echo "Uninstallation cancelled!"
	echo
	exit 0
fi

set -x
sudo systemctl stop nix-daemon.socket
sudo systemctl stop nix-daemon.service
sudo systemctl disable nix-daemon.socket
sudo systemctl disable nix-daemon.service
sudo systemctl daemon-reload
rm -rf ~/.nix-*
sudo bash -c 'rm -rf /root/.nix-*'
sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc
sudo rm /etc/bashrc /etc/zshrc
sudo rm /etc/bashrc.backup-before-nix /etc/zshrc.backup-before-nix
sudo rm /etc/profile.d/nix.sh
sudo rm /etc/profile.d/nix.sh.backup-before-nix

sudo rm -rf /nix /etc/nix
sudo userdel nixbld1
sudo userdel nixbld2
sudo userdel nixbld3
sudo userdel nixbld4
sudo userdel nixbld5
sudo userdel nixbld6
sudo userdel nixbld7
sudo userdel nixbld8
sudo userdel nixbld9
sudo userdel nixbld10
sudo userdel nixbld11
sudo userdel nixbld12
sudo userdel nixbld13
sudo userdel nixbld14
sudo userdel nixbld15
sudo userdel nixbld16
sudo userdel nixbld17
sudo userdel nixbld18
sudo userdel nixbld19
sudo userdel nixbld20
sudo userdel nixbld21
sudo userdel nixbld22
sudo userdel nixbld23
sudo userdel nixbld24
sudo userdel nixbld25
sudo userdel nixbld26
sudo userdel nixbld27
sudo userdel nixbld28
sudo userdel nixbld29
sudo userdel nixbld30
sudo userdel nixbld31
sudo userdel nixbld32
sudo groupdel nixbld
exit 0