source global-conf.sh
export COLUMNS=999
export TERM=xterm
PS3="Selecciona una opción: "
getMenu (){
  cd $scriptdir
  getActions
  ShowHead "Opciones disponibles:"
  select answer in "${choices[@]}"; do
    for item in "${choices[@]}"; do
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
  echo "creando carpetas remotas"
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR*"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR/$weburi"
  ssh $remoteuser@$remotehost "mkdir $BACKUPDIR/$weburi/site"
  # ssh $remoteuser@$remotehost "cp -fr $webroot $BACKUPDIR/$weburi/site"

  echo "Borrando carpetas temporales locales si las hubiera"
  sudo rm -fr $BACKUPDIR*

  echo "creando carpetas locales temporales"
  mkdir $BACKUPDIR
  # open $BACKUPDIR
  mkdir $BACKUPDIR/$weburi
  mkdir $BACKUPDIR/$weburi/site

  for item in "${webroot[@]}"
    do
        echo "bajando a carpetas locales temporales"
        rsync -ahv $remoteuser@$remotehost:$item $BACKUPDIR/$weburi/site
    done

  if [[ ${databasename} ]]; then
    echo "encontrada base de datos"
    ssh $remoteuser@$remotehost "mkdir $BACKUPDIR/$weburi/bbdd"
    mkdir $BACKUPDIR/$weburi/bbdd

    ssh $remoteuser@$remotehost "mysqldump -u$databaseuser -p$databasepassword $databasename > $BACKUPDIR/$weburi/bbdd/${databasename}-backup.sql"
    rsync -ah $remoteuser@$remotehost:$BACKUPDIR/ $BACKUPDIR
  fi
  # ssh $remoteuser@$remotehost "cd $BACKUPDIR; tar -zcf $weburi.-$jftime-.tar.gz $weburi --exclude=settings.php --exclude=*.mp4 --exclude=*.mov --exclude=*.ogm --exclude=*.webm --exclude=*.avi --exclude=*.mysql.gz"

  if [ ! -d "$LOCALBACKUPDIR/$weburi" ]; then
    mkdir $LOCALBACKUPDIR/$weburi
    echo -e "${YELLOW}$LOCALBACKUPDIR/$weburi creado${NC}"
  fi
  echo "COMPRIMIENDO"
  cd $LOCALBACKUPDIR/$weburi
  # tar -zcf $weburi.-$jftime.tar.gz $BACKUPDIR/$weburi --exclude=settings.php --exclude=*.mp4 --exclude=*.mov --exclude=*.ogm --exclude=*.webm --exclude=*.avi --exclude=*.mysql.gz
  tar -zcf $weburi.-$jftime.tar.gz $BACKUPDIR/$weburi
  cd ../..



  # open $LOCALBACKUPDIR
  # echo $BACKUPDIR
  # rsync -avh $remoteuser@$remotehost:$BACKUPDIR/ $LOCALBACKUPDIR/$weburi
  # mv $BACKUPDIR/ $LOCALBACKUPDIR/$weburi/

  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR"
  ssh $remoteuser@$remotehost "rm -fr $BACKUPDIR*"


  sudo rm -fr $BACKUPDIR*

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
  echo -e "${GREEN}Copia de seguridad completa terminada${NC}"
  echo ""
  terminal-notifier -title "BACKUPS COMPLETADOS!!!!" -message "Todas las tareas de Backup han sido completadas"
  borrarviejos
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

echo "webroot (si existe mas de una carpeta a sincronizar, edita el archivo $weburi.backup.sh directamente:"
read webroot
echo "webroot[0]=$webroot" >> backups-conf/$weburi.backup.sh

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

divideDate(){
  max=$1
  pref=$1
  jfyear=${max:0:4} #ano
  jfmonth=${max:4:2} #mes
  jfday=${max:6:2} #dia
  jfhour=${max:8:2} #hora
  jfminute=${max:10:2} #minuto
  jfsecond=${max:12:2} #segundo
}

borrarviejos(){
  echo "
================================================================================
  Hoy es $(date "+%d/%m/%Y").
================================================================================"

#cogemos todos los sitios con backup existentes y los contamos
backupsites=${LOCALBACKUPDIR}/*
count=0
for site in ${backupsites[@]};do
  count=$((count+1))
done

echo "  ==> ${count} sitios en total
================================================================================"

today=$(date "+%d/%m/%Y")
todayyear=$(date "+%Y")
todaymonth=$(date "+%m")
todayday=$(date "+%d")

for site in ${backupsites[@]};do # recorro sitios con backup
echo "
================================================================================
  Backups de ${site#$LOCALBACKUPDIR/}
================================================================================"


  backuplist=($site/*)

count=0
for site in ${backuplist[@]};do
  count=$((count+1))
  # echo $site
done
echo "$count copias encontradas"


lastweek=$((count-SAVEBACKUPS))
# echo $lastweek
count=0
for (( i = 0; i < $lastweek; i++ )); do
  rm ${backuplist[$i]}
  count=$((count+1))
done
if [[ $count > 0 ]]; then
  echo borrados $count backups
fi

done
}
