#!/bin/bash
source functions.sh
clear


if [[ $1 == all ]]; then
  /bin/bash ./actions/Backup_All_Sites.sh
  exit
elif [[ 1 != all ]]; then
  getMenu
fi

