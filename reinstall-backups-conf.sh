#!/bin/bash
cd; cp -fr bash-backup/backups-conf .; rm -fr bash-backup; git clone https://github.com/carcheky/bash-backup.git; cp -fr backups-conf/ bash-backup; cd bash-backup/; chmod +x bash-backup.sh; ./bash-backup.sh all
