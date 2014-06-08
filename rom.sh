#!/bin/bash

# We don't allow scrollback buffer
echo -e '\0033\0143'
clear

DATE=$(date +%D)
MACHINE_TYPE=`uname -m`
CM_VERSION=11.0

# Get current path
DIR="$(cd `dirname $0`; pwd)"
OUT="$(readlink $DIR/out)"
[ -z "${OUT}" ] && OUT="${DIR}/out"

# Prepare output customization commands
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

# Local defaults, can be overriden by environment
: ${PREFS_FROM_SOURCE:="false"}
: ${THREADS:="$(cat /proc/cpuinfo | grep "^processor" | wc -l)"}

# Import command line parameters
DEVICE="$1"
EXTRAS="$2"

# If there is no extra parameter, reduce parameters index by 1
if [ "$EXTRAS" == "true" ] || [ "$EXTRAS" == "false" ]; then
        SYNC="$2"
        UPLOAD="$3"
else
        SYNC="$3"
        UPLOAD="$4"
fi

echo -e "${txtblu} #####################################################################"
echo -e "${txtblu} \r\n"                                                   
echo -e "${txtblu}                CCCCCCCCCCCCC MMMMMMMM               MMMMMMMM "
echo -e "${txtblu}             CCC::::::::::::C M:::::::M             M:::::::M "
echo -e "${txtblu}           CC:::::::::::::::C M::::::::M           M::::::::M "
echo -e "${txtblu}          C:::::CCCCCCCC::::C M:::::::::M         M:::::::::M "
echo -e "${txtblu}         C:::::C       CCCCCC M::::::::::M       M::::::::::M "
echo -e "${txtblu}        C:::::C               M:::::::::::M     M:::::::::::M "
echo -e "${txtblu}        C:::::C               M:::::::M::::M   M::::M:::::::M "
echo -e "${txtblu}        C:::::C               M::::::M M::::M M::::M M::::::M "
echo -e "${txtblu}        C:::::C               M::::::M  M::::M::::M  M::::::M "
echo -e "${txtblu}        C:::::C               M::::::M   M:::::::M   M::::::M "
echo -e "${txtblu}        C:::::C               M::::::M    M:::::M    M::::::M "
echo -e "${txtblu}         C:::::C       CCCCCC M::::::M     MMMMM     M::::::M "
echo -e "${txtblu}          C:::::CCCCCCCC::::C M::::::M               M::::::M "
echo -e "${txtblu}           CC:::::::::::::::C M::::::M               M::::::M "
echo -e "${txtblu}             CCC::::::::::::C M::::::M               M::::::M "
echo -e "${txtblu}                CCCCCCCCCCCCC MMMMMMMM               MMMMMMMM "
echo -e "${txtblu} \r\n"
echo -e "${txtblu}                     CyanogenMod ${CM_VERSION} buildscript"
echo -e "${txtblu}                visit us @ http://www.cyanogenmod.org"
echo -e "${txtblu} \r\n"
echo -e "${txtblu} #####################################################################"
echo -e "\r\n ${txtrst}"

# Get start time
res1=$(date +%s.%N)

echo -e "${bldgrn}Start time: $(date) ${txtrst}"

# Decide what command to execute
case "$EXTRAS" in
        threads)
                echo -e "${bldblu}Please enter desired building/syncing threads number followed by [ENTER]${txtrst}"
                read threads
                THREADS=$threads
        ;;
        clean|cclean)
                echo -e "${bldblu}Cleaning intermediates and output files${txtrst}"
                export CLEAN_BUILD="true"
                [ -d "${DIR}/out" ] && rm -Rf ${DIR}/out/*
        ;;
esac

echo -e ""

export DEVICE=$DEVICE

# Setup environment
echo -e ""
echo -e "${bldblu}Setting up environment${txtrst}"
. build/envsetup.sh
echo -e ""

# lunch/brunch device
echo -e "${bldblu}Lunching device [$DEVICE] ${cya}(Includes dependencies sync)${txtrst}"
export PREFS_FROM_SOURCE
lunch "cm_$DEVICE-userdebug";
echo -e "${bldblu}Starting compilation${txtrst}"
mka bacon
echo -e ""

# Get elapsed time
res2=$(date +%s.%N)
echo -e "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds)${txtrst}"
