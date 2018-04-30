#!/bin/bash

# -----------------------------------
# Mount Toshiba USB Stick on /dev/sda1
# -----------------------------------

device="/dev/sda1"
fileSystem="/media/usbstick"
retVal=0

tput clear
tput cup $start_row $left_col 
tput rev 
echo "   Raspicam Utilities  "
tput cup $(($start_row + 1)) $left_col 
echo "       Mount USB       " 
tput sgr0
tput cup $(($start_row + 3)) $left_col; echo "Device      : $device"
tput cup $(($start_row + 4)) $left_col; echo "File System : $fileSystem"
tput cup $(($start_row + 6)) $left_col; read -p "Mount USB Drive y/n : " ansr

if [ "$ansr" = "y" ]; then
   sudo mount -t vfat -o uid=pi,gid=pi $device $fileSystem  2> /dev/null
   retVal=$?
   if [ $retVal -eq 0 ]; then
      tput cup $(($start_row + 7)) $left_col; echo "USB Drive mounted ok."
   else
      if [ $retVal -eq 32 ]; then 
         tput cup $(($start_row + 7)) $left_col; echo "$fileSystem already mounted"
      else
         tput cup $(($start_row + 7)) $left_col; echo "Returning to Main Menu - Unable to mount $fileSystem"
      fi
   fi
fi
