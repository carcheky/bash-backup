#!/bin/bash
# Bash Menu Script Example
sleep 0.2
export COLUMNS=20
source functions.sh
echo ""
echo "----------> Fix perms in sudo mode <------------------------------ "
echo ""
sudo chmod -R 777 .
