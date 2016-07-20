#!/bin/bash
if [[ ! -f "global-conf.sh" ]]; then
  echo "debe crear el archivo global-conf.sh para que el script funcione"
  echo "esta vez lo hemos creado por ti, puedes personalizarlo si lo deseas"
  cp global-conf.sh.example global-conf.sh
fi

source functions.sh
clear


if [[ $1 == all ]]; then
  /bin/bash ./actions/Backup_All_Sites.sh
  exit
elif [[ 1 != all ]]; then
  getMenu
fi

