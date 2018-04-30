#!/bin/bash

# -------------------------------------------------------------
# Check if Time Lapse directory is empty.
# -------------------------------------------------------------
 
CheckJPG ()
{
    local locretVal=0
    local ansr="n"
    local chceOk="n"
    local numJpg=$(ls -l $piTL/*.jpg 2> /dev/null | wc -l)
    
    while [ $chceOk = "n" ]; do
        if [ $numJpg -gt 0 ]; then
            tput cup $(($start_row + 6)) $left_col; echo "Currently $numJpg files in $piTL"
            tput cup $(($start_row + 7)) $left_col; read -p "Do you want to delete them y/n : " ansr
            if [ ! -z $ansr ]; then
                if [ $ansr = "y" ]; then
                    rm $piTL/*.jpg
                    if [ $? -ne 0 ]; then
                        msg="Unable to delete existing files, check priveleges, terminating."; . $DisplayMsg; . $PressEnter
                        locretVal=1
                    else
                        msg="All $numJpg files deleted."; . $DisplayMsg; . $PressEnter
                        chceOk="y"
                    fi
                elif [ $ansr = "n" ]; then
                    msg="Keeping existing files."; . $DisplayMsg; . $PressEnter
                    chceOk="y"
                else
                    msg="Choice needs to be Y or N."; . $DisplayMsg; . $PressEnter
                 fi
            else
                 msg="No choice made, choice needs to be Y or N."; . $DisplayMsg; . $PressEnter
            fi
        else
            chceOk="y"
        fi
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

      if [[ "$tlInt" =~ ^-?[0-9]+$ ]]; then
         if [ $tlInt -gt 0 ]; then
            intOk="y"
         else
            msg="Time interval must be greater than zero (0)."; . $DisplayMsg; . $PressEnter
         fi
      else
         msg="Time interval must be an integer greater then zero (0)."; . $DisplayMsg; . $PressEnter
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
      tput cup $(($start_row + 7)) $left_col; read -p "Length of time to run in minutes : " tlTime

      if [[ "$tlTime" =~ ^-?[0-9]+$ ]]; then
         if [ $tlTime -gt 0 ]; then
            lenOk="y"
         else
            msg="Length of time must be greater than zero (0)."; . $DisplayMsg; . $PressEnter
         fi
      else
         msg="Length of time must be an integer greater then zero (0)."; . $DisplayMsg; . $PressEnter
      fi
   done
}

# -------------------------------------------------------------
# Run Time Lapse in background. 
# -------------------------------------------------------------
 
StartTL ()
{
    local ansr="n"
    local thouSec=$((tlInt * 1000))
    local thouHrs=$((tlTime * 60000))
    local tlPid=0

    tput cup $(($start_row + 9)) $left_col; read -p "Start timelapse y/n : " ansr 

    if [ ! -z $ansr ]; then
        if [ "$ansr" = "y" ]; then
            nohup raspistill -t "$thouHrs" -tl "$thouSec" -o $tlFile -rot 180 2> /dev/null &
            tlPid=$!
            WriteToLog $tlPid
            msg="Timelapse started, PID is $tlPid."; . $DisplayMsg; . $PressEnter
        elif [ $ansr = "n" ]; then
            msg="No selected, timelapse not started, returning to main menu."; . $DisplayMsg; . $PressEnter 
        else
            msg="Answer wasn't either Y or N, assuming no start, returning to main menu."; . $DisplayMsg; . $PressEnter
        fi
    else
        msg="No choice made, assuming no start, returning to main menu."; . $DisplayMsg; . $PressEnter
    fi
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
tlInt=0
tlTime=0

hdrLne2="       Timelapse        "

. $PiCamHdr
. $CheckDir "$piTL"

if [ $? -eq 0 ]; then
    tput cup $(($start_row + 3)) $left_col; echo "Directory    : $piTL"
    tput cup $(($start_row + 4)) $left_col; echo "File Name(s) : $tlImg eg. (PiTl-160708-0934-0001.jpg)"
    CheckJPG
    if [ $? -eq 0 ]; then
        GetInterval
        GetLength
        StartTL
    fi
fi
