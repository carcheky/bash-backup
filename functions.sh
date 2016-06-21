source global-conf.sh

getMenu (){
  getActions
  ShowHead "Opciones disponibles:"
  PS3="Selecciona una opción: "
  select answer in "${choices[@]}"; do
    for item in "${choices[@]}"; do
      if [[ $item == "SALIR" ]]; then
        clear
        exit
      fi
      if [[ $item == $answer ]]; then
        clear
        runAction $item
      fi
    done
  done
}

getActions(){
    actions=(./actions/*.sh)
    for item in "${actions[@]}"; do
        choices=(${choices[@]} ${item##*/})
    done
  choices=(${choices[@]} "SALIR")

}

getBackupMenu (){
getBackupConfigList
ShowHead "Sitios disponibles para realizar una copia de seguridad:"
PS3="Selecciona un sitio: "
select answer in "${backup[@]} "; do
  for item in "${backup[@]}"; do
    if [[ $item == "VOLVER" ]]; then
      clear
      getMenu
    fi
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
    backup=(${backup[@]} "VOLVER")

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
  echo ""
  echo -e "${GREEN}backup de $weburi realizado${NC}"
  echo ""
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR*"
}

ShowHead(){
  echo -e "${PURPLE}============================================================${NC}"
  echo -e "${PURPLE}============================================================${NC}"
  echo -e "${PURPLE}====                                                    ====${NC}"
  echo -e "${PURPLE}====             BASH BACKUP                            ====${NC}"
  echo -e "${PURPLE}====                        por @carcheky               ====${NC}"
  echo -e "${PURPLE}====                                                    ====${NC}"
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
    if [[ $item != "VOLVER" ]]; then
      runInSsh $item
    fi
  done
  clear
  echo ""
  echo -e "${GREEN}Copia de seguridad completa terminada"
  echo ""
  getMenu
}
