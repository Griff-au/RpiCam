#!/bin/bash

# ----------------------------
# Start VNC server
# ----------------------------

StartVnc ()
{
    local locretVal=0

    vncserver :1 2> /dev/null

    return $?
}

# ----------------------------
# Start  here
# ----------------------------

ipAddr=$(sed -e 's/^[ \t]*//;s/[ \t]*$//' <<<"$(hostname -I)")

tput clear
tput cup $start_row $left_col; tput rev; echo "   Raspicam Utilities  "
tput cup $(($start_row + 1)) $left_col; echo "       Start VNC       "
tput sgr0
tput cup $(($start_row + 3)) $left_col; echo "VNC will be started as below"
tput cup $(($start_row + 4)) $left_col; echo "http://$ipAddr:1"

tput cup $(($start_row + 6)) $left_col; read -p "Start VNC server y/n : " ansr

if [ $ansr = "y" ]; then
   StartVnc
   case $? in
      0)  tput cup $(($start_row + 7)) $left_col; echo "Ok, VNC Server started";;
      98) tput cup $(($start_row + 7)) $left_col; echo "VNC Server already started";;
      *)  tput cup $(($start_row + 7)) $left_col; echo "Returning to main menu - Unknown problem";;
   esac 
else
   tput cup $(($start_row + 7)) $left_col; echo "Returning to main menu - VNC not started"
fi  
