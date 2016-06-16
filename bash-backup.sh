#!/bin/bash
# Bash Menu Script Example
sleep 0.2
export COLUMNS=20
source functions.sh
clear
clear
echo ""
echo ""
echo "_______________________________________________"
echo ""
echo "          WELCOME TO bash-backup.sh"
echo "_______________________________________________"
echo ""
echo ""
echo ""

getdirs actions
PS3="Please enter your choice: "
select answer in "${choices[@]}" "QUIT"; do
    if [[ $answer == "QUIT" ]]; then
        clear
        echo "_______________________________________________"
        echo "
        Thanks & bye"
        echo "_______________________________________________"
        sleep 0
        clear
        break 5
    fi
  for item in "${choices[@]}"; do
    if [[ $item == $answer ]]; then
        clear
        /bin/bash ./actions/"$item"
        break 5
    fi
  done
done

