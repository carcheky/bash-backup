source global-conf.sh

getMenu (){
  getActions
  ShowHead "Action list:"
  PS3="Please enter your choice: "
  select answer in "${choices[@]}"; do
    for item in "${choices[@]}"; do
      if [[ $item == "Quit" ]]; then
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
  choices=(${choices[@]} "Quit")

}

getBackupMenu (){
getBackupConfigList
ShowHead "Avaivable sites to backup:"
PS3="Select site to backup: "
select answer in "${backup[@]} "; do
  for item in "${backup[@]}"; do
    if [[ $item == "BACK TO MAIN MENU" ]]; then
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
    backup=(${backup[@]} "BACK TO MAIN MENU")

}

runAction(){
  /bin/bash ./actions/$item
}

LoadBackupVariables(){
  source backups-conf/$1
}

runInSsh(){
  echo "============================================================="
  echo "============================================================="
  echo "Realizando Backup de  $1"
  LoadBackupVariables $1
  jftime=$(date "+%Y%m%d%H%M%S")
  jfday=$(date "+%Y%m%d")
  BACKUPDIR=$TMPDIR/bash-backups-$jfday

  if [[ $DEV == 1 ]]; then
    sudo rm -fr $LOCALBACKUPDIR
    ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR"
    echo ""
    echo "==============================================="
    echo "=             RUNNING IN DEV MODE             ="
    echo "==============================================="
  fi

  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR/$1"
  ssh $remoteuser@$remotehost "cp -fr $webroot $BACKUPDIR/$1"
  ssh $remoteuser@$remotehost "mysqldump -u$databaseuser -p$databasepassword $databasename > $BACKUPDIR/$1/backup.sql"
  ssh $remoteuser@$remotehost "cd $BACKUPDIR; tar -zcf $1-$jftime.tar.gz $1 --exclude=settings.php --exclude=*.mp4"
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR/$1"
  rsync -avh $remoteuser@$remotehost:$BACKUPDIR $LOCALBACKUPDIR
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR"
  echo "backup de $1 realizado"
  echo ""
  echo ""
  echo ""
  echo ""

}

ShowHead(){
  echo "============================================================="
  echo "=                                                           ="
  echo "=                 BASH BACKUP                               ="
  echo "=                            por @carcheky                  ="
  echo "=                                                           ="
  echo "============================================================="
  echo ""
  echo ""
  if [[ $1 ]]; then
  echo $1
  echo ""
  fi
}


BackupAllSites(){
  ShowHead "Backup All"
  getBackupConfigList
  for item in "${backup[@]}"
  do
    runInSsh $item
  done
  echo "Backup completed"
  getMenu
}
