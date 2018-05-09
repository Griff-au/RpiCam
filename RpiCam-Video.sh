#!/bin/bash

# -------------------------------------------------------------
# Set length of time video is to be taken for.  Value must be an integer greater than 0. 
# -------------------------------------------------------------

SetLenTime ()
{
    local timeOk="n"

    while [ $timeOk = "n" ]; do
        tput cup $(($start_row + 6)) $left_col; tput el
        tput cup $(($start_row + 6)) $left_col; read -p "Length of time              : " vdTime
        if [[ "$vdTime" =~ ^-?[0-9]+$ ]]; then
            if [ $vdTime -gt 0 ]; then
                timeOk="y"
            else
                msg="Time duration must be greater than zero (0)."; . $DisplayMsg; . $PressEnter
            fi  
        else
            msg="Time duration must be an integer greater then zero (0)."; . $DisplayMsg; . $PressEnter
        fi  
    done
}

# -------------------------------------------------------------
# Set unit of time.  Either minutes or seconds. 
# -------------------------------------------------------------

SetUnitTime ()
{
    local unitOk="n"

    while [ $unitOk = "n" ]; do
        tput cup $(($start_row + 7)) $left_col; tput el
        tput cup $(($start_row + 7)) $left_col; read -p "Minutes or Seconds (m or s) : " vdUnit 
        if [ ! -z $vdUnit ]; then
            if [[ $vdUnit == [msMS] ]]; then
                unitOk="y"
            else
                msg="Unit must be either [Mm] or [Ss]."; . $DisplayMsg; . $PressEnter
            fi
         else
            msg="Unit can't be blank and must be either [Mm] or [Ss]."; . $DisplayMsg; . $PressEnter
        fi 
    done
}

# -------------------------------------------------------------
# Run video recording in background. 
# -------------------------------------------------------------

TakeVideo ()
{
    local chceOk="n"
    local ansr="n"
    local myPid=0
    local vdLen=0
    local vdH264="PiVd-$(date +"%Y%m%d-%H%M%S")-$vdTime$vdUnit.h264"
    local vdFile=${piVideo}/${vdH264}

    if [[ $vdUnit == [mM] ]]; then
        vdLen=$((vdTime * 60000))
    else
        vdLen=$((vdTime * 1000))
    fi

    tput cup $(($start_row + 4)) $left_col; echo "File Name : $vdH264" 

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 9)) $left_col; read -p "Start video [yn] : " ansr 
        if [[ $ansr =~ [YyNn] ]]; then
            chceOk="yes"
            if [[ $ansr =~ [Yy] ]]; then
                nohup raspivid -t $vdLen -o $vdFile 2> /dev/null & 
                myPid=$!
                msg="Video started, PID is $myPid"; . $DisplayMsg; . $PressEnter 
            else 
                msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter 
            fi
        else
            msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter 
        fi
        tput cup $(($start_row + 9)) $left_col; tput el 
    done
}

# -------------------------------------------------------------
# Main routine - Start here 
# -------------------------------------------------------------

vdTime=0
vdUnit=""

hdrLne2="          Video         "

. $PiCamHdr

tput cup $(($start_row + 3)) $left_col; echo "Directory : $piVideo"
tput cup $(($start_row + 4)) $left_col; echo "File Name :" 

. $CheckDir "$piVideo"

if [ $? -eq 0 ]; then
    SetLenTime
    SetUnitTime
    TakeVideo
fi
