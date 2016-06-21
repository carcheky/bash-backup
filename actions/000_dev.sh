#!/bin/bash
# sleep 0.2
# export COLUMNS=20
# source functions.sh

source functions.sh

listbackupsites=$LOCALBACKUPDIR/*
for backupsite in ${listbackupsites[@]}; do
  backupsite=${backupsite##*/}
  echo $backupsite
done



























exit
