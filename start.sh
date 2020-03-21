#!/bin/bash
# ubuntu18.sh
##vi ubuntu18.sh
###############################################set conf#################################################

# check for root privilege
if [ "$(id -u)" != "0" ]; then
   echo " this script must be run as root" 1>&2
   echo
   exit 1
fi

#set ulimit
echo \#\!/bin/bash >> /etc/rc.local
echo "ulimit -SHn 1024000" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
 *           soft   nofile       1024000
 *           hard   nofile       1024000
 *           soft   nproc        1024000
 *           hard   nproc        1024000
EOF

# set max service processes

cat >> /etc/systemd/system.conf << EOF
DefaultLimitNOFILE=1024000
DefaultLimitNPROC=1024000
EOF

#set max user processes
#set ssh
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
#sed -i 's/#PermitRootLogin yes/#PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd
#set sysctl
true > /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
 net.ipv4.ip_forward = 0
 net.ipv4.conf.default.rp_filter = 1
 net.ipv4.conf.default.accept_source_route = 0
 kernel.sysrq = 0
 kernel.core_uses_pid = 1
 net.ipv4.tcp_syncookies = 1
 fs.file-max = 1024000
 fs.nr_open = 1024000
 vm.swappiness = 0
 vm.max_map_count = 2048000
 vm.overcommit_memory = 1
 kernel.sem =5010 641280 5010 128
 kernel.pid_max = 4194303
 kernel.msgmnb = 65536
 kernel.msgmax = 65536
 kernel.shmmax = 68719476736
 kernel.shmall = 4294967296
 net.ipv4.tcp_max_tw_buckets = 6000
 net.ipv4.tcp_sack = 1
 net.ipv4.tcp_window_scaling = 1
 net.ipv4.tcp_mem = 786432 1697152 1945728
 net.ipv4.tcp_rmem = 4096 87380 16777216
 net.ipv4.tcp_wmem = 4096 65536 16777216
 net.core.wmem_default = 8388608
 net.core.rmem_default = 8388608
 net.core.rmem_max = 16777216
 net.core.wmem_max = 16777216
 net.core.netdev_max_backlog = 2048000
 net.core.somaxconn = 65535
 net.ipv4.tcp_max_orphans = 3276800
 net.ipv4.tcp_max_syn_backlog = 2048000
 net.ipv4.tcp_mem = 94500000 915000000 927000000
 net.ipv4.tcp_fin_timeout = 1
 net.ipv4.tcp_keepalive_time = 1200
 net.ipv4.ip_local_port_range = 1024 65535
# net.ipv4.ip_local_reserved_ports = 8000-20000
 net.ipv4.neigh.default.gc_stale_time=120
 net.ipv4.conf.default.rp_filter=0
 net.ipv4.conf.all.rp_filter=0
 net.ipv4.conf.all.arp_announce=2
 net.ipv4.conf.lo.arp_announce=2
EOF
/sbin/sysctl -p
echo "sysctl set OK!!"
#set profile
cat >> /etc/profile << EOF
ulimit -d unlimited
ulimit -m unlimited
ulimit -s unlimited
ulimit -v unlimited
ulimit -t unlimited
ulimit -c unlimited
EOF
source /etc/profile
#set dns
##echo DNS=192.168.1.169 >>/etc/systemd/resolved.conf
##echo DNS=192.168.1.8 >>/etc/systemd/resolved.conf
##systemctl restart systemd-resolved.service
chmod +x /etc/rc.local
netplan apply
# 安装docker 使用 WARNING: No swap limit support
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
update-grub
 apt update -y
systemctl stop ufw.service
systemctl disable ufw.service
rm -rf /root/start.sh
