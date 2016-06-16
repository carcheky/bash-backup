#!/bin/bash
# Bash Menu Script Example
export COLUMNS=20
echo "-------------------------------"
echo "-------------------------------"
PS3='Please enter your choice: (input blank to show menu)'

options=("Backups Config List" "Backup Site" "Backup All" "Fix Perms" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Backups Config List")
            clear
            /bin/bash actions/BackupsConfigList.sh
            ;;
        "Backup Site")
            clear
            /bin/bash actions/BackupSite.sh
            ;;
        "Backup All")
            clear
            /bin/bash actions/BackupAll.sh
            ;;
        "Fix Perms")
            clear
            /bin/bash actions/FixPerms.sh
            ;;
        "Quit")
            clear
            break
            ;;
        *) echo invalid option;;
    esac
done
