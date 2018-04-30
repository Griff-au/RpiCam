#!/bin/bash

# -------------------------------------------------------------------
# Take shot 
# -------------------------------------------------------------------

TakeShot ()
{
    local takeShot=true

    tput cup $(($start_row + 3)) $left_col; tput el
    tput cup $(($start_row + 4)) $left_col; tput el
    tput cup $(($start_row + 3)) $left_col; echo "Directory : $piStills"
    tput cup $(($start_row + 4)) $left_col; echo "File Name : $stImg"
    tput cup $(($start_row + 6)) $left_col; read -p "Ok to take shot y/n : " ansr

    if [ ! -z $ansr ]; then
        if [ $ansr = "y" ]; then 
            while [ $takeShot = true ]; do
                tput cup $(($start_row + 7)) $left_col; echo "Taking shot" 
                raspistill -rot 180 -o $stFile 
                tput cup $(($start_row + 7)) $left_col; echo "Shot taken " 
                tput cup $(($start_row + 6)) $left_col; tput el
                TakeAnother
                if [ $? -eq 0 ]; then
                    stImg="PiImg-$(date +'%y%m%d-%H%M%S').jpg"
                    stFile=${piStills}/${stImg}
                    tput cup $(($start_row + 4)) $left_col; echo "File Name : $stImg"
                else
                    takeShot=false
                fi
            done
        else
            msg="Choice was not Yes, returning to main menu."; . $DisplayMsg; . $PressEnter
        fi
    else
        msg="No choice made, returning to main menu."; . $DisplayMsg; . $PressEnter
    fi
}

# -------------------------------------------------------------------
# 	Take another shot.
# -------------------------------------------------------------------
 
TakeAnother ()
{
    local locRetVal=0
    local ansr="n"

    tput cup $(($start_row + 6)) $left_col; read -p "Take another y/n : " ansr
    tput cup $(($start_row + 7)) $left_col; tput el

    if [ ! -z $ansr ]; then
        if [ $ansr != "y" ]; then
           msg="No shot to take, returning to main menu"; . $DisplayMsg; . $PressEnter 
           locRetVal=1
        fi    
    else
        msg="No choice made, returning to main menu"; . $DisplayMsg; . $PressEnter 
        locRetVal=1
    fi 

    return $locRetVal
}

# -------------------------------------------------------------------
# 	Main routine - Start here.
# -------------------------------------------------------------------
 
stImg="PiImg-$(date +'%y%m%d-%H%M%S').jpg"
stFile="${piStills}/${stImg}"

hdrLne2="       Still Shot       "

. $PiCamHdr
. $CheckDir "$piStills"

if [ $? -eq 0 ]; then
    TakeShot 
fi
