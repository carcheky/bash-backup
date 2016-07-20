#!/bin/bash

source functions.sh

year=2016
hour=00
minutes=00
seconds=00

for (( i = 1; i < 4; i++ )); do
  jfdir=backups$i.jfmaguire.es
  mkdir ${LOCALBACKUPDIR}/$jfdir

  for (( month = 2; month < 7; month++ )); do
      monthlength=${#month}
      if [[ $monthlength == 1 ]]; then
        mes=0$month
      elif [[ $monthlength == 2 ]]; then
        mes=$month
      fi

      for (( day = 1; day < 8; day++ )); do
        daylength=${#day}
        if [[ $daylength == 1 ]]; then
          dia=0$day
        elif [[ $daylength == 2 ]]; then
          dia=$day
        fi
      touch ${LOCALBACKUPDIR}/$jfdir/$jfdir.-$year$mes$dia$hour$minutes$seconds-.tar.gz
      done
  done
done
# getMenu
