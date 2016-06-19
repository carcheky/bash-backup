TMPDIR="/tmp"

MainMenu(){
  /bin/bash ./bash-backup.sh
}

getMenu (){
  getActions
  choices=(${choices[@]} "Quit")
  ShowHead "Action list:"
  PS3="Please enter your choice: "
  select answer in "${choices[@]}"; do
    for item in "${choices[@]}"; do
      if [[ $item == "Quit" ]]; then
        clear
        exit
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
}

getBackupMenu (){
getBackupConfigList
backup=("BACK TO MENU" "" ${backup[@]})
ShowHead "Avaivable sites to backup:"
PS3="Select site to backup: "
select answer in "${backup[@]} "; do
  for item in "${backup[@]}"; do
    if [[ $item == "BACK TO MENU" ]]; then
      clear
      getMenu
    fi
    if [[ $item == $answer ]]; then
        runInSsh $item
    fi

    echo $item
  done
done
}
getBackupConfigList(){
    backups=(./backups-conf/*.sh)
    for item in "${backups[@]}"; do
        backup=(${backup[@]} ${item##*/})
    done
}

insertSpace(){
        echo ""
        echo ""
        echo ""
}

runAction(){
  /bin/bash ./actions/$item
}

backupValues(){
  ssh
}

LoadBackupVariables(){
  source backups-conf/$1
}


runInSsh(){
  echo "Realizando Backup de  $1"
  LoadBackupVariables $1
  jftime=$(date "+%Y%m%d%H%M%S")
  jfday=$(date "+%Y%m%d")
  BACKUPDIR=$TMPDIR/bash-backups-$jfday
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR/$1"
  ssh $remoteuser@$remotehost "cp -fr $webroot $BACKUPDIR/$1"
  ssh $remoteuser@$remotehost "mysqldump -u$databaseuser -p$databasepassword $databasename > $BACKUPDIR/$1/backup.sql"
  ssh $remoteuser@$remotehost "cd $BACKUPDIR; tar -zcf $1-$jftime.tar.gz $1"
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR/$1"
  rsync -avh $remoteuser@$remotehost:$BACKUPDIR bash-backups
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR"
}

ShowHead(){
  echo "_____________________________________________________________"
  echo "_                                                           _"
  echo "_                 BASH BACKUP                               _"
  echo "_                            por @carcheky                  _"
  echo "_                                                           _"
  echo "_____________________________________________________________"
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
    echo "_____________________________________________________________"
    echo "_____________________________________________________________"
    runInSsh $item
    echo "backup de $item realizado"
    echo ""
    echo ""
    echo ""
    echo ""
  done
  echo "Backup completed"
  pause
  getMenu
}
