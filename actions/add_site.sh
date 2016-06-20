#!/bin/bash
# sleep 0.2
# export COLUMNS=20
# source functions.sh
# echo "----------> Example Action <------------------------------ "
export COLUMNS=990
source functions.sh

  echo "weburi:"
  read weburi
  touch backups-conf/$weburi.backup.sh
  echo "weburi=$weburi" >> backups-conf/$weburi.backup.sh

  echo "webroot:"
  read webroot
  echo "webroot=$webroot" >> backups-conf/$weburi.backup.sh

  echo "remotehost:"
  read remotehost
  echo "remotehost=$remotehost" >> backups-conf/$weburi.backup.sh

  echo "remoteuser:"
  read remoteuser
  echo "remoteuser=$remoteuser" >> backups-conf/$weburi.backup.sh

  echo "databasename:"
  read databasename
  echo "databasename=$databasename" >> backups-conf/$weburi.backup.sh

  echo "databaseuser:"
  read databaseuser
  echo "databaseuser=$databaseuser" >> backups-conf/$weburi.backup.sh

  echo "databasepassword:"
  read databasepassword
  echo "databasepassword=$databasepassword" >> backups-conf/$weburi.backup.sh

clear
echo -e "${GREEN}$weburi creado${NC}"
getMenu
