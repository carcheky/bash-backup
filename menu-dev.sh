#!/bin/bash

while :
do
    clear
    cat<<EOF
    ==============================
    Menusystem experiment
    ------------------------------
    Please enter your choice:

    Option (1) Backup All
    Option (2) Backups Config List
    Option (3) Backup Site
    Option (4) Fix Perms
           (q)uit
    ------------------------------
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  echo "you chose choice 1"; /bin/bash actions/BackupAll.sh;;
    "2")  echo "you chose choice 2"; /bin/bash actions/BackupsConfigList.sh ;;
    "3")  echo "you chose choice 3"; /bin/bash actions/BackupSite.sh ;;
    "4")  echo "you chose choice 4"; /bin/bash actions/FixPerms.sh ;;
    "q")  clear;exit                      ;;
     * )  echo "invalid option"     ;;
    esac
    sleep 1
done
