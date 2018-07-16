#!/bin/bash
#adwpc

OBJ=""
CURDIR=$(cd `dirname $0`; pwd)
NAME=`basename $0`
LOG="$CURDIR/$NAME.log"
ERR="$CURDIR/$NAME.err"



function sysctl_conf_optm() {
    sudo mv /etc/sysctl.conf /etc/sysctl.conf.`date +%Y%m%d%H%M%S`
    cat >> sysctl.conf << EOF

#the process open file limit
fs.nr_open = 1048576

#the system open file limit
fs.file-max = 1048576


#port range
net.ipv4.ip_local_port_range = 1024 65535

# Decrease the time default value for connections to keep alive
#tcp keepalive packet cycle
net.ipv4.tcp_keepalive_time = 600

#tcp keepalive packet retry times
net.ipv4.tcp_keepalive_probes = 10

#tcp keepalive packet retry delay when packet lost
net.ipv4.tcp_keepalive_intvl = 30

# TCP window scaling for high-throughput, high-pingtime TCP performance
net.ipv4.tcp_window_scaling = 1

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 65535


# Controls the System Request debugging functionality of the kernel
#disable debug
kernel.sysrq = 0


# Don't ignore directed pings
net.ipv4.icmp_echo_ignore_all = 0

# Controls the maximum size of a message queue, in bytes
kernel.msgmnb = 65536

# Controls the maximum msg num of queue
kernel.msgmni = 1024

# Controls the default maximum size of a message
kernel.msgmax = 655360

# specifies the minimum virtual address that a process is allowed to mmap
vm.mmap_min_addr = 4096

# How many times to retry killing an alive TCP connection
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_retries1 = 3

# Increase the maximum memory used to reassemble IP fragments
net.ipv4.ipfrag_high_thresh = 512000
net.ipv4.ipfrag_low_thresh = 446464


# Set maximum amount of memory allocated to shm to 16G
kernel.shmmax = 16000000000
kernel.shmall = 4000000

# number of unprocessed input packets before kernel starts dropping them
net.core.netdev_max_backlog = 262144
net.core.rmem_default = 1048576
net.core.optmem_max = 1048576
net.core.rmem_max = 33554432
net.core.somaxconn = 65535
net.core.wmem_max = 1048576

#iptables
net.netfilter.nf_conntrack_max = 1048576


net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_timestamps = 1

# 
net.ipv4.tcp_rmem = 32768 131072 16777216
net.ipv4.tcp_wmem = 8192 131072 16777216
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 10000


# Do a 'modprobe tcp_cubic' first
net.ipv4.tcp_congestion_control = cubic

# cache ssthresh from previous connection
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.tcp_moderate_rcvbuf = 0

# Enable a fix for RFC1337 - time-wait assassination hazards in TCP
net.ipv4.tcp_rfc1337 = 1

# UDP parameters
net.ipv4.udp_mem = 262144 1048576 10485760
net.ipv4.udp_rmem_min = 1048576
net.ipv4.udp_wmem_min = 1048576

# Enable ignoring broadcasts request
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable bad error message Protection
net.ipv4.icmp_ignore_bogus_error_responses = 1


vm/min_free_kbytes = 65536


# disable ipv6
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1
# net.ipv6.conf.lo.disable_ipv6 = 1

# This will ensure that immediately subsequent connections use the new values
net.ipv4.route.flush = 1
# net.ipv6.route.flush = 1

EOF
    sudo mv sysctl.conf /etc
    sudo sysctl -p

    sudo cp /etc/security/limits.conf /etc/security/limits.conf.`date +%Y%m%d%H%M%S`
    cat >> limits.conf << EOF

#the shell open file limit, the soft limit is a warning point, and the hard limit is a block.
#relogin make params work

* soft nofile 1048575
* hard nofile 1048575
* soft nproc 1048575
* hard nproc 1048575


# End of file

EOF
    sudo mv limits.conf /etc/security

}

sysctl_conf_optm
