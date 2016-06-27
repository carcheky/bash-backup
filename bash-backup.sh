#!/bin/bash
export COLUMNS=20
source functions.sh
clear


if [[ $1 == backupall ]]; then
  /bin/bash ./actions/Backup_All_Sites.sh
  exit
elif [[ 1 != backupall ]]; then
  getMenu
fi

