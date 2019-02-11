#!/bin/bash

#git
wget https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
sudo rpm -Uvh endpoint-repo-1.7-1.x86_64.rpm
sudo yum install -y git
rm endpoint-repo-1.7-1.x86_64.rpm

#ifconfig
sudo yum install net-tools

#fish shell
cd /etc/yum.repos.d/
sudo wget https://download.opensuse.org/repositories/shells:fish:release:2/CentOS_7/shells:fish:release:2.repo
sudo yum install -y fish
sudo rm shells:fish:release:2.repo
cd -

#oh-my-fish
curl -L https://get.oh-my.fish > install
fish install --noninteractive
rm install

#go
wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.5.linux-amd64.tar.gz
rm go1.11.5.linux-amd64.tar.gz

echo 'set -x GOROOT /usr/local/go' >> ~/.config/fish/conf.d/omf.fish
echo "set -x GOPATH ~/work" >> ~/.config/fish/conf.d/omf.fish
echo "set -x GOBIN ~/work/bin" >> ~/.config/fish/conf.d/omf.fish
mkdir -p $GOBIN
echo "set -x PATH /usr/local/go/bin ~/work/bin /usr/sbin $PATH" >> ~/.config/fish/conf.d/omf.fish
source ~/.config/fish/conf.d/omf.fish

#vim8
wget http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/vim-common-8.0.003-1.gf.el7.x86_64.rpm
wget http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/vim-minimal-8.0.003-1.gf.el7.x86_64.rpm
wget http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/vim-enhanced-8.0.003-1.gf.el7.x86_64.rpm
sudo yum install -y vim*.rpm
rm vim*.rpm

#gcc 
sudo yum install -y centos-release-scl
sudo yum install -y devtoolset-7-gcc-c++


#vimrc
#env for vim-go ycm
export GOROOT=/usr/local/go
export GOPATH=~/work
export GOBIN=$GOPATH/bin
export PATH=/opt/rh/devtoolset-7/root/usr/bin:$GOROOT/bin:$GOBIN:$PATH
export LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:/opt/rh/devtoolset-7/root/usr/lib64/dyninst:/opt/rh/devtoolset-7/root/usr/lib/dyninst:/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib

sudo yum install -y cmake
git clone https://github.com/adwpc/wow-vim
cd wow-vim
./install vimrc

#autojump
git clone https://github.com/wting/autojump.git
cd autojump
./install.py
echo "source ~/.autojump/share/autojump/autojump.fish" >> ~/.config/fish/conf.d/omf.fish

#trash cli
wget https://github.com/andreafrancia/trash-cli/archive/master.zip
unzip master.zip
cd trash-cli-master
sudo python setup.py install
rm master.zip

echo 'alias rm=trash-put' >> ~/.config/fish/conf.d/omf.fish
echo 'alias vi=vim' >> ~/.config/fish/conf.d/omf.fish


chsh -s /usr/bin/fish

echo 'sudo reboot to enjoy!'
