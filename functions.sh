source global-conf.sh
export COLUMNS=999
PS3="Selecciona una opción: "

getMenu (){
  getActions
  ShowHead "Opciones disponibles:"
  select answer in "${choices[@]}"; do
    for item in "${choices[@]}"; do
      if [[ $item == $answer ]]; then
        clear
        runAction $item
        getMenu
      fi
    done
  done
}

getActions(){
    actions=(./actions/*.sh)
    for item in "${actions[@]}"; do
        choices=(${choices[@]} ${item##*/})
    done
}

getBackupMenu (){
getBackupConfigList
ShowHead "Sitios disponibles para realizar una copia de seguridad:"
  select answer in "${backup[@]}"; do
    for item in "${backup[@]}"; do
      if [[ $item == $answer ]]; then
        runInSsh $item
      fi
    done
  done
}

getBackupConfigList(){
    backups=(./backups-conf/*.sh)
    for itembackup in "${backups[@]}"; do
        backup=(${backup[@]} ${itembackup##*/})
    done
}

runAction(){
  /bin/bash ./actions/$item
}

LoadBackupVariables(){
  source backups-conf/$1
}

runInSsh(){
  if [ ! -d "$LOCALBACKUPDIR" ]; then
    mkdir $LOCALBACKUPDIR/
    echo -e "${YELLOW}$LOCALBACKUPDIR creado${NC}"
  fi
  LoadBackupVariables $1
  jftime=$(date "+%Y%m%d%H%M%S")
  jfday=$(date "+%Y%m%d")
  BACKUPDIR=$TMPDIR/bash-backups-$jfday
  echo ""
  echo -e "${BLUE}============================================================="
  echo -e "${CYAN}Realizando backup de $weburi ${NC}\n"

  runInDev
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR*"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR/$weburi"
  ssh $remoteuser@$remotehost "cp -fr $webroot $BACKUPDIR/$weburi"
  ssh $remoteuser@$remotehost "mysqldump -u$databaseuser -p$databasepassword $databasename > $BACKUPDIR/$weburi/backup.sql"
  ssh $remoteuser@$remotehost "cd $BACKUPDIR; tar -zcf $weburi.$jftime.tar.gz $weburi --exclude=settings.php --exclude=*.mp4 --exclude=*.mysql.gz"
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR/$weburi"
  if [ ! -d "$LOCALBACKUPDIR/$weburi" ]; then
    mkdir $LOCALBACKUPDIR/$weburi
    echo -e "${YELLOW}$LOCALBACKUPDIR/$weburi creado${NC}"
  fi
  rsync -avh $remoteuser@$remotehost:$BACKUPDIR/ $LOCALBACKUPDIR/$weburi
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR"
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR*"
  if [[ $2 ]]; then
    clear
    echo ""
    echo -e "${GREEN}backup de $weburi realizado${NC}"
    echo ""
    terminal-notifier -title "$weburi" -message "backup de $weburi realizado"
    getMenu
  fi
    echo ""
    echo -e "${GREEN}backup de $weburi realizado${NC}"
    echo ""
    terminal-notifier -title "$weburi" -message "backup de $weburi realizado"
}

ShowHead(){
  echo -e "${PURPLE}============================================================${NC}"
  echo -e "${PURPLE}============================================================${NC}"
  echo -e "${PURPLE}====                                                    ====${NC}"
  echo -e "${PURPLE}====           BASH BACKUP por @carcheky                ====${NC}"
  echo -e "${PURPLE}====                                                    ====${NC}"
  echo -e "${PURPLE}====                                 ${RED}(ctrl + c to exit)${NC} ${PURPLE}====${NC}"
  echo -e "${PURPLE}============================================================${NC}"
  echo -e "${PURPLE}============================================================${NC}"
  echo ""
  echo ""
  if [[ $1 ]]; then
  echo $1
  echo ""
  fi
}


BackupAllSites(){
  ShowHead "Realizando copia de seguridad de todos los sitios"
  getBackupConfigList
  for item in "${backup[@]}"
  do
      runInSsh $item
  done
  clear
  echo ""
  echo -e "${GREEN}Copia de seguridad completa terminada"
  echo ""
  terminal-notifier -title "BACKUPS COMPLETADOS!!!!" -message "Todas las tareas de Backup han sido completadas"
  getMenu
}


addNewSite(){
ShowHead "Add new site:"
echo "weburi:"
read weburi
touch backups-conf/$weburi.backup.sh
echo "weburi=$weburi" >> backups-conf/$weburi.backup.sh

echo "remotehost:"
read remotehost
echo "remotehost=$remotehost" >> backups-conf/$weburi.backup.sh

echo "remoteuser:"
read remoteuser
echo "remoteuser=$remoteuser" >> backups-conf/$weburi.backup.sh

echo "webroot:"
read webroot
echo "webroot=$webroot" >> backups-conf/$weburi.backup.sh

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
echo -e "${GREEN}Sitio $weburi creado${NC}"

getMenu
}
runInDev(){
    if [[ $DEV == 1 ]]; then
    sudo rm -fr $LOCALBACKUPDIR
    ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR"
    echo ""
    echo "====================================================="
    echo "====================================================="
    echo "====             RUNNING IN DEV MODE             ===="
    echo "====================================================="
    echo "====================================================="
  fi
}

resetToDev(){
  sudo rm -fr $LOCALBACKUPDIR
  ssh $1@$2 "rm -fr /tmp/bash-backup*"
  ssh $1@$2 "ls -la /tmp | grep bash"
  echo ""
  echo -e "${GREEN}BACKUPS LOCALES Y TEMPORALES REMOTOS BORRADOS${NC}"
  echo ""
}

ListBackups(){
  listbackupsites=$LOCALBACKUPDIR/*
  for backupsite in ${listbackupsites[@]}; do
    backupsite=${backupsite##*/}
    echo $backupsite

  done
}
