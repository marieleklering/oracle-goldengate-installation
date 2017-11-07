#!/bin/bash
cd /home/oracle/midias/database
sudo -u oracle ./runInstaller -silent -responseFile /home/oracle/midias/db_install.rsp -ignoreSysPrereqs -ignorePrereq -waitforcompletion -showProgress
./u01/app/oraInventory/orainstRoot.sh
./u01/app/oracle/product/11.2.0/db_1/root.sh

##config netca
/home/oracle/db.env 
cd /home/oracle/midias
sudo -u oracle netca -silent -responseFile /home/oracle/midias/netca.rsp

##install DB
sudo -u oracle dbca -silent -responseFile /home/oracle/midias/dbca.rsp
