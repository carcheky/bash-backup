# dev mode: 1 activado
# Esta variable activada lo que hace es asegurarse de boorar directorios
# locales de copias de seguridad y temporales remotos
DEV=0

# Variable para establecer la ruta temporal del directorio remoto
# Por defecto, no tocar, suele ser esta en todos los servidores
TMPDIR="/tmp"

# Variable para establecer el directorio local donde guardar las copias de
# seguridad
LOCALBACKUPDIR=~/BACKUP_SITES

# Colorines to guapos
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
