#!/bin/bash

# -----------------------------------
# Check that MJPG streaming has been installed 
# -----------------------------------

ChkMjpg ()
{
    local locretVal=0
    local mjpgDir="/home/pi/mjpg-streamer-code-182"
 
    if [ -d $mjpgDir ]; then
       locretVal=0 
    else
       locretVal=1 
    fi 

    return $locretVal
}
 
# -----------------------------------
# Check that temp directory exists
# -----------------------------------


ChkTmp ()
{
    local tmpDir="/tmp/stream"

    if [ ! -d $tmpDir ]; then
       mkdir $tmpDir
    fi
}

# -----------------------------------
# Start MJPG streaming video 
# -----------------------------------

StartMjpg ()
{
    local myPid=0

    raspistill --nopreview -w 640 -h 480 -q 5 -o /tmp/stream/pic.jpg -tl 100 -t 9999999 -th 0:0:0 2> /dev/null &
    myPid=$!
    tput cup $(($start_row + 7)) $left_col; echo "$myPid started in background."

    LD_LIBRARY_PATH=/usr/local/lib mjpg_streamer -i "input_file.so -f /tmp/stream -n pic.jpg" -o "output_http.so -w /usr/local/www" 2> /dev/null &

}

# -----------------------------------
# Start here
# -----------------------------------

ipAddr=$(sed -e 's/^[ \t]*//;s/[ \t]*$//' <<<"$(hostname -I)")

tput clear
tput cup $start_row $left_col; tput rev; echo "   Raspicam Utilities  "
tput cup $(($start_row + 1)) $left_col; echo "      MJPG Video       "
tput sgr0
tput cup $(($start_row + 3)) $left_col; echo "Use URL below to view video from MJPG"
tput cup $(($start_row + 4)) $left_col; echo "http://$ipAddr:8080/"

ChkMjpg

if [ $? -eq 0 ]; then
   ChkTmp
   tput cup $(($start_row + 6)) $left_col; read -p "Start MJPG streaming video y/n : " ansr
   if [ $ansr = "y" ]; then
      StartMjpg
   else
      tput cup $(($start_row + 7)) $left_col; echo "Returning to Main Menu - No streaming video"
   fi
else
   tput cup $(($start_row + 7)) $left_col; echo "Returning to Main Menu - Check MJPG is installed"
fi
