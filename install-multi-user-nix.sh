#!/bin/bash

if [ "x${1}" != "xlogged" ]; then
	readonly LOGFILE=$(basename $0 .sh)-${1}.log
	# Restart the script through 'script' with parameter 'logged'
        # to do the work:
	script -e -c "${0} logged ${1}" $LOGFILE
	exit $?
fi
shift
trap 'exit' SIGINT

NIX_VERSION="${1}"
if [ -z "${NIX_VERSION}" ]; then
	echo
	echo "ERROR: add single argument (the 'nix' version to install)!"
	echo "You can find 'current' version here: https://nixos.org/download.html"
	echo
	exit 1
fi
INSTALLER_NAME="install-nix-${NIX_VERSION}"
INSTALLER_URL="https://releases.nixos.org/nix/nix-${NIX_VERSION}/install"

echo
echo "!!!INFO!!!"
echo "You are about to install Nix package manager (version: ${NIX_VERSION})!"
echo
if [ "x$(which nix)" != "x" ]; then
	echo "!!!WARNING: found installed '$(nix --version)'!!!"
else
	echo "Nix not found installed!"
fi
echo
echo "This script starts Nix package manger multi-user installation process"
echo "and collects its output to a log file!"
echo
echo -n "Do you want to proceed (y/n)? "
read INPUT
if [ "x${INPUT}" != "xy" ]; then
	echo
	echo "Installation cancelled!"
	exit 0
fi

if [ "x$(which nix)" != "x" ]; then
	echo
#	echo "Can not proceed!"
#	echo "Already installed: $(nix --version)"
#	exit 1
fi

echo
if [ ! -f "./${INSTALLER_NAME}" ]; then
	echo "Installer not available!"
	echo "Remove any signature and download new '${INSTALLER_URL}' to './${INSTALLER_NAME}':"
	rm -f ./${INSTALLER_NAME}.asc
	curl -o ./${INSTALLER_NAME} ${INSTALLER_URL}
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "Error: Installer download failed!"
		exit $ret
	fi
fi
echo "Installer './${INSTALLER_NAME}' available!"
echo
if [ ! -f "./${INSTALLER_NAME}.asc" ]; then
	echo
	echo "Signature not available!"
	echo "Download new '${INSTALLER_URL}.asc' to './${INSTALLER_NAME}.asc':"
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
echo "Signature './${INSTALLER_NAME}.asc' available!"
echo
echo "Verify the installer:"
gpg2 --verify ./${INSTALLER_NAME}.asc
ret=$?
if [ $ret -ne 0 ]; then
	echo "Error: Installer verificaion failed!"
	exit $ret
fi
echo

echo "Run the installer"
set -x; sh ./${INSTALLER_NAME} --daemon
exit $?
