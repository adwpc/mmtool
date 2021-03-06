#!/bin/bash
#adwpc

CORES=`cat /proc/cpuinfo | grep "processor" | wc -l`

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    unset NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [[ "$CURDIR" == "" ]];then
    CURDIR=$(cd `dirname $0`; pwd)
fi

if [[ "$FNAME" == "" ]];then
    FNAME=`basename $0`
fi

if [[ "$LOG" == "" ]];then
    LOG="$CURDIR/$FNAME.log"
fi

rm "$LOG" > /dev/null 2>&1

if [[ "$ERR" == "" ]];then
    ERR="$CURDIR/$FNAME.err"
fi

rm "$ERR" > /dev/null 2>&1



#check if exist
function exist() {
    # $1 --help > /dev/null
    type "$1" > /dev/null 2>&1
    if [ "$?" -eq 0 ] ; then
        return 0
    else
        return 1
    fi
}

#init tools
function _init() {
    local tools=""
    for tool in wget git svn hg automake autoconf gcc g++ cmake; do
        exist "$tool"
        if [[ $? -eq 1 ]];then
            if [ "$tool" == "g++" ];then
                tool="gcc-c++"
            fi
            if [[ "$OS" == "Ubuntu" && "$tool" == "svn" ]];then
                tool="subversion"
            fi
            tools="${tools} ${tool}"
        fi
    done

    if [[ "$tools" != "" ]];then
        if [[ "$OS" == "CentOS" ]];then
            echo "sudo yum install -y $tools"
            sudo yum install -y $tools
        fi
        if [[ "$OS" == "Ubuntu" ]];then
            echo "sudo apt-get install -y $tools"
            sudo apt-get install -y $tools
        fi
    fi
}

_init

#echol LOGLEVEL ...
function echol()
{
    local mode="\033[0m"
    case "$1" in
        INFO)   mode="\033[34;1m";;#bule
        USER)   mode="\033[32;1m";;#green
        WARN)   mode="\033[33;1m";;#yellow
        ERROR)  mode="\033[31;1m";;#red
        *)      mode="\033[35;1m";;#pink
    esac
    echo -e "$mode$@\033[0m"
    echo -e "$@" >> "$LOG"
}


#run cmd {params...}
function run()
{
    echol "$@"
    eval $@ 1>>"$LOG" 2>>"$ERR"
    local ret=$?
    if [[ $ret -ne 0 ]];then
        eval $@ 1>>"$LOG" 2>>"$ERR"
        if [[ $ret -eq 2 ]];then
            #e.g. make distclean fail return 2
            echol WARN "warning:$@, ret=$ret"
        else
            echol ERROR "failed:$@, ret=$ret"
        fi
        # exit -3
    fi
}

#mv to tmp
function saferm()
{
    # local name=`echo "$1" | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}'`
    local name="${1%/}"
    name="${name##*/}"
    mv $1 "/tmp/$name`date +%Y%m%d%H%M%S`" > /dev/null 2>&1
}


#get code by git/wget
#ver=wget
#ver=git 优先下载最新tag(非rc、beta版本)，如果没有tag，下载stable分支，如果没有stable分支，下载master分支
#get url ver {rename}
function get()
{
    local dir="$PWD"
    local url="$1"
    local dir=`echo "$url" | awk -F'/' '{print $NF}'|awk -F'.' '{print $1}'`
    local rename="$3"
    local ver="$2"
    if [ "$rename" != "" ];then
        saferm $rename
    else
        saferm $dir
    fi
    echol "$FUNCNAME:$@"
    local ltag=""
    if [[ "$ver" == "git" ]]; then
        local ltag_num=`git ls-remote --tags "$url" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | grep -iEv 'dev|alpha|beta|rc|pre|test|fips|engine|mac' | tr -d "a-zA-Z" | sed 's/^[-_]*//' | grep -E "^[0-9]{1,2}[-._][0-9]{1,3}" | sort -V | tail -n1`
        ltag=`git ls-remote --tags "$url" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | grep -iEv 'dev|alpha|beta|rc|pre|test|fips|engine' | grep -e "$ltag_num" | sort -V | tail -n1`
        if [[ "$ltag" == "master" ]]; then
            ltag_num=`git ls-remote --tags "$url" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | grep -iEv 'dev|alpha|beta|rc|pre|test|fips|engine|mac' | tr -d "a-zA-Z" | sed 's/^[-_]*//' | grep -E "^[0-9]{1,2}[-._][0-9]{1,3}" | sort -V | tail -n1`
            ltag=`git ls-remote --tags "$url" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | grep -iEv 'dev|alpha|beta|rc|pre|test|fips|engine' | grep -e "$ltag_num" | sort -V | tail -n1`
        fi
    elif [[ "$ver" == "wget" ]]; then
        saferm wget.data
        run wget $url -c -O wget.data
        uz wget.data
    elif [[ "$ver" == "master" ]]; then
        run git clone --depth=1 -b master "$url"
        return 0
    else
        ltag=`git ls-remote --tags "$url" | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | grep -iEv 'dev|alpha|beta|rc|pre|test|fips|engine' | grep -w "$ver" | sort -V | head -n1`
    fi

    if [[ "$ver" != "wget" ]]; then
        if [[ "$ltag" == "" ]];then
            local stable=`git ls-remote --heads "$url" | awk '{print $2}' | awk -F"/" '{print $3}' | grep "stable" | sort -n -t. -k1,1`
            if [ "$stable" == "" ];then
                echol INFO "master"
                if [ "$rename" == "" ];then
                    run git clone --depth=1 -b master "$url"
                else
                    run git clone --depth=1 -b master "$url" "$rename"
                fi
            else
                echol INFO "stable"
                if [ "$rename" == "" ];then
                    run git clone --depth=1 -b $stable "$url"
                else
                    run git clone --depth=1 -b $stable "$url" "$rename"
                fi
            fi
        else
            echol INFO "$ltag"

            if [ "$rename" == "" ];then
                run git clone --depth=1 -b "$ltag" "$url"
            else
                run git clone --depth=1 -b "$ltag" "$url" "$rename"
            fi
        fi
    fi
    echol "success:$@"
}

