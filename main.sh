#!/bin/bash
##add groups for oracle:
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -u 54321 -g oinstall -G dba,oper oracle
##update yum
yum update -y

##add config for oracle database installation
sed -i '/kernel.shmmax/s/^/#/g' /etc/sysctl.conf
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
mv .bash_profile .bash_profile_old
wget https://raw.githubusercontent.com/marieleklering/project2/master/.bash_profile
. .bash_profile

##download midias
mkdir -p /home/oracle/midias/
cd /home/oracle/midias/
wget https://s3.amazonaws.com/oracle-midias/123010_fbo_ggs_Linux_x64_services_shiphome.zip
wget https://s3.amazonaws.com/oracle-midias/p13390677_112040_Linux-x86-64_1of7.zip
wget https://s3.amazonaws.com/oracle-midias/p13390677_112040_Linux-x86-64_2of7.zip
wget https://raw.githubusercontent.com/marieleklering/project2/master/db_install.rsp
wget https://raw.githubusercontent.com/marieleklering/project2/master/netca.rsp
wget https://raw.githubusercontent.com/marieleklering/project2/master/dbca.rsp


##unzip midias
unzip 123010_fbo_ggs_Linux_x64_services_shiphome.zip
unzip p13390677_112040_Linux-x86-64_1of7.zip
unzip p13390677_112040_Linux-x86-64_2of7.zip

##create oracle directories
mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle/product/11.2.0/db_1
mkdir -p /u01/app/oracle/oradata/
mkdir -p /u01/app/oracle/flash_recovery_area/
chown -R oracle.oinstall /u01/app
chown -R oracle.oinstall /home/oracle/

##installation db software 
su - oracle
cd midias/database
./runInstaller -silent -responseFile /home/oracle/midias/db_install.rsp -ignoreSysPrereqs -ignorePrereq -waitforcompletion -showProgress
./u01/app/oraInventory/orainstRoot.sh
./u01/app/oracle/product/11.2.0/db_1/root.sh

##config netca
cd /home/oracle/midias
netca -silent -responseFile /home/oracle/midias/netca.rsp

##install DB
dbca -silent -responseFile /home/oracle/midias/dbca.rsp


