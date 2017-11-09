#!/bin/bash
##create directories 
mkdir -p /home/oracle/12.3.0.1
mkdir -p /home/oracle/oraInventory
mkdir -p /home/oracle/gg_deployments/ServiceManager

##download response file
cd /home/oracle/midias/
wget https://raw.githubusercontent.com/marieleklering/project2/master/oggcore.rsp
wget https://raw.githubusercontent.com/marieleklering/project2/master/ogg_config.rsp
wget https://raw.githubusercontent.com/marieleklering/project2/master/db_config.sql
chown -R oracle.oinstall /home/oracle/

##run installer
su - oracle -c "/home/oracle/midias/fbo_ggs_Linux_x64_services_shiphome/Disk1/runInstaller -silent -nowait -ignoreSysPrereqs -responseFile /home/oracle/midias/oggcore.rsp"

##config service manager
##db steps
su - oracle -c "sqlplus / as sysdba @db_config.sql"

##run config
su - oracle -c "/home/oracle/12.3.0.1/bin/oggca.sh -silent -responseFile /home/oracle/midias/ogg_config.rsp"
