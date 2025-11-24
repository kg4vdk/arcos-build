#!/bin/bash

# TIMESTAMP
DATE="$(date +'%m%d')"

# ARCOS_DEV
ARCOS_DEV=/media/user/ARCOS-DEV

# Build directory
BUILD_DIR="${ARCOS_DEV}/cubic-build"

# Stable release version and codename
STABLE_RELEASE="22.2.0"
STABLE_CODENAME="Denali"

# Xanadu release version
XANADU_RELEASE="22.2.0-${DATE}"

# For Xanadu builds, the first argument
# is available as an "Alpha" designator
# for same-day re-builds
ALPHA="$1"

# If no "Alpha" designator, assume stable build
if [ -z "${ALPHA}" ]; then
	RELEASE="${STABLE_RELEASE}"
	CODENAME="${STABLE_CODENAME}"
else
	RELEASE="${XANADU_RELEASE}"
	CODENAME="Xanadu"
fi

if [ "${CODENAME}" == "Xanadu" ]; then
	PROJECT_NAME="arcOS-${XANADU_RELEASE}${ALPHA}_${CODENAME}"
else
	PROJECT_NAME="arcOS-${STABLE_RELEASE}_${CODENAME}"
fi

CUBIC_VERSION=$(dpkg -s cubic | grep '^Version:' | awk -F " " '{print $2}')

DATE="$(date +'%F %R')"

##########################################

mkdir -p ${BUILD_DIR}

cat <<EOF > ${BUILD_DIR}/cubic.conf
[Project]
cubic_version = ${CUBIC_VERSION}
first_version = ${CUBIC_VERSION}
create_date = ${DATE}
modify_date = ${DATE}
directory = ${BUILD_DIR}

[Original]
iso_file_name = linuxmint-22.2-cinnamon-64bit.iso
iso_directory = ${ARCOS_DEV}
iso_volume_id = Linux Mint 22.2 Cinnamon 64-bit
iso_release_name = Zara

[Custom]
iso_version_number = arcOS-${RELEASE}_${CODENAME}
iso_file_name = ${PROJECT_NAME}.iso
iso_directory = ${BUILD_DIR}
iso_volume_id = arcOS-${RELEASE}_${CODENAME}
iso_release_name = ${CODENAME}
iso_disk_name = arcOS-${RELEASE}_${CODENAME} "${CODENAME}"

[Options]
update_os_release = False
has_minimal_install = False
boot_configurations = boot/grub/grub.cfg, isolinux/live.cfg
compression = zstd
EOF

cubic ${BUILD_DIR} &
