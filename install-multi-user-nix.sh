#!/bin/bash

if [ "x${1}" != "xlogged" ]; then
	if [ "x${1}" != "xinit" ]; then
		# Freshen the environment:
		source /etc/profile
		export NIX_VERSION="${1}"
		# Restart the script through 'script' with parameter 'logged'
		# to do the work:
		script -q -e -c "${0} init $@"
		if [ $? -ne 0 ]; then
			exit $?
		fi
	else
		if [ -z "${NIX_VERSION}" ]; then
			echo "error: Add single argument (the 'nix' version to install)!"
			echo "You can find 'current' version here: https://nixos.org/download.html"
			exit 1
		fi

		echo
		echo "You are about to install Nix package manager (version: ${NIX_VERSION})!"
		echo
		if [ "x$(which nix)" != "x" ]; then
			echo "error: Found installed 'nix' (version: $(nix --version | sed -e 's/*. //g'))!"
			echo "Nix need to be uninstalled to proceed!"
			exit 1
		else
			echo "Seems 'nix' not already installed - OK!"
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
			exit 1
		fi
		exit 0
	fi
	readonly LOGFILE=$(basename $0 .sh)-${NIX_VERSION}.log
	mv -f typescript $LOGFILE
	# Restart the script through 'script' with parameter 'logged'
        # to do the work:
	script -a -e -c "${0} logged ${NIX_VERSION}" $LOGFILE
	exit $?
fi
shift
trap 'exit' SIGINT

function exit_fn ()
{
	set +x; echo
	exit $1
}

INSTALLER_NAME="install-nix-${NIX_VERSION}"
INSTALLER_URL="https://releases.nixos.org/nix/nix-${NIX_VERSION}/install"

echo
if [ ! -f "./${INSTALLER_NAME}" ]; then
	echo "Installer not available!"
	echo "Remove any signature and download new '${INSTALLER_URL}' to './${INSTALLER_NAME}':"
	rm -f ./${INSTALLER_NAME}.asc
	curl -o ./${INSTALLER_NAME} ${INSTALLER_URL}
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "error: Installer download failed!"
		exit_fn $ret
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
		echo "error: Signature download failed!"
		exit_fn $ret
	fi
	echo
	echo "Receive GPG keys:"
	gpg2 --keyserver hkps://keyserver.ubuntu.com --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "error: Receiveing GPG keys failed!"
		exit_fn $ret
	fi
fi
echo "Signature './${INSTALLER_NAME}.asc' available!"
echo
echo "Verify the installer:"
gpg2 --verify ./${INSTALLER_NAME}.asc
ret=$?
if [ $ret -ne 0 ]; then
	echo "error: Installer verificaion failed!"
	exit_fn $ret
fi
echo

echo "Run the installer"
set -x; sh ./${INSTALLER_NAME} --daemon
exit_fn $?
