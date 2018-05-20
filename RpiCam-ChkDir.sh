#!/bin/bash

# -------------------------------------------------------------------
#   If directory does not exist create it. 
# -------------------------------------------------------------------

CreateDir ()
{
    local locRetVal=0

    mkdir $dirName
    if [ $? -ne 0 ]; then
        locRetVal=1
    fi  

    return $locRetVal
}

# -------------------------------------------------------------------
#   Main Routine starts here - Check if directory exists. 
# -------------------------------------------------------------------

dirName=$1
retVal=0
ansr="n"
chceOk="n"

tput cup $(($start_row + 3)) $left_col; tput el; echo "$dirName not found"
tput cup $(($start_row + 4)) $left_col; tput el  

while [ $chceOk = "n" ]; do
    if [ ! -d $dirName ]; then
        tput cup $(($start_row + 4)) $left_col; read -p "Do you want to create it y/n : " ansr
        if [ $ansr =~ [YyNn] ]; then
           chceOk="y"
           if [ "$ansr" = "y" ]; then
               CreateDir 
               if [ $? -ne 0 ]; then
                   msg="Unable to create $dirName, returning to main menu."; . $DisplayMg; . $PressEnter
                   retVal=1
               fi  
           else
               msg="Directory not created, returning to main menu."; . $DisplayMsg; . $PressEnter
               retVal=1
           fi  
        else
            msg="Choice must be Y or N"; . $DisplayMsg; . $PressEnter
        fi  
    else
        chceOk="y"
    fi  
    tput cup $(($start_row + 4)) $left_col; tput el  
done

return $retVal
