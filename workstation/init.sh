#!/bin/bash

ETC_PROFILE="/etc/profile"

set +e && chmod 555 $ETC_PROFILE && source $ETC_PROFILE &>/dev/null && set -e

INFRA_BRANCH=$1
SKIP_UPDATE=$2
START_TIME_INIT=$3
DEBUG_MODE=$4

[ ! -z "$SUDO_USER" ] && KIRA_USER=$SUDO_USER
[ -z "$KIRA_USER" ] && KIRA_USER=$USER
[ -z "$INFRA_BRANCH" ] && INFRA_BRANCH="master"

KIRA_DUMP="/home/$KIRA_USER/DUMP"
KIRA_SECRETS="/home/$KIRA_USER/.secrets"
SETUP_LOG="$KIRA_DUMP/setup.log"

CDHELPER_VERSION="v0.6.15"
SETUP_VER="v0.0.5" # Used To Initialize Essential, Needs to be iterated if essentials must be updated
INFRA_REPO="https://github.com/KiraCore/kira"

echo "------------------------------------------------"
echo "| STARTED: INIT $SETUP_VER"
echo "|-----------------------------------------------"
echo "|  SKIP UPDATE: $SKIP_UPDATE"
echo "|   START TIME: $START_TIME_INIT"
echo "|   DEBUG MODE: $DEBUG_MODE"
echo "| INFRA BRANCH: $INFRA_BRANCH"
echo "|   INFRA REPO: $INFRA_REPO"
echo "|    KIRA USER: $SUDO_USER"
echo "------------------------------------------------"

rm -rfv $KIRA_DUMP
mkdir -p "$KIRA_DUMP"

set +x
if [ -z "$SKIP_UPDATE" ]; then
    echo -e "\e[35;1mMMMMMMMMMWX0kdloxOKNWMMMMMMMMMMMMMMMMMMMMMMMMMMM"
    echo "MMMMMWNKOxlc::::::cok0XWWMMMMMMMMMMMMMMMMMMMMMMM"
    echo "MMWX0kdlc::::::::::::clxkOKNMMMMMMMMMMWKkk0NWMMM"
    echo "MNkoc:::::::::::::::::::::cok0NWMMMMMMWKxlcld0NM"
    echo "W0l:cllc:::::::::::::::::::::coKWMMMMMMMWKo:;:xN"
    echo "WOlcxXNKOdlc::::::::::::::::::l0WMMMMMWNKxc;;;oX"
    echo "W0olOWMMMWX0koc::::::::::::ldOXWMMMWXOxl:;;;;;oX"
    echo "MWXKNMMMMMMMWNKOdl::::codk0NWMMWNKkdc:;;;;;;;;oX"
    echo "MMMMMMMMMMMMMMMMWX0kkOKNWMMMWX0xl:;;;;;;;;;;;;oX"
    echo "MMMMMMMMMWXOkOKNMMMMMMMMMMMW0l:;;;;;;;;;;;;;;;oX"
    echo "MMMMMMMMMXo:::cox0XWMMMMMMMNx:;;;;;;;;;;;;;;;;oX"
    echo "MMMMMMMMMKl:::::::ldOXWMMMMNx:;;;;;;;;;;;;;;co0W"
    echo "MMMMMMMMMKl::::;;;;;:ckWMMMNx:;;;;;;;;;;:ldOKNMM"
    echo "MMMMMMMMMKl;;;;;;;;;;;dXMMMNx:;;;;;;;:ox0XWMMMMM"
    echo "MMMMMMMMMKl;;;;;;;;;;;dXMMMWk:;;;:cdkKNMMMMMMMMM"
    echo "MMMMMMMMMKl;;;;;;;;;;;dXMMMMXkoox0XWMMMMMMMMMMMM"
    echo "MMMMMMMMMKl;;;;;;;;;;;dXMMMMMWWWMMMMMMMMMMMMMMMM"
    echo "MMMMMMMMMKl;;;;;;;;;;;dXMMMMMMMMMMMMMMMMMMMMMMMM"
    echo "MMMMMMMMMKo;;;;;;;;;;;dXMMMMMMMMMMMMMMMMMMMMMMMM"
    echo "MMMMMMMMMWKxl:;;;;;;;;oXMMMWNWMMMMMMMMMMMMMMMMMM"
    echo "MMMMMMMMMMMWNKkdc;;;;;:dOOkdlkNMMMMMMMMMMMMMMMMM"
    echo "MMMMMMMMMMMMMMMWXOxl:;;;;;cokKWMMMMMMMMMMMMMMMMM"
    echo "MMMMMMMMMMMMMMMMMMWN0kdxxOKWMMMMMMMMMMMMMMMMMMMM"
    echo "M         KIRA NETWORK SETUP $SETUP_VER"
    echo -e "MMMMMMMMMMMMMMMMMMMMMMWWMMMMMMMMMMMMMMMMMMMMMMMM\e[0m\c\n"
    sleep 3
