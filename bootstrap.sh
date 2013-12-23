#!/usr/bin/env bash

set -e

if [[ $EUID == 0 ]]; then
    echo "run as normal user please"
    exit 1
fi

hash git 2>/dev/null || { echo >&2 "Install git first.  Aborting."; exit 1; }

RUBY_VERSION='2.0.0-p353'
CURRENT_USER=$(whoami)
CHEF_SERVER="https://api.opscode.com/organizations/devtrwlan"
PROJECT_DIR="${HOME}/projects/chef-local"

if [[ ! -d $PROJECT_DIR ]]; then
    git clone 'git@github.com:llwt/chef-local.git' ${PROJECT_DIR}
fi

cd $PROJECT_DIR
echo -e "changed to $(pwd)"

mkdir_and_cd () {
    CREATE_DIR=$1
    if [[ -n $2 ]]; then
        USE_SUDO=true
        if [[ -n $3 ]];then
            SET_OWNER_TO=$3
        fi
    fi

    if [[ ! -d $1 ]]; then
        echo "making dir $CREATE_DIR"
        if $USE_SUDO; then
            sudo mkdir $CREATE_DIR --parents
        else
            mkdir $CREATE_DIR --parents
        fi
    fi

    if [[ $USE_SUDO && -n $SET_OWNER_TO ]];then
        sudo chown -R "$SET_OWNER_TO:$SET_OWNER_TO" $CREATE_DIR
    fi
    echo "changing into $CREATE_DIR"
    cd $CREATE_DIR
}

abs_pkg_build () {
    TARBALL_LOC=$1
    TAR_FILE=${TARBALL_LOC##*/}
    PKG_NAME=${TAR_FILE%.tar.gz}

    wget $TARBALL_LOC
    tar xzvf $TAR_FILE
    rm $TAR_FILE
    cd $PKG_NAME
    makepkg -si --noconfirm
}

bootstrap_arch_linux () {
    ABS_DIR="/var/abs/local"
    mkdir_and_cd $ABS_DIR true $CURRENT_USER
    abs_pkg_build 'https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz'
    abs_pkg_build 'https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz'
    sudo sed -i 's/#DEVELBUILDDIR/DEVELBUILDDIR/' /etc/yaourtrc
    yaourt -S --noconfirm 'ruby-build'
    yaourt -S --noconfirm 'rbenv'
}

OS=$(uname -s)
case ${OS} in
    "Darwin" )
        echo "TODO"
        exit 3 ;;
    "Linux" )
        CHEF_ENVIRONMENT="arch"
        bootstrap_arch_linux
        ;;
    *)
        echo "${OS} unsupported"
        exit 2
esac

cd $HOME

eval "$(rbenv init -)"
rbenv rehash
set +e
rbenv install $RUBY_VERSION
set -e
rbenv shell   $RUBY_VERSION
rbenv global  $RUBY_VERSION

echo 'Installing chef gem...'
gem install chef
rbenv rehash

KNIFE_COMMON_OPTS="\
 -s ${CHEF_SERVER}\
 --user stevenmnance\
 --yes"

knife configure $KNIFE_COMMON_OPTS\
 --repository "${PROJECT_DIR}"\
 --validation-client-name devtrwlan-validator\
 --validation-key "${HOME}/.chef/devtrwlan-validator.pem"\
 --admin-client-name "stevenmnance"\
 --admin-client-key "${HOME}/.chef/stevenmnance.pem"

sudo knife configure client /etc/chef\
 $KNIFE_COMMON_OPTS

echo 'run `sudo chef-client` when you're done'
