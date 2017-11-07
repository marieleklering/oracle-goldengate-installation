#!/bin/bash
cd /home/oracle/midias/database
su - oracle -c "./runInstaller -silent -responseFile /home/oracle/midias/db_install.rsp -ignoreSysPrereqs -ignorePrereq -waitforcompletion -showProgress"

/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/11.2.0/db_1/root.sh

##config netca
su - oracle -c "netca -silent -responseFile /home/oracle/midias/netca.rsp"

##install DB
su - oracle -c "dbca -silent -responseFile /home/oracle/midias/dbca.rsp"
