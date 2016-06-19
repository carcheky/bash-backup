TMPDIR="/tmp"
getMenu (){

  getActions
  PS3="Please enter your choice: "
  select answer in "${choices[@]}"; do
    for item in "${choices[@]}"; do
      if [[ $item == $answer ]]; then
        clear
        runAction $item
        MainMenu
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
PS3="Select site to backup: "
select answer in "${backup[@]} "; do
  for item in "${backup[@]}"; do
    if [[ $item == $answer ]]; then
        runInSsh $item
    fi
    if [[ $item == "BACK TO MENU" ]]; then
      clear
      MainMenu
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
    backup=(${backup[@]} "BACK TO MENU")
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

BackupMenu(){
  insertSpace
  /bin/bash ./actions/BackupsConfigList.sh
}

LoadBackupVariables(){
  source backups-conf/$1
}

MainMenu(){
  /bin/bash ./bash-backup.sh
}

runInSsh(){
  clear
  echo "----------> Realizando Backup ---------->  $1"
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
