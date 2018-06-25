#!/usr/bin/env bash

OBJ=""
CURDIR="$PWD"
LOG="$CURDIR/$0.log"
ERR="$CURDIR/$0.err"
CORES=`cat /proc/cpuinfo | grep "processor" | wc -l`



. common.sh

function cmake3_inst()
{
    exist "cmake3"
    if [ $? -eq 1 ];then
        dl http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
        sudo rpm -Uvh epel-release-7-11.noarch.rpm
        sudo yum -y install cmake3
        # sudo rpm -e epel-release-7-11.noarch
        rm epel-release-7-11.noarch.rpm
    fi
}

function nasm_inst() {
    dlrepo https://www.nasm.us/nasm.repo
    sudo yum -y install nasm
    rmrepo nasm.repo
}

function git_inst()
{
    cd /tmp
    wget https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
    sudo rpm -Uvh endpoint-repo-1.7-1.x86_64.rpm
    sudo yum -y install git
    cd -
}



echo "`date`"
echo "cmd=$0 $@"
echo "log=$LOG"
if [ "$1" != "" ];then
    OBJ="$1"
fi
case "$OBJ" in
    git)    git_inst;;
    nasm) nasm_inst;;
    cmake3) cmake3_inst;;
    *)      echo "Usage: {ffmpeg|git|nasm|cmake3}" >&2
        echo "tested in centos 7.x" >&2
        exit 1
        ;;
esac
echo "install end:$0!"


