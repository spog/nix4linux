#!/bin/bash

readonly LOGFILE=$(basename $0 .sh).log
touch $LOGFILE
exec &> >(tee $LOGFILE)

echo "!!!INFO!!!"
echo "This script starts multi-user NIX installation process and collects"
echo "its output to a log file!"
echo
echo -n "Do you want to proceed (y/n)? "
read INPUT
if [ "x${INPUT}" != "xy" ]; then
	echo
	echo "Install cancelled!"
	exit 0
fi
set -x
# Get and verify the installer?
#curl -o install-nix-2.6.1 https://releases.nixos.org/nix/nix-2.6.1/install
#curl -o install-nix-2.6.1.asc https://releases.nixos.org/nix/nix-2.6.1/install.asc
#gpg2 --keyserver hkps://keyserver.ubuntu.com --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
#gpg2 --verify ./install-nix-2.6.1.asc

sh ./install-nix-2.6.1 --daemon

