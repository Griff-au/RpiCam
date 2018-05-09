#!/bin/bash

# -------------------------------------------------------------------
# Take shot 
# -------------------------------------------------------------------

TakeShot ()
{
    local tkePhoto=true
    local ansr=""
    local shotMsg="Ok to take shot [yn] : "

    tput cup $(($start_row + 3)) $left_col; tput el
    tput cup $(($start_row + 4)) $left_col; tput el
    tput cup $(($start_row + 3)) $left_col; echo "Directory : $piStills"
    tput cup $(($start_row + 4)) $left_col; echo "File Name : $stImg"

    while [ $tkePhoto = true ]; do
        tput cup $(($start_row + 6)) $left_col; read -p "$shotMsg" ansr
        if [[ $ansr =~ [YyNn] ]]; then
            if [[ $ansr =~ [Yy] ]]; then 
                tput cup $(($start_row + 7)) $left_col; echo "Taking shot" 
                raspistill -rot 180 -o $stFile 
                tput cup $(($start_row + 7)) $left_col; echo "Shot taken " 
                tput cup $(($start_row + 6)) $left_col; tput el
                stImg="PiImg-$(date +'%y%m%d-%H%M%S').jpg"
                stFile=${piStills}/${stImg}
                tput cup $(($start_row + 4)) $left_col; echo "File Name : $stImg"
                shotMsg="Take another [yn] : "
            else
                tkePhoto=false
                msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter
            fi
        else
            msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
        fi
        tput cup $(($start_row + 6)) $left_col; tput el
    done
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
