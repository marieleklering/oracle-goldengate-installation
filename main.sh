#!/bin/bash
##add groups for oracle:
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper oracle
##update yum
yum update -y

##add config for oracle database installation
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.shmmax = 4398046511104" >> /etc/sysctl.conf
echo "kernel.shmall = 1073741824" >> /etc/sysctl.conf
echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf

echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf
echo "fs.file-max = 6815744" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf
echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.wmem_max = 1048586" >> /etc/sysctl.conf
/sbin/sysctl -p
echo "oracle   soft   nproc    131072" >> /etc/security/limits.conf
echo "oracle   hard   nproc    131072" >> /etc/security/limits.conf
echo "oracle   soft   nofile   131072" >> /etc/security/limits.conf
echo "oracle   hard   nofile   131072" >> /etc/security/limits.conf
echo "oracle   soft   core     unlimited" >> /etc/security/limits.conf
echo "oracle   hard   core     unlimited" >> /etc/security/limits.conf
echo "oracle   soft   memlock  50000000" >> /etc/security/limits.conf
echo "oracle   hard   memlock  50000000" >> /etc/security/limits.conf

##install necessary packages
yum install -y compat-libstdc++-33 
yum install -y elfutils-libelf 
yum install -y elfutils-libelf-devel 
yum install -y gcc 
yum install -y gcc-c++ 
yum install -y glibc 
yum install -y glibc-common 
yum install -y glibc-devel 
yum install -y glibc-headers 
yum install -y ksh 
yum install -y libaio 
yum install -y libaio-devel 
yum install -y libgcc 
yum install -y libstdc++ 
yum install -y libstdc++-devel 
yum install -y make 
yum install -y sysstat 
yum install -y unixODBC 
yum install -y unixODBC-devel

##create mount point
cd /home/ec2-user/
mkdir /u01
mount /dev/xvda1 /u01/

##download db.env file
cd /home/oracle
wget https://github.com/marieleklering/project2/blob/master/db.env
.db.env

##download midias
mkdir -p /home/oracle/midias/
cd /home/oracle/midias/
wget https://s3.amazonaws.com/oracle-midias/123010_fbo_ggs_Linux_x64_services_shiphome.zip
wget https://s3.amazonaws.com/oracle-midias/p13390677_112040_Linux-x86-64_1of7.zip
wget https://s3.amazonaws.com/oracle-midias/p13390677_112040_Linux-x86-64_2of7.zip

##unzip midias
unzip https://s3.amazonaws.com/oracle-midias/123010_fbo_ggs_Linux_x64_services_shiphome.zip
unzip https://s3.amazonaws.com/oracle-midias/p13390677_112040_Linux-x86-64_1of7.zip
unzip https://s3.amazonaws.com/oracle-midias/p13390677_112040_Linux-x86-64_2of7.zip

