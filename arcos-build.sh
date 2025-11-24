#!/bin/bash

LOCAL_PKGS="$1"

#RELEASE="22.2.0"
RELEASE="22.2.0-$(date +'%m%d')"
CODENAME="Xanadu"
#RELEASE="22.2.0"
#CODENAME="Denali"

BUILD_HOST="arcOS.local"
BUILD_USER="user"

SETUP_DIR=/root/arcos-build
ARCOS_DIR=/opt/arcOS

#ARCOS_DEV=/media/ARCOS-DEV
ARCOS_DEV=/media/user/ARCOS-DEV

# Build directory
BUILD_DIR=${ARCOS_DEV}/cubic-build

# Output colors
BLK='\033[01;30m'
RED='\033[01;31m'
ORG='\033[38;5;208m'
YEL='\033[01;33m'
GRN='\033[01;32m'
CYN='\033[01;36m'
BLU='\033[01;34m'
PRP='\033[01;35m'
WHT='\033[01;37m'
GRY='\033[01;90m'
RST='\033[0m' # No Color

# A build banner...
echo
echo
echo -e "${RED}########  ##     ## #### ##       ########  #### ##    ##  ######         ###    ########   ######   #######   ######              "
echo -e "${ORG}##     ## ##     ##  ##  ##       ##     ##  ##  ###   ## ##    ##       ## ##   ##     ## ##    ## ##     ## ##    ##             "
echo -e "${YEL}##     ## ##     ##  ##  ##       ##     ##  ##  ####  ## ##            ##   ##  ##     ## ##       ##     ## ##                   "
echo -e "${GRN}########  ##     ##  ##  ##       ##     ##  ##  ## ## ## ##   ####    ##     ## ########  ##       ##     ##  ######              "
echo -e "${CYN}##     ## ##     ##  ##  ##       ##     ##  ##  ##  #### ##    ##     ######### ##   ##   ##       ##     ##       ##             "
echo -e "${BLU}##     ## ##     ##  ##  ##       ##     ##  ##  ##   ### ##    ##     ##     ## ##    ##  ##    ## ##     ## ##    ## ### ### ### "
echo -e "${PRP}########   #######  #### ######## ########  #### ##    ##  ######      ##     ## ##     ##  ######   #######   ######  ### ### ### ${RST}"
echo
echo

###################################################

arcos_iso_setup () {
ssh_keys
create_package_archive
boot_files
use_local_packages
remove_packages
remove_icons
remove_themes
if [ "${LOCAL_PKGS}" != "local" ]; then
	add_repositories
	update_repos
	#upgrade_system
fi
#install_hwe_kernel
#remove_old_kernel
install_firefox-esr
arcos_files
arcos_packages
#compile_sensitive_files
install_security_tools
install_viking
remove_pipewire
setup_digirig
install_gpsd
install_hamlib
install_ardopcf
install_direwolf
install_pat
install_fl_suite
install_yaac
install_js8call
install_wsjtx
install_qsstv
install_paracon
install_gpredict
install_rtlsdr
install_piaware
#install_qemu
install_wine
arcos_customization
disable_wayland
update_package_archive
wait_fldigi
cleanup
}

ssh_keys () {
echo -e "${CYN}### ENABLE SSH KEYS ###${RST}" >&2
SSH_KEY="/root/.ssh/arcos-build-key"
sudo cp ${SETUP_DIR}/ssh/arcos-build-key ${SSH_KEY}
sudo chmod 600 ${SSH_KEY}
}

create_package_archive () {
echo -e "${CYN}### CREATE PACKAGE ARCHIVE ###${RST}" >&2
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${BUILD_USER}@${BUILD_HOST} "mkdir -p ${BUILD_DIR}/local-packages/{cache,keyrings,lists,misc/pat,sources,trusted}" > /dev/null 2>&1
}

boot_files () {
echo -e "${CYN}### COPY BOOT FILES ###${RST}" >&2
sed -i 's/\"Start arcOS\"/\"[DEFAULT]  arcOS '"${RELEASE}"' '"${CODENAME}"'\"/' ${SETUP_DIR}/boot/grub.cfg
sed -i 's/Start arcOS/[DEFAULT]  arcOS '"${RELEASE}"' '"${CODENAME}"'/' ${SETUP_DIR}/boot/live.cfg
sed -i 's/\"Boot arcOS to RAM\"/\"[RAM ONLY] arcOS '"${RELEASE}"' '"${CODENAME}"'\"/' ${SETUP_DIR}/boot/grub.cfg
sed -i 's/Boot arcOS to RAM/[RAM ONLY] arcOS '"${RELEASE}"' '"${CODENAME}"'/' ${SETUP_DIR}/boot/live.cfg

scp -i ${SSH_KEY} ${SETUP_DIR}/boot/grub.cfg ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/custom-disk/boot/grub/ >&2
scp -i ${SSH_KEY} ${SETUP_DIR}/boot/live.cfg ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/custom-disk/isolinux/ >&2
scp -i ${SSH_KEY} ${SETUP_DIR}/boot/grub-splash.png ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/custom-disk/boot/grub/ >&2
scp -i ${SSH_KEY} ${SETUP_DIR}/boot/isolinux-splash.png ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/custom-disk/isolinux/ >&2
}

