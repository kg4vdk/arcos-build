#!/bin/bash

# ARCOS_DEV
ARCOS_DEV="/media/user/ARCOS-DEV"

# Build repo directory
BUILD_REPO="${ARCOS_DEV}/arcos-build"

# Mint ISO and checksum
MINT_ISO="${ARCOS_DEV}/linuxmint-22.2-cinnamon-64bit.iso"
MINT_ISO_SHA256="759c9b5a2ad26eb9844b24f7da1696c705ff5fe07924a749f385f435176c2306"

# Verify ISO exists
if [ ! -f ${MINT_ISO} ]; then
	echo "${MINT_ISO} not available. Please download the ISO to the specified location."
	exit 1
else
	if [[ "$(sha256sum ${MINT_ISO} | awk -F " " '{print $1}' > /dev/null)" != "${MINT_ISO_SHA256}" ]]; then
		echo "ISO checksum does not match. Please re-download the ISO."
		exit 2
	else
		echo "ISO checksum valid."
	fi
fi

# Verify arcos-linux-modules are included
if [ ! -d ${BUILD_REPO}/arcos-linux-modules/.git ]; then
	echo "arcos-linux-modules not available. Downloading..."
	git clone --branch ${BRANCH} https://github.com/kg4vdk/arcos-linux-modules ${BUILD_REPO}/arcos-linux-modules || exit 3
else
	echo "Using available arcos-linux-modules:"
	git --git-dir ${BUILD_REPO}/arcos-linux-modules/.git show | head -n 3
fi

# Setup temporary SSH key for build
mkdir -p ${BUILD_REPO}/ssh
if [ -f ${BUILD_REPO}/ssh/arcos-build-key ]; then
	rm -rf ${BUILD_REPO}/ssh/arcos-build-key*
fi
ssh-keygen -f ${BUILD_REPO}/ssh/arcos-build-key -P "" -q
cat ${BUILD_REPO}/ssh/arcos-build-key.pub >> $HOME/.ssh/authorized_build_keys
