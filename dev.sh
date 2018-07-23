#!/bin/bash
#adwpc
#it will update your packages !

OBJ=""
CURDIR=$(cd `dirname $0`; pwd)
NAME=`basename $0`
LOG="$CURDIR/$NAME.log"
ERR="$CURDIR/$NAME.err"


function dev()
{
    #git
    wget https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
    sudo rpm -Uvh endpoint-repo-1.7-1.x86_64.rpm
    sudo yum install -y git
    sudo rm 'endpoint-repo-1.7-1.x86_64.rpm'

    #fish
    cd /etc/yum.repos.d/
    sudo wget https://download.opensuse.org/repositories/shells:fish:release:2/CentOS_7/shells:fish:release:2.repo
    sudo yum -y install fish
    sudo rm 'shells:fish:release:2.repo'
    cd -

    chsh -s /usr/bin/fish
    curl -L http://get.oh-my.fish | /usr/bin/fish

    #autojump
    git clone https://github.com/wting/autojump.git
    cd autojump
    sudo ./install.py
    cd -
    rm -rf autojump
    echo "source $HOME/.autojump/share/autojump/autojump.fish" >> "$HOME/.config/fish/conf.d/omf.fish"

    #go
    wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz
    echo "set -x GOROOT /usr/local/go" >> "$HOME/.config/fish/conf.d/omf.fish"
    echo "set -x GOPATH $HOME/work" >> "$HOME/.config/fish/conf.d/omf.fish"
    echo "set -x GOBIN $HOME/bin" >> "$HOME/.config/fish/conf.d/omf.fish"
    echo "set -x PATH /usr/local/go/bin $PATH" >> "$HOME/.config/fish/conf.d/omf.fish"
    rm go1.10.3.linux-amd64.tar.gz

    #vim
    git clone https://github.com/adwpc/vim.git
    cd vim
    ./install centos7_vim
    ./install vimrc
    cd -

    #trash-cli
    git clone https://github.com/andreafrancia/trash-cli.git
    cd trash-cli
    sudo python setup.py install
    echo "alias rm=trash-put" >> "$HOME/.config/fish/conf.d/omf.fish"
    cd -
    rm -rf trash-cli

}

dev