use_local_packages () {
echo -e "${CYN}### LOCAL PACKAGES ###${RST}" >&2
if [ "${LOCAL_PKGS}" == "local" ]; then
	echo -e "Using local-packages...${GRN}YES${RST}" >&2
	echo -n "Copying local-packages..." >&2
	sudo scp -i ${SSH_KEY} -q -r ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/cache/* /var/cache/apt/ >&2
	sudo scp -i ${SSH_KEY} -q -r ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/keyrings/* /etc/apt/keyrings/ >&2
	sudo scp -i ${SSH_KEY} -q -r ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/lists/* /var/lib/apt/lists/ >&2
	sudo scp -i ${SSH_KEY} -q -r ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/sources/* /etc/apt/sources.list.d/ >&2
	sudo scp -i ${SSH_KEY} -q -r ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/trusted/* /etc/apt/trusted.gpg.d/ >&2
	echo -e "${GRN}DONE${RST}" >&2
else
	echo -e "Using local-packages...${RED}NO${RST}" >&2
fi
}

install_packages () {
# Helper to install packages when needed
if [ "${LOCAL_PKGS}" == "local" ]; then
	sudo apt-get install -y ${DEPENDS}
else
	sudo apt-get install -y --download-only ${DEPENDS}
	sudo apt-get install -y ${DEPENDS}
fi
}

remove_packages () {
echo -e "${CYN}### REMOVE PACKAGES ###${RST}" >&2
DEPENDS="ubiquity* timeshift* brltty* firefox* rhythmbox* onboard* yt-dlp* hypnotix* mint-backgrounds-wallpapers"
echo "Removing: ${DEPENDS}" >&2
sudo apt-get purge -y ${DEPENDS}
unset ${DEPENDS}
}

remove_icons () {
echo -e "${CYN}### REMOVE UNUSED ICONS ###${RST}" >&2
sudo rm -rf /usr/share/icons/{Mint-L*,Mint-X*,Papirus*,ePapirus*,Yaru*}
sudo rm -rf /usr/share/icons/Mint-Y-{Aqua,Cyan,Grey,Navy,Orange,Pink,Purple,Teal,Yaru}
sudo rm -rf /usr/share/icons/{Bibata-Original*,Bibata-Modern-Ice,Google*,XCursor*}
#echo "Remaining icons: $(ls /usr/share/icons)" >&2
}

remove_themes () {
echo -e "${CYN}### REMOVE UNUSED THEMES ###${RST}" >&2
sudo rm -rf /usr/share/themes/"Linux Mint"
sudo rm -rf /usr/share/themes/{Mint-L*,Mint-X*}
sudo rm -rf /usr/share/themes/{Mint-Y,Mint-Y-Dark}
sudo rm -rf /usr/share/themes/Mint-Y-{Aqua,Blue,Orange,Pink,Purple,Red,Sand,Teal}
sudo rm -rf /usr/share/themes/Mint-Y-Dark-{Aqua,Blue,Orange,Pink,Purple,Red,Sand,Teal}
#echo "Remaining themes: $(ls /usr/share/themes)" >&2
}

add_repositories () {
echo -e "${CYN}### ADD REPOSITORIES ###${RST}" >&2
# Source repos
echo "deb-src http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse" | sudo tee /etc/apt/sources.list.d/deb-src.list
echo "Added: deb-src.list" >&2
# Firefox ESR (Official)
sudo add-apt-repository -y ppa:mozillateam/ppa 2> /dev/null
echo "Added: ppa:mozillateam/ppa" >&2
# PiAware
sudo wget -q -O /etc/apt/sources.list.d/abcd567a.list https://abcd567a.github.io/ubuntu24/abcd567a.list 2> /dev/null
sudo wget -q -O /etc/apt/keyrings/abcd567a-key.gpg https://abcd567a.github.io/ubuntu24/KEY2.gpg 2> /dev/null
echo "Added: abcd567a.list" >&2
}

update_repos () {
echo -e "${CYN}### UPDATE REPOS ###${RST}" >&2
sudo apt-get update
}

upgrade_system () {
echo -e "${CYN}### UPGRADE SYSTEM ###${RST}" >&2
sudo apt-get upgrade -y >&2
}

install_hwe_kernel () {
echo -e "${CYN}### INSTALL HWE KERNEL ###${RST}" >&2
CURRENT_KERNELS=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort)
#echo "***" >&2
#echo -e "Current kernels:\n${CURRENT_KERNELS}" >&2
DEPENDS="linux-generic-hwe-24.04"
install_packages
unset ${DEPENDS}
NEW_KERNEL=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort | head -n 1)
#echo
#echo "Installed HWE kernel version ${NEW_KERNEL}..." >&2
CURRENT_KERNELS=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort)
#echo "***" >&2
#echo -e "Current kernels:\n${CURRENT_KERNELS}" >&2
}

remove_old_kernel () {
#echo "### REMOVE OLD KERNEL(S) ###" >&2
NUM_KERNELS=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort | wc -l)
if [[ ${NUM_KERNELS} > 1 ]]; then
	OLD_KERNEL=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort | tail -n 1)
#	echo "Removing kernel version ${OLD_KERNEL}..." >&2
	sudo apt-get purge -y linux-image-${OLD_KERNEL}-generic linux-headers-${OLD_KERNEL} linux-headers-${OLD_KERNEL}-generic linux-modules-${OLD_KERNEL}-generic linux-modules-extra-${OLD_KERNEL}-generic
fi
# Lazy do it again
NUM_KERNELS=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort | wc -l)
if [[ ${NUM_KERNELS} > 1 ]]; then
	OLD_KERNEL=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort | tail -n 1)
#	echo "Removing kernel version ${OLD_KERNEL}..." >&2
	sudo apt-get purge -y linux-image-${OLD_KERNEL}-generic linux-headers-${OLD_KERNEL} linux-headers-${OLD_KERNEL}-generic linux-modules-${OLD_KERNEL}-generic linux-modules-extra-${OLD_KERNEL}-generic
fi
CURRENT_KERNELS=$(dpkg -l linux-image-[0-9]* | grep "^ii" | awk -F " " '{print $2}' | awk -F "-" '{print $3 "-" $4}' | sort)
#echo "### INSTALLED  KERNEL(S) ###" >&2
echo -e "Installed kernel(s):\n${CURRENT_KERNELS}" >&2
}

install_firefox-esr () {
echo -e "${CYN}### INSTALL FIREFOX-ESR ###${RST}" >&2
DEPENDS="firefox-esr"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
sudo sed -i 's/Icon=firefox-esr/Icon=web-browser/' /usr/share/applications/firefox-esr.desktop
firefox-esr --version >&2
}

arcos_files () {
echo -e "${CYN}### COPY ARCOS FILES ###${RST}" >&2
MODULES=${SETUP_DIR}/arcos-linux-modules
BACKGROUNDS=${SETUP_DIR}/opt/arcOS/backgrounds
BIN=${SETUP_DIR}/opt/arcOS/bin
CONFIGS=${SETUP_DIR}/opt/arcOS/configs
IMAGES=${SETUP_DIR}/opt/arcOS/images
CHGLOG=${SETUP_DIR}/CHANGELOG
MANUAL=${SETUP_DIR}/opt/arcOS/arcos-linux-modules/CORE/MANUAL/arcOS-Field-Manual.html
sudo mkdir -p ${ARCOS_DIR}/{arcos-linux-modules,backgrounds,bin,configs,images}
sudo cp -r ${MODULES} ${ARCOS_DIR}/
sudo cp -r ${BACKGROUNDS} ${ARCOS_DIR}/
sudo cp -r ${BIN} ${ARCOS_DIR}/
sudo cp -r ${CONFIGS} ${ARCOS_DIR}/
sudo cp -r ${IMAGES} ${ARCOS_DIR}/
sudo cp ${CHGLOG} ${ARCOS_DIR}/
sudo cp ${MANUAL} ${ARCOS_DIR}/

APPLICATIONS=${SETUP_DIR}/etc/skel/local/share/applications
ICONS=${SETUP_DIR}/etc/skel/local/share/icons
sudo mkdir -p /etc/skel/.local/share/{applications,icons}
sudo cp -r ${APPLICATIONS} /etc/skel/.local/share/
sudo cp -r ${ICONS} /etc/skel/.local/share/

MENU=${SETUP_DIR}/etc/skel/config/menus/cinnamon-applications.menu
sudo mkdir -p /etc/skel/.config/menus
sudo cp ${MENU} /etc/skel/.config/menus/

MENU_DIRS=${SETUP_DIR}/etc/skel/local/share/desktop-directories
sudo mkdir -p /etc/skel/.local/share/desktop-directories
sudo cp -r ${MENU_DIRS} /etc/skel/.local/share/
}

arcos_packages () {
echo -e "${CYN}### INSTALL ARCOS PACKAGES ###${RST}" >&2
DEPENDS="audacity bindfs build-essential cmake conky-std cowsay espeak festival ffmpeg figlet fonts-font-awesome fortune gimp git gstreamer1.0-plugins-ugly hexchat imagemagick inotify-tools jq markdown openssh-server pipx python3-pip qrencode ruby shc shotcut simplescreenrecorder virt-viewer vlc x11vnc yad zbar-tools zsh"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
# Install localsend
echo "Installing: localsend" >&2
sudo dpkg -i ${SETUP_DIR}/cache/LocalSend-1.17.0-linux-x86-64.deb
}

compile_sensitive_files () {
echo -e "${CYN}### COMPILE SENSITIVE FILES ###${RST}" >&2
sudo shc -r -f ${ARCOS_DIR}/bin/arcos_validate
sudo rm ${ARCOS_DIR}/bin/arcos_validate.x.c
sudo rm ${ARCOS_DIR}/bin/arcos_validate
sudo mv ${ARCOS_DIR}/bin/arcos_validate.x ${ARCOS_DIR}/bin/arcos_validate
echo "arcos_validate" >&2

#sudo shc -r -f ${ARCOS_DIR}/bin/persistent-storage
#sudo rm ${ARCOS_DIR}/bin/persistent-storage.x.c
#sudo rm ${ARCOS_DIR}/bin/persistent-storage
#sudo mv ${ARCOS_DIR}/bin/persistent-storage.x ${ARCOS_DIR}/bin/persistent-storage
#echo "persistent-storage" >&2
}

install_security_tools () {
echo -e "${CYN}### INSTALL SECURITY TOOLS ###${RST}" >&2
# veracrypt requires pcscd
DEPENDS="caja-seahorse kleopatra nemo-seahorse pcscd scdaemon"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
#sudo dpkg -i ${SETUP_DIR}/cache/veracrypt-1.26.20-Ubuntu-24.04-amd64.deb
sudo dpkg -i ${SETUP_DIR}/cache/veracrypt-1.26.24-Ubuntu-24.04-amd64.deb
}

install_viking () {
echo -e "${CYN}### INSTALL VIKING ###${RST}" >&2
DEPENDS="viking"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
}

remove_pipewire () {
echo -e "${CYN}### REMOVE PIPEWIRE ###${RST}" >&2
DEPENDS="pipewire pipewire-bin"
echo "Removing: ${DEPENDS}" >&2
sudo apt-get purge -y ${DEPENDS}
unset ${DEPENDS}
}

setup_digirig () {
echo -e "${CYN}### CONFIGURE DIGIRIG ###${RST}" >&2
sudo cp ${SETUP_DIR}/lib/udev/rules.d/99-digirig.rules /lib/udev/rules.d/
sudo cp ${SETUP_DIR}/lib/udev/rules.d/99-pulseaudio-usb.rules /lib/udev/rules.d/
sudo cp ${SETUP_DIR}/etc/asound.conf /etc/
sudo sed -i 's/^options snd-usb-audio.*$/options snd-usb-audio index=5/g' /etc/modprobe.d/alsa-base.conf
}

install_gpsd () {
echo -e "${CYN}### INSTALL GPSD ###${RST}" >&2
DEPENDS="gpsd gpsd-clients chrony"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
gpsd --version >&2

sudo cp ${SETUP_DIR}/etc/default/gpsd /etc/default/
sudo cp ${SETUP_DIR}/etc/chrony/chrony.conf /etc/chrony/chrony.conf
sudo cp ${SETUP_DIR}/lib/udev/rules.d/60-gpsd.rules /lib/udev/rules.d/
sudo cp -r ${SETUP_DIR}/cache/gems /var/lib/
sudo echo "@reboot root for i in 1 2 3 4; do /usr/bin/ruby /opt/arcOS/bin/gps2file.rb && sleep 5; done" > /etc/crontab
sudo echo "@reboot root for i in 1 2 3 4; do /opt/arcOS/bin/check-gps-clock && sleep 10; done" >> /etc/crontab
sudo echo "* * * * * root /opt/arcOS/bin/check-gps-clock" >> /etc/crontab
sudo echo "* * * * * root /usr/bin/ruby /opt/arcOS/bin/gps2file.rb" >> /etc/crontab
}

install_hamlib () {
echo -e "${CYN}### INSTALL HAMLIB ###${RST}" >&2
DEPENDS="libhamlib4t64"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
dpkg -s libhamlib4t64 | grep "Version:" >&2
}

install_ardopcf () {
echo -e "${CYN}### INSTALL ARDOPCF ###${RST}" >&2
sudo cp ${SETUP_DIR}/cache/ardopcf /usr/bin/ardopcf
ardopcf --help | grep "Version" >&2
}

install_direwolf () {
echo -e "${CYN}### INSTALL DIREWOLF ###${RST}" >&2
DEPENDS="direwolf"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
sudo mkdir -p /etc/skel/.config
sudo cp ${SETUP_DIR}/opt/arcOS/configs/direwolf/direwolf.conf /etc/skel/.config/
direwolf -t 0 -u | head -n 2 >&2
}

install_pat () {
echo -e "${CYN}### INSTALL PAT ###${RST}" >&2
echo "Installing: pat" >&2
#sudo dpkg -i ${SETUP_DIR}/cache/pat_0.16.0_linux_amd64.deb
sudo dpkg -i ${SETUP_DIR}/cache/pat_0.19.1_linux_amd64.deb
sudo mkdir -p /etc/skel/.config/pat
sudo cp ${SETUP_DIR}/opt/arcOS/configs/pat/config.json /etc/skel/.config/pat/
sudo mkdir -p /etc/skel/.local/share/pat
# Setup for root during install to allow for generating rmslist and getting forms in place
sudo mkdir -p /root/.config/pat
sudo cp ${SETUP_DIR}/opt/arcOS/configs/pat/config.json /root/.config/pat/
sed -i "s/XXXCALLSIGNXXX/N0CALL/g" /root/.config/pat/config.json
if [ "${LOCAL_PKGS}" != "local" ]; then
	pat templates update
	sudo cp -r /root/.local/share/pat/Standard_Forms /etc/skel/.local/share/pat/
	pat rmslist
	sudo cp /root/.local/share/pat/rmslist.json /etc/skel/.local/share/pat/
else
	scp -i ${SSH_KEY} -r ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/misc/pat/* /etc/skel/.local/share/pat/
fi
# Setup webapp
sudo mkdir -p /etc/skel/.local/share/ice/firefox
sudo cp -r ${SETUP_DIR}/etc/skel/local/share/ice/firefox/WinlinkClient0335 /etc/skel/.local/share/ice/firefox/
pat version >&2
}

build_fldigi () {
echo -e "${YEL}Building fldigi from source...(in background)${RST}" >&2
cd ${SETUP_DIR}/cache/fldigi-4.1.20
./configure
make > /dev/null 2>&1
sudo make install
cd ${SETUP_DIR}
touch /root/fldigi-complete
}

install_fl_suite () {
echo -e "${CYN}### INSTALL FL-SUITE ###${RST}" >&2
DEPENDS="libsndfile1-dev"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset $DEPENDS
if [ "${LOCAL_PKGS}" == "local" ]; then
	echo "Installing: build dependencies for fldigi" >&2
	sudo apt-get -y build-dep fldigi
else
	echo "Installing: build dependencies for fldigi" >&2
	sudo apt-get -y build-dep --download-only fldigi
	sudo apt-get -y build-dep fldigi
fi

build_fldigi &

#DEPENDS="fldigi flamp flmsg flrig"
DEPENDS="flamp flmsg flrig"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
echo "flamp $(flamp --version)" >&2
echo "flmsg $(flmsg --version)" >&2
echo "flrig $(flrig --version)" >&2
}

install_yaac () {
echo -e "${CYN}### INSTALL YAAC ###${RST}" >&2
DEPENDS="openjdk-11-jre libjssc-java"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset $DEPENDS
sudo mkdir -p /etc/skel/.yaac
#sudo unzip -d /etc/skel/.yaac ${SETUP_DIR}/cache/YAAC_1.0-beta209.zip
sudo unzip -d /etc/skel/.yaac ${SETUP_DIR}/cache/YAAC_1.0-beta216.zip
sudo mkdir -p /etc/skel/.java/.userPrefs/org/ka2ddo/yaac
sudo cp -a ${SETUP_DIR}/opt/arcOS/configs/yaac/Profiles /etc/skel/.java/.userPrefs/org/ka2ddo/yaac/
echo "YAAC_1.0-beta209" >&2
}

install_js8call () {
echo -e "${CYN}### INSTALL JS8CALL ###${RST}" >&2
DEPENDS="libqt5multimedia5 libqt5multimediagsttools5 libqt5multimediawidgets5 libqt5multimedia5-plugins libqt5printsupport5t64 libqt5serialport5"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
sudo dpkg -i ${SETUP_DIR}/cache/js8call_2.2.0_20.04_amd64.deb
echo "js8call_2.2.0_20.04_amd64.deb" >&2
}

install_wsjtx () {
echo -e "${CYN}### INSTALL WSJTX ###${RST}" >&2
DEPENDS="libboost-filesystem1.74.0 libboost-log1.74.0 libboost-regex1.74.0 libboost-thread1.74.0 libqt5multimedia5 libqt5multimediagsttools5 libqt5multimediawidgets5 libqt5multimedia5-plugins libqt5printsupport5t64 libqt5serialport5 libqt5sql5t64 libqt5sql5-sqlite"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
sudo dpkg -i ${SETUP_DIR}/cache/wsjtx_2.7.0_amd64.deb
echo "wsjtx_2.7.0_amd64.deb" >&2
}

install_qsstv () {
echo -e "${CYN}### INSTALL QSSTV ###${RST}" >&2
DEPENDS="qsstv"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
sudo mkdir -p /etc/skel/.config/ON4QZ
sudo cp ${SETUP_DIR}/opt/arcOS/configs/qsstv/qsstv_9.0.conf /etc/skel/.config/ON4QZ/qsstv_9.0.conf
dpkg -s qsstv | grep "Version:" >&2
}

install_paracon () {
echo -e "${CYN}### INSTALL PARACON ###${RST}" >&2
echo "Installing: paracon" >&2
sudo cp ${SETUP_DIR}/cache/paracon_1.2.0.pyz /usr/local/bin/
python3 /usr/local/bin/paracon_1.2.0.pyz --version >&2
}

install_gpredict () {
echo -e "${CYN}### INSTALL GPREDICT ###${RST}" >&2
DEPENDS="gpredict"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
dpkg -s gpredict | grep "Version:" >&2
}

install_rtlsdr () {
# Trying a little humor here
echo -e "${CYN}### INSTALL SDR ###${RST}" >&2
DEPENDS="rtl-sdr"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
DEPENDS="gqrx-sdr"
echo -e "${WHT}Hey, I've got a joke for you!${RST}" >&2
sleep 2
echo -e "${WHT}Wanna hear it?${RST}" >&2
sleep 2
echo -e "${WHT}Hang on, let me get this thing started...${RST}" >&2
sleep 1
echo "Installing: ${DEPENDS}" >&2
echo -e "${WHT}OK, ready?!${RST}" >&2
sleep 2
echo -e -n "${WHT}Knock, knock...${RST}" >&2
sleep 2
echo -e "${WHT}Who's there?...${RST}" >&2
sleep 3
echo -e -n "${WHT}/usr/bin/dpkg...${RST}" >&2
sleep 5
echo -e "${WHT}/usr/bin/dpkg WHO?!${RST}" >&2
install_packages
unset ${DEPENDS}
# xtrx-dkms removed to workaround something eerily similar to https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1012616
sudo dpkg --refuse-configure-any --purge xtrx-dkms
echo -e "${RED}^^^ Who said it was a good joke?! ;-) ^^^${RST}" >&2
echo "rtl-sdr: $(dpkg -s rtl-sdr | grep Version)" >&2
echo "gqrx-sdr: $(dpkg -s gqrx-sdr | grep Version)" >&2
}

install_piaware () {
echo -e "${CYN}### INSTALL PIAWARE ###${RST}" >&2
echo "Github: abcd567a" >&2
DEPENDS="piaware dump1090-fa piaware-web"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
sudo cp ${SETUP_DIR}/etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf
sudo cp ${SETUP_DIR}/etc/lighttpd/conf-available/89-skyaware.conf /etc/lighttpd/conf-available/89-skyaware.conf
sudo cp ${SETUP_DIR}/usr/share/skyaware/html/config.js /usr/share/skyaware/html/
sudo cp ${SETUP_DIR}/usr/share/skyaware/html/planeObject.js /usr/share/skyaware/html/
sudo cp ${SETUP_DIR}/usr/share/skyaware/html/style.css /usr/share/skyaware/html/
sudo cp ${SETUP_DIR}/usr/share/skyaware/html/layers.js /usr/share/skyaware/html/

# Setup webapp
sudo mkdir -p /etc/skel/.local/share/ice/firefox
sudo cp -r ${SETUP_DIR}/etc/skel/local/share/ice/firefox/ADSB2388 /etc/skel/.local/share/ice/firefox/
}

install_qemu () {
echo -e "${CYN}### INSTALL QEMU ###${RST}" >&2
sudo apt-get install -y qemu-system-x86
qemu-system-x86_64 --version >&2
}

install_wine () {
echo -e "${CYN}### INSTALL WINE ###${RST}" >&2
DEPENDS="wine-installer winetricks"
echo "Installing: ${DEPENDS}" >&2
install_packages
unset ${DEPENDS}
wine-stable --version >&2
/usr/bin/winetricks --version >&2
}

arcos_customization () {
echo -e "${CYN}### ARCOS CUSTOMIZATION ###${RST}" >&2
# arcOS Branding
#sudo sed -i "/\$distro = 'Arco Linux'/d" /usr/bin/inxi
#sudo sed -i '/$distro .= " $version_name"/d' /usr/bin/inxi
sudo sed -i 's/$dist_osr .= " $version_name";/$dist_osr = "$version_name";/' /usr/bin/inxi
sudo rm /etc/linuxmint/info
sudo cp ${SETUP_DIR}/etc/issue /etc/issue
sudo sed -i "s/XXXCODENAMEXXX/${CODENAME}/" /etc/issue
sudo sed -i "s/XXXRELEASEXXX/${RELEASE}/" /etc/issue
sudo cp ${SETUP_DIR}/usr/lib/os-release /usr/lib/os-release
sudo sed -i "s/XXXCODENAMEXXX/${CODENAME}/" /usr/lib/os-release
sudo sed -i "s/XXXRELEASEXXX/${RELEASE}/" /usr/lib/os-release

# Eliminate prompt to press Enter on shutdown
sudo cp ${SETUP_DIR}/sbin/casper-stop /sbin/casper-stop

# Default user groups
sudo cp ${SETUP_DIR}/usr/share/initramfs-tools/scripts/casper-bottom/25adduser /usr/share/initramfs-tools/scripts/casper-bottom/25adduser

# Default home directories
sudo cp ${SETUP_DIR}/etc/xdg/user-dirs.defaults /etc/xdg/

# Profile level customization
sudo cp ${SETUP_DIR}/etc/profile.d/arcos-customization.sh /etc/profile.d/

# Map the system "help" button to the local field manual
sudo sed -i 's|http://www.linuxmint.com/documentation.php|file:///opt/arcOS/arcOS-Field-Manual.html|g' /usr/local/bin/gnome-help

# Set the default background image
WALLPAPER="${ARCOS_DIR}/backgrounds/releases/${CODENAME}-3840x2160.jpg"
sudo rm /usr/share/backgrounds/linuxmint/*.{jpg,png}
sudo rm -rf /usr/share/backgrounds/linuxmint-*
sudo cp ${WALLPAPER} /usr/share/backgrounds/linuxmint/default_background.jpg
sudo chmod 644 /usr/share/backgrounds/linuxmint/default_background.jpg
sudo rm -rf /usr/share/cinnamon-background-properties/*.xml
sudo cp ${SETUP_DIR}/usr/share/cinnamon-background-properties/System.xml /usr/share/cinnamon-background-properties/System.xml

# Panel transparency
sudo mkdir -p /etc/skel/.local/share/cinnamon/extensions
sudo cp -r ${SETUP_DIR}/etc/skel/local/share/cinnamon/extensions/transparent-panels@germanfr /etc/skel/.local/share/cinnamon/extensions/
sudo mkdir -p /etc/skel/.config/cinnamon/spices/transparent-panels@germanfr
sudo cp ${SETUP_DIR}/etc/skel/config/cinnamon/spices/transparent-panels@germanfr/transparent-panels@germanfr.json /etc/skel/.config/cinnamon/spices/transparent-panels@germanfr/

# Customize menu icon and hide Logout button
sudo cp ${SETUP_DIR}/usr/share/cinnamon/applets/menu@cinnamon.org/settings-override.json /usr/share/cinnamon/applets/menu@cinnamon.org/settings-override.json
sudo cp ${SETUP_DIR}/usr/share/cinnamon/applets/menu@cinnamon.org/applet.js /usr/share/cinnamon/applets/menu@cinnamon.org/applet.js

# Default pinned apps
sudo cp ${SETUP_DIR}/usr/share/cinnamon/applets/grouped-window-list@cinnamon.org/settings-override.json /usr/share/cinnamon/applets/grouped-window-list@cinnamon.org/settings-override.json

# Customize clock
sudo cp ${SETUP_DIR}/usr/share/cinnamon/applets/calendar@cinnamon.org/settings-override.json /usr/share/cinnamon/applets/calendar@cinnamon.org/settings-override.json

# Customize workspace switcher
sudo cp ${SETUP_DIR}/usr/share/cinnamon/applets/workspace-switcher@cinnamon.org/settings-override.json /usr/share/cinnamon/applets/workspace-switcher@cinnamon.org/settings-override.json

# Setup the login screen
sudo cp ${SETUP_DIR}/etc/lightdm/slick-greeter.conf /etc/lightdm/
sudo cp ${SETUP_DIR}/etc/lightdm/lightdm.conf /etc/lightdm/

# Set custom bootsplash image
sudo cp -r ${SETUP_DIR}/usr/share/plymouth/themes/arcos-bootsplash /usr/share/plymouth/themes/
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/arcos-bootsplash/arcos-bootsplash.plymouth 800
sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/arcos-bootsplash/arcos-bootsplash.plymouth
sudo update-initramfs -uk all

# Quiet console messages
sudo cp ${SETUP_DIR}/etc/sysctl.d/10-console-messages.conf /etc/sysctl.d/

# Disable CTL+ALT+BKSP
sudo cp ${SETUP_DIR}/etc/X11/xorg.conf.d/99-dontzap.conf /etc/X11/xorg.conf.d/

# Disable logout/suspend/hibernate
sudo systemctl mask sleep.target hibernate.target suspend.target hybrid-sleep.target

# Create autostart directory
sudo mkdir -p /etc/skel/.config/autostart

# Conky config and autostart
sudo cp ${SETUP_DIR}/etc/skel/conkyrc /etc/skel/.conkyrc
sudo cp ${SETUP_DIR}/etc/skel/config/autostart/conky.desktop /etc/skel/.config/autostart/

# Check station config autostart
sudo cp ${SETUP_DIR}/etc/skel/config/autostart/check-station-config.desktop /etc/skel/.config/autostart/

# Install x11vnc service file
sudo cp ${SETUP_DIR}/lib/systemd/system/x11vnc.service /lib/systemd/system/x11vnc.service

# Custom login/logout sounds
sudo cp ${SETUP_DIR}/usr/share/sounds/{hi,73}.ogg /usr/share/sounds/

# Add bashrc
sudo cp ${SETUP_DIR}/etc/skel/bashrc /etc/skel/.bashrc

# Add zshrc
sudo cp ${SETUP_DIR}/etc/skel/zshrc /etc/skel/.zshrc

# Add gray sticky color
#sudo cp ${SETUP_DIR}/cache/sticky/sticky.py /usr/lib/sticky/
#sudo cp ${SETUP_DIR}/cache/sticky/sticky.css /usr/share/sticky/

# Configure bindfs
sudo cp ${SETUP_DIR}/etc/fuse.conf /etc/fuse.conf

# Default simplescreenrecorder config
sudo cp -r ${SETUP_DIR}/etc/skel/ssr /etc/skel/.ssr

# mint-iso-verify compatibility
sudo cp ${SETUP_DIR}/usr/lib/mintstick/verify.py /usr/lib/mintstick/verify.py

# Allow locking live session
sudo cp ${SETUP_DIR}/usr/share/cinnamon-screensaver/util/utils.py /usr/share/cinnamon-screensaver/util/utils.py

# Disable password auth adn enable key auth for ssh
sudo cp ${SETUP_DIR}/etc/sshd/sshd_config.d/sshd_custom.conf /etc/ssh/sshd_config.d/sshd_custom.conf
}

disable_wayland () {
echo -e "${CYN}### DISABLE WAYLAND ###${RST}" >&2
sudo mv /usr/share/xsessions/cinnamon.desktop /usr/share/xsessions/cinnamon.desktop.disabled
sudo mv /usr/share/wayland-sessions/cinnamon-wayland.desktop /usr/share/wayland-sessions/cinnamon-wayland.desktop.disabled
sudo cp ${SETUP_DIR}/etc/lightdm/lightdm.conf.d/70-linuxmint.conf /etc/lightdm/lightdm.conf.d/70-linuxmint.conf
}

update_package_archive () {
if [ "${LOCAL_PKGS}" != "local" ]; then
	echo -e "${CYN}### UPDATE PACKAGE ARCHIVE ###${RST}" >&2
	echo -n "Copying packages to local-packages..." >&2
	sudo rm /var/lib/apt/lists/lock
	scp -i ${SSH_KEY} -q -r /var/cache/apt/* ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/cache/ >&2
	scp -i ${SSH_KEY} -q -r /etc/apt/keyrings/* ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/keyrings/  >&2
	scp -i ${SSH_KEY} -q -r /var/lib/apt/lists/* ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/lists/  >&2
	scp -i ${SSH_KEY} -q -r /root/.local/share/pat/{Standard_Forms,rmslist.json} ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/misc/pat/ >&2
	scp -i ${SSH_KEY} -q -r /etc/apt/sources.list.d/* ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/sources/ >&2
	scp -i ${SSH_KEY} -q -r /etc/apt/trusted.gpg.d/* ${BUILD_USER}@${BUILD_HOST}:${BUILD_DIR}/local-packages/trusted/ >&2	
	echo -e "${GRN}DONE${RST}" >&2
fi
}

wait_fldigi () {
echo -e "${CYN}### WAITING FOR FLDIGI BUILD TO COMPLETE... ###${RST}" >&2
while [ ! -f /root/fldigi-complete ]; do
	sleep 1
done
if [ -f /root/fldigi-complete ]; then
	echo "$(fldigi --version | head -n 1)" >&2
	sudo rm /root/fldigi-complete
fi
}

cleanup () {
echo -e "${CYN}### CLEANUP ###${RST}" >&2
ssh -i ${SSH_KEY} ${BUILD_USER}@${BUILD_HOST} "rm $HOME/.ssh/authorized_build_keys"
sudo rm /etc/apt/sources.list.d/deb-src.list
sudo rm /etc/apt/sources.list.d/mozillateam-ppa-noble.list
sudo rm /etc/apt/sources.list.d/abcd567a.list
sudo rm /etc/apt/keyrings/mozillateam-ppa-noble.gpg
sudo rm /etc/apt/keyrings/abcd567a-key.gpg
sudo apt-get autoremove -y
sudo rm -rf /root/arcos-build
sudo rm -rf /root/.ssh
sudo rm -rf /root/.config/pat
sudo rm -rf /root/.local/share/pat
sudo rm -rf /root/.local/state/pat
sudo rm -rf /root/.local/share/gem
sudo rm -rf /root/.wget-hsts
sudo apt-get clean
history -c
}

arcos_iso_setup > /dev/null
