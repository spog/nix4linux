#!/bin/bash

NIX_VERSION="2.6.1"
INSTALLER_NAME="install-nix-${NIX_VERSION}"
INSTALLER_URL="https://releases.nixos.org/nix/nix-${NIX_VERSION}/install"

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

# Get and verify the installer?
if [ ! -f "./${INSTALLER_NAME}" ]; then
	echo
	echo "Installer not available!"
	echo "Remove any signature and download new '${INSTALLER_URL}' to '${INSTALLER_NAME}'"
	rm -f ./${INSTALLER_NAME}.asc
	curl -o ./${INSTALLER_NAME} ${INSTALLER_URL}
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "Error: Installer download failed!"
		exit $ret
	fi
fi
if [ ! -f "./${INSTALLER_NAME}.asc" ]; then
	echo
	echo "Signature not available!"
	echo "Download new '${INSTALLER_URL}.asc' to '${INSTALLER_NAME}.asc'"
	curl -o ./${INSTALLER_NAME}.asc ${INSTALLER_URL}.asc
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "Error: Signature download failed!"
		exit $ret
	fi
	echo
	echo "Receive GPG keys:"
	gpg2 --keyserver hkps://keyserver.ubuntu.com --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "Error: Receiveing GPG keys failed!"
		exit $ret
	fi
fi

echo
echo "Verify the installer:"
gpg2 --verify ./${INSTALLER_NAME}.asc
ret=$?
if [ $ret -ne 0 ]; then
	echo "Error: Installer verificaion failed!"
	exit $ret
fi
echo

set -x
sh ./${INSTALLER_NAME} --daemon

