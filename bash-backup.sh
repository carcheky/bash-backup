#!/bin/bash
if [[ ! -f "global.conf.sh.example" ]]; then
  echo "debe crear el archivo global-conf.sh para que el script funcione"
  exit
fi

source functions.sh
clear


if [[ $1 == all ]]; then
  /bin/bash ./actions/Backup_All_Sites.sh
  exit
elif [[ 1 != all ]]; then
  getMenu
fi

