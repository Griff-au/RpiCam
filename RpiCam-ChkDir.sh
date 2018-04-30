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

while [ $chceOk = "n" ]; do
    if [ ! -d $dirName ]; then
        tput cup $(($start_row + 3)) $left_col; tput el  
        tput cup $(($start_row + 4)) $left_col; tput el  
        tput cup $(($start_row + 3)) $left_col; echo "$dirName not found"
        tput cup $(($start_row + 4)) $left_col; read -p "Do you want to create it y/n : " ansr
        if [ ! -z $ansr ]; then
           if [ "$ansr" = "y" ]; then
               CreateDir 
               if [ $? -ne 0 ]; then
                   msg="Unable to create $dirName, returning to main menu."; . $DisplayMg; . $PressEnter
                   retVal=1
               else
                   chceOk="y"
               fi  
           elif [ $ansr = "n" ]; then
               msg="Directory not created, returning to main menu."; . $DisplayMsg; . $PressEnter
               retVal=1
               chceOk="y"
           else
               msg="Choice must be Y or N"; . $DisplayMsg; . $PressEnter
           fi  
        else
            msg="No respone given, choice must be Y or N"; . $DisplayMsg; . $PressEnter
        fi  
    else
        chceOk="y"
    fi  
done

return $retVal