else
    echo "INFO: Initalizing setup script..."
fi

echo ""
set -x

[ -z "$START_TIME_INIT" ] && START_TIME_INIT="$(date -u +%s)"
[ -z "$SKIP_UPDATE" ] && SKIP_UPDATE="False"
[ -z "$DEBUG_MODE" ] && DEBUG_MODE="False"
[ -z "$SILENT_MODE" ] && SILENT_MODE="False"

[ -z "$SEKAI_BRANCH" ] && SEKAI_BRANCH="master"
[ -z "$FRONTEND_BRANCH" ] && FRONTEND_BRANCH="master"
[ -z "$INTERX_BRANCH" ] && INTERX_BRANCH="master"

[ -z "$SEKAI_REPO" ] && SEKAI_REPO="https://github.com/KiraCore/sekai"
[ -z "$FRONTEND_REPO" ] && FRONTEND_REPO="https://github.com/KiraCore/kira-frontend"
[ -z "$INTERX_REPO" ] && INTERX_REPO="https://github.com/KiraCore/sekai"

[ "$KIRA_USER" == "root" ] && KIRA_USER=$(logname)
if [ "$KIRA_USER" == "root" ]; then
    echo "ERROR: You must login as non root user to your machine!"
    exit 1
fi

if [ "$SKIP_UPDATE" == "False" ]; then
    #########################################
    # START Installing Essentials
    #########################################
    KIRA_REPOS=/kira/repos

    KIRA_INFRA="$KIRA_REPOS/kira"
    KIRA_SEKAI="$KIRA_REPOS/sekai"
    KIRA_FRONTEND="$KIRA_REPOS/frontend"
    KIRA_INTERX="$KIRA_REPOS/interx"

    KIRA_SETUP=/kira/setup
    KIRA_MANAGER="/kira/manager"

    KIRA_SCRIPTS="${KIRA_INFRA}/common/scripts"
    KIRA_WORKSTATION="${KIRA_INFRA}/workstation"

    SEKAID_HOME="/root/.simapp"

    mkdir -p $KIRA_INFRA
    mkdir -p $KIRA_SEKAI
    mkdir -p $KIRA_FRONTEND
    mkdir -p $KIRA_INTERX

    mkdir -p $KIRA_SETUP
    mkdir -p $KIRA_MANAGER
    rm -rfv $KIRA_DUMP
    mkdir -p "$KIRA_DUMP/INFRA/manager"

    ESSENTIALS_HASH=$(echo "$SETUP_VER-$CDHELPER_VERSION-$KIRA_USER-$INFRA_BRANCH-$INFRA_REPO" | md5sum | awk '{ print $1 }' || echo "")
    KIRA_SETUP_ESSSENTIALS="$KIRA_SETUP/essentials-$ESSENTIALS_HASH"
    if [ ! -f "$KIRA_SETUP_ESSSENTIALS" ]; then
        echo "INFO: Installing Essential Packages & Env Variables..."
        apt-get update -y
        apt-get install -y --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages \
            software-properties-common apt-transport-https ca-certificates gnupg curl wget git unzip build-essential \
            nghttp2 libnghttp2-dev libssl-dev fakeroot dpkg-dev libcurl4-openssl-dev

        ln -s /usr/bin/git /bin/git || echo "WARNING: Git symlink already exists"
        git config --add --global core.autocrlf input || echo "WARNING: Failed to set global autocrlf"
        git config --unset --global core.filemode || echo "WARNING: Failed to unset global filemode"
        git config --add --global core.filemode false || echo "WARNING: Failed to set global filemode"
        git config --add --global pager.branch false || echo "WARNING: Failed to disable branch pager"
        git config --add --global http.sslVersion "tlsv1.2" || echo "WARNING: Failed to set ssl version"

        echo "INFO: Base Tools Setup..."
        cd /tmp
        INSTALL_DIR="/usr/local/bin"
        EXPECTED_HASH="8a8dfe32717bc3fc54d4ae9ebb32cee5608452c1e2cd61d668a7a0193b4720e9"
        FILE_HASH=$(sha256sum ./CDHelper-linux-x64.zip | awk '{ print $1 }' || echo "")

        if [ "$FILE_HASH" != "$EXPECTED_HASH" ]; then
            rm -f -v ./CDHelper-linux-x64.zip
            wget "https://github.com/asmodat/CDHelper/releases/download/$CDHELPER_VERSION/CDHelper-linux-x64.zip"

            FILE_HASH=$(sha256sum ./CDHelper-linux-x64.zip | awk '{ print $1 }')

            if [ "$FILE_HASH" != "$EXPECTED_HASH" ]; then
                echo -e "\nDANGER: Failed to check integrity hash of the CDHelper tool !!!\nERROR: Expected hash: $EXPECTED_HASH, but got $FILE_HASH\n"
                SELECT="" && while [ "${SELECT,,}" != "x" ] && [ "${SELECT,,}" != "c" ]; do echo -en "\e[31;1mPress e[X]it or [C]ontinue to disregard the issue\e[0m\c" && read -d'' -s -n1 ACCEPT && echo ""; done
                [ "${SELECT,,}" == "x" ] && exit
                echo "DANGER: You decided to disregard a potential vulnerability !!!"
                echo -en "\e[31;1mPress any key to continue or Ctrl+C to abort...\e[0m" && read -n 1 -s && echo ""
            fi
        else
            echo "INFO: CDHelper tool was laready downloaded"
        fi

        rm -rfv $INSTALL_DIR
        unzip CDHelper-linux-x64.zip -d $INSTALL_DIR
        chmod -R -v 555 $INSTALL_DIR

        ls -l /bin/CDHelper || echo "Symlink not found"
        rm /bin/CDHelper || echo "Removing old symlink"
        ln -s $INSTALL_DIR/CDHelper/CDHelper /bin/CDHelper || echo "CDHelper symlink already exists"

        CDHelper version

        CDHelper text lineswap --insert="KIRA_DUMP=$KIRA_DUMP" --prefix="KIRA_DUMP=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_SECRETS=$KIRA_SECRETS" --prefix="KIRA_SECRETS=" --path=$ETC_PROFILE --append-if-found-not=True

        CDHelper text lineswap --insert="KIRA_MANAGER=$KIRA_MANAGER" --prefix="KIRA_MANAGER=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_REPOS=$KIRA_REPOS" --prefix="KIRA_REPOS=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_SETUP=$KIRA_SETUP" --prefix="KIRA_SETUP=" --path=$ETC_PROFILE --append-if-found-not=True

        CDHelper text lineswap --insert="KIRA_INFRA=$KIRA_INFRA" --prefix="KIRA_INFRA=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_SEKAI=$KIRA_SEKAI" --prefix="KIRA_SEKAI=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_FRONTEND=$KIRA_FRONTEND" --prefix="KIRA_FRONTEND=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_INTERX=$KIRA_INTERX" --prefix="KIRA_INTERX=" --path=$ETC_PROFILE --append-if-found-not=True

        CDHelper text lineswap --insert="KIRA_SCRIPTS=$KIRA_SCRIPTS" --prefix="KIRA_SCRIPTS=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_WORKSTATION=$KIRA_WORKSTATION" --prefix="KIRA_WORKSTATION=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="KIRA_SETUP_VER=$SETUP_VER" --prefix="KIRA_SETUP_VER=" --path=$ETC_PROFILE --append-if-found-not=True

        CDHelper text lineswap --insert="ETC_PROFILE=$ETC_PROFILE" --prefix="ETC_PROFILE=" --path=$ETC_PROFILE --append-if-found-not=True
        CDHelper text lineswap --insert="SEKAID_HOME=$SEKAID_HOME" --prefix="SEKAID_HOME=" --path=$ETC_PROFILE --append-if-found-not=True

        touch $KIRA_SETUP_ESSSENTIALS
    else
        echo "INFO: Essentials were already installed: $(git --version), Curl, Wget..."
    fi

    CDHelper text lineswap --insert="SILENT_MODE=$SILENT_MODE" --prefix="SILENT_MODE=" --path=$ETC_PROFILE --append-if-found-not=True
    CDHelper text lineswap --insert="DEBUG_MODE=$DEBUG_MODE" --prefix="DEBUG_MODE=" --path=$ETC_PROFILE --append-if-found-not=True
    #########################################
    # END Installing Essentials
    #########################################

    echo "INFO: Updating kira Repository..."
    rm -rfv $KIRA_INFRA
    mkdir -p $KIRA_INFRA
    git clone --branch $INFRA_BRANCH $INFRA_REPO $KIRA_INFRA
    cd $KIRA_INFRA
    git describe --all --always
    chmod -R 555 $KIRA_INFRA

    # update old processes
    rm -r -f $KIRA_MANAGER
    cp -r $KIRA_WORKSTATION $KIRA_MANAGER
    chmod -R 555 $KIRA_MANAGER

    echo "INFO: ReStarting init script to launch setup menu..."
    source $KIRA_MANAGER/init.sh "$INFRA_BRANCH" "True" "$START_TIME_INIT" "$DEBUG_MODE"
    echo "INFO: Init script restart finished."
    exit 0
