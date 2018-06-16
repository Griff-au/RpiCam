#!/bin/bash

# -----------------------------------
# Mount Toshiba USB Stick on /dev/sda1
# -----------------------------------

device="/dev/sda1"
fileSystem="/media/usbdrive"
retVal=0

hdrLne2="       Mount USB       " 
. $PiCamHdr

tput sgr0
tput cup $(($start_row + 3)) $left_col; echo "Device      : $device"
tput cup $(($start_row + 4)) $left_col; echo "File System : $fileSystem"
tput cup $(($start_row + 6)) $left_col; read -p "Mount USB Drive y/n : " ansr

if [ "$ansr" = "y" ]; then
   sudo mount -t vfat -o uid=pi,gid=pi $device $fileSystem  2> /dev/null
   retVal=$?
   if [ $retVal -eq 0 ]; then
      msg="USB Drive mounted Ok."; . $DisplayMsg; . $PressEnter
   else
      if [ $retVal -eq 32 ]; then 
         msg="$fileSystem already mounted."; . $DisplayMsg; . $PressEnter
      else
         msg="Unable to mount $fileSystem."; . $DisplayMsg; . $PressEnter
      fi
   fi
fi
