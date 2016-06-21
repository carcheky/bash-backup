#!/bin/bash
# sleep 0.2
# export COLUMNS=20
# source functions.sh
source functions.sh

echo "Root user:"
read rootname
echo "host:"
read roothost
resetToDev $rootname $roothost
getMenu