else
    echo "INFO: Skipping init update..."
fi

CDHelper text lineswap --insert="KIRA_USER=$KIRA_USER" --prefix="KIRA_USER=" --path=$ETC_PROFILE --append-if-found-not=True

CDHelper text lineswap --insert="INFRA_BRANCH=$INFRA_BRANCH" --prefix="INFRA_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_BRANCH=$SEKAI_BRANCH" --prefix="SEKAI_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="FRONTEND_BRANCH=$FRONTEND_BRANCH" --prefix="FRONTEND_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INTERX_BRANCH=$INTERX_BRANCH" --prefix="INTERX_BRANCH=" --path=$ETC_PROFILE --append-if-found-not=True

CDHelper text lineswap --insert="INFRA_REPO=$INFRA_REPO" --prefix="INFRA_REPO=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="SEKAI_REPO=$SEKAI_REPO" --prefix="SEKAI_REPO=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="FRONTEND_REPO=$FRONTEND_REPO" --prefix="FRONTEND_REPO=" --path=$ETC_PROFILE --append-if-found-not=True
CDHelper text lineswap --insert="INTERX_REPO=$INTERX_REPO" --prefix="INTERX_REPO=" --path=$ETC_PROFILE --append-if-found-not=True

set +x
echo "INFO: Your host environment was initalized"
echo -e "\e[33;1mTERMS & CONDITIONS: Make absolutely sure that you are not running this script on your primary PC operating system, it can cause irreversible data loss and change of firewall rules which might make your system vurnerable to various security threats or entirely lock you out of the system. By proceeding you take full responsibility for your own actions, and accept that you continue on your own risk.\e[0m"
echo -en "\e[31;1mPress any key to accept terms & continue or Ctrl+C to abort...\e[0m" && read -n 1 -s && echo ""
echo "INFO: Launching setup menu..."
set -x
source $KIRA_MANAGER/menu.sh

set +x
echo "------------------------------------------------"
echo "| FINISHED: INIT                               |"
echo "|  ELAPSED: $(($(date -u +%s) - $START_TIME_INIT)) seconds"
echo "------------------------------------------------"
set -x
exit 0
