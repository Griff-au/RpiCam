#!/bin/bash

# -------------------------------------------------------------
# Check if Time Lapse directory is empty.
# -------------------------------------------------------------

CheckJPG ()
{
    local numJpg=$1
    local locretVal=0
    local ansr="n"
    local chceOk="n"

    tput cup $(($start_row + 6)) $left_col; echo "Currently $numJpg files in $piTL"

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 7)) $left_col; read -p "Do you want to delete them [yn] : " ansr
        if [[ $ansr =~ [YyNn] ]]; then
            chceOk="y"
            if [[ $ansr =~ [Yy] ]]; then
                rm $piTL/*.jpg
                if [ $? -ne 0 ]; then
                    msg="Unable to delete existing files."; . $DisplayMsg; . $PressEnter
                    locretVal=1
                else
                    msg="All $numJpg files deleted."; . $DisplayMsg; . $PressEnter
                fi
            else
                msg="Keeping existing files."; . $DisplayMsg; . $PressEnter
            fi
        else
             msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
        fi
        tput cup $(($start_row + 7)) $left_col; tput el
    done
 
    tput cup $(($start_row + 6)) $left_col; tput el
    tput cup $(($start_row + 7)) $left_col; tput el

    return $locretVal
}

# -------------------------------------------------------------
# Get time interval between each shot in seconds 
# -------------------------------------------------------------
 
GetInterval ()
{
   local intOk="n"

   while [ $intOk = "n" ]; do
      tput cup $(($start_row + 6)) $left_col; tput el
      tput cup $(($start_row + 6)) $left_col; read -p "Time interval in seconds         : " tlInt 
      if [[ "$tlInt" =~ ^-?[0-9]+$ ]] && [ $tlInt -gt 0 ]; then
         intOk="y"
      else
         msg="Must be an integer greater then zero (0)."; . $DisplayMsg; . $PressEnter
      fi
   done
}

# -------------------------------------------------------------
# Get length of time that time lapse is to run for 
# -------------------------------------------------------------
 
GetLength ()
{
   local lenOk="n"

   while [ $lenOk = "n" ]; do
      tput cup $(($start_row + 7)) $left_col; tput el
      tput cup $(($start_row + 7)) $left_col; read -p "Length of time to run in minutes : " tlTime
      if [[ "$tlTime" =~ ^-?[0-9]+$ ]] && [ $tlTime -gt 0 ]; then
         lenOk="y"
      else
         msg="Must be an integer greater then zero (0)."; . $DisplayMsg; . $PressEnter
      fi
   done
}

# -------------------------------------------------------------
# Run Time Lapse in background. 
# -------------------------------------------------------------
 
StartTL ()
{
    local chceOk="n"
    local ansr=""
    local thouSec=$((tlInt * 1000))
    local thouHrs=$((tlTime * 60000))
    local tlPid=0

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 9)) $left_col; read -p "Start timelapse [yn] : " ansr 
        if [[ $ansr =~ [YyNn] ]]; then
            chceOk="y"
            if [[ $ansr =~ [Yy] ]]; then
                nohup raspistill -t "$thouHrs" -tl "$thouSec" -o $tlFile -rot 180 2> /dev/null &
                tlPid=$!
                WriteToLog $tlPid
                msg="Timelapse started, PID is $tlPid."; . $DisplayMsg; . $PressEnter
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
#   Write to log. 
# -------------------------------------------------------------

WriteToLog ()
{
    local pid=$1

    echo "Timelapse started on $(date)" > $tlLog
    echo "Pid is      : $pid" >> $tlLog
    echo "Length is   : $tlTime minute(s)" >> $tlLog
    echo "Interval is : $tlInt seconds between shots" >> $tlLog
    echo "jpg files   : $tlImg" >> $tlLog
}

# -------------------------------------------------------------
# Main routine - Start here 
# -------------------------------------------------------------

tlImg="PiTl-$(date +'%Y%m%d-%H%M')-%04d.jpg"
tlFile="${piTL}/${tlImg}"
tlLog=${piTL}/"PiTl-$(date +'%Y%m%d-%H%M').log"
numJpg=$(ls -l $piTL/*.jpg 2> /dev/null | wc -l)
tlInt=0
tlTime=0

hdrLne2="       Timelapse        "

. $PiCamHdr
. $CheckDir "$piTL"

if [ $? -eq 0 ]; then
    tput cup $(($start_row + 3)) $left_col; echo "Directory    : $piTL"
    tput cup $(($start_row + 4)) $left_col; echo "File Name(s) : $tlImg eg. (PiTl-160708-0934-0001.jpg)"
    if [ $numJpg -gt 0 ]; then
        CheckJPG $numJpg
    fi
    if [ $? -eq 0 ]; then
        GetInterval
        GetLength
        StartTL
    fi
fi