#download url
#dl url {rename}
function wgetdl()
{
    local file="${1##*/}"
    local rename="$2"
    echol "$FUNCNAME:$@"
    if [ ! -f "$file" ];then
        rm -fr "$file"
        if [ "$rename" = "" ];then
            run wget --no-verbose -c "$1" > /dev/null
        else
            run wget --no-verbose -c -O "$2" "$1" > /dev/null
        fi
    fi
    echol "success:$@"
}


#download repo to yum.repos.d
function dlrepo()
{
    cd /etc/yum.repos.d
    run sudo wget --no-verbose -c "$1"
    cd -
}

function rmrepo() {
    cd /etc/yum.repos.d
    run sudo rm "$1"
    cd -
}

#unzip file
#uz file
function uz()
{
    echol "$@"
    local ftype=`file "$1"`   # Note ' and ` is different
    case "$ftype" in
        "$1: Zip archive"*)
            run unzip "$1" > /dev/null;;
        "$1: gzip compressed"*)
            run tar zxvf "$1" > /dev/null;;
        "$1: bzip2 compressed"*)
            run tar jxvf "$1" > /dev/null;;
        "$1: xz compressed data"*)
            run tar xf "$1" > /dev/null;;
        "$1: 7-zip archive data"*)
            run 7za x "$1" > /dev/null;;
        *)
            echol ERROR "failed:File $1 can not be unzip"
            return;;
    esac
    echol "success:$@"
}

#ver the tag|branch that you want to build, git means: try the lastest release tag,then try the lastest release branch
function inst() {
    local dir="$PWD"
    local dldir="$1"
    local url="$2"
    local ver="$3"

    if [[ "$dldir" == "" ]];then
        dldir="/tmp"
    fi

    if [[ "$url" == "" ]];then
        echol ERROR "url is empty!"
        return 1
    fi

    local folder=`echo "$url" | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}'`
    cd "$dldir" && get "$url" "$ver"
    if [ $? -ne 0 ];then
        echol ERROR "get $url $ver failed!"
        return 1
    fi

    local src="$dldir/$folder"
    if [[ "$ver" != "wget" ]]; then
        cd "$src"
    fi

    #参数列表左移
    shift 3

    #预处理阶段，bootstrap或者autogen.sh或者autoreconf
    #如果命令行有bootstrap，执行
    #否则如果有bootstrap文件，命令行没有，则补充执行，但是参数为默认
    if [[ "$@" =~ "bootstrap" ]];then
        eval run $@
    elif [[ -f bootstrap ]];then
        run ./bootstrap
    fi

    #如果命令有autogen.sh执行，否则如果发现配置文件则执行autoreconf
    if [[ -f autogen.sh ]];then
        run ./autogen.sh
    elif [[ -f configure.ac || -f configure.in ]]; then
        run autoreconf -fiv
    fi

    #configure或者cmake生成Makefile，bootstrap也可以直接生成Makefile
    if [[ "$@" =~ "configure" || "$@" =~ "cmake" || "$@" =~ "config" ]];then
        # if [[ "$@" =~ "configure" || "$@" =~ "cmake" ]];then
        #./configure ...  cmake ...
        # eval $@
        eval run $@
        #如果有Makefile，执行make
        if [[ -f Makefile ]];then
            run make -j"$CORES" && run make install
            if [[ $? -eq 0 ]];then
                echol "$FUNCNAME success!"
            else
                echol ERROR "$FUNCNAME error! see $LOG!"
            fi
            #如果有cmake或者bootstrap，则不支持distclean
            if [[ "$@" =~ "cmake" ]];then
                run make clean
            else
                run make distclean
            fi
        else
            echol ERROR "$FUNCNAME failed, Makefile not exist!"
        fi
        return 0
    fi


    if [[ "$@" =~ "bootstrap" ]]; then
        run make -j"$CORES"
        run make install
        run make clean
        return 0
    else
        #如果没bootstrap有make
        if [[ "$@" =~ "make" ]];then
            eval run $@
        else
            #有Makefile
            if [[ -f Makefile ]];then
                #e.g. sed Makefile
                eval run $@
                run make -j"$CORES"
            fi
        fi
        #如果没有make install，补上
        if [[ "$@" =~ "install" ]];then
            :
        else
            run make install
            if [[ $? -eq 0 ]] ;then
                echol "$FUNCNAME success!"
            else
                echol ERROR "$FUNCNAME error! see $LOG!"
            fi
        fi
        run make clean
        return 0
    fi
    eval cd "$dir" >/dev/null
    return 1

}

#memory size by KB
#usage: $(getmaxmem)
function getmaxmem()
{
    local mem=`free -k|grep "Mem"|awk -F' ' '{print $2}'`
    echo "$mem"
}

#get cpu cores
#usage: $(getmaxcpu)
function getmaxcpu()
{
    local cpu=`cat /proc/cpuinfo |grep processor|awk -F' ' '{print $3}'|tail -n1`
    echo "$cpu"
}
