#!/bin/bash
 
# -----------------------------------
# Check that VLC is installed
# -----------------------------------

CheckVLC ()
{
    local locretVal=0
    local vlcDir="/usr/bin/vlc"

    if [ -f $vlcDir ]; then
       locretVal=0  
    else
       locretVal=1 
    fi

    return $locretVal
}

# -----------------------------------
#  Decide which stream to use RTSP or HTTP 
# -----------------------------------

VLCStream ()
{
    local ansr=0
    local locretVal=0
    local nochoiceMade=true

    while [ $nochoiceMade = true ]; do
       tput cup $(($start_row + 3)) $left_col; echo "Choose ouput stream to use below"
       tput cup $(($start_row + 5)) $left_col; echo "1. Send output to RTSP"
       tput cup $(($start_row + 6)) $left_col; echo "2. Send output to HTTP"
       tput cup $(($start_row + 7)) $left_col; echo "x. Exit - Return to Main Menu" 
       tput cup $(($start_row + 9)) $left_col; read -p "Enter your choice 1,2 or x : " ansr 
       if [[ $ansr =~ [1|2|x|X] ]]; then
          nochoiceMade=false
          vlcStream=$ansr
          if [[ $ansr =~ [xX] ]]; then
             locretVal=1
          fi
       else
          tput cup $(($start_row + 10)) $left_col; echo "Choice must be 1,2 or x"
       fi
    done

    if [[ $ansr =~ [1|2] ]]; then
       tput cup $(($start_row + 3)) $left_col; tput el 
       tput cup $(($start_row + 5)) $left_col; tput el 
       tput cup $(($start_row + 6)) $left_col; tput el 
       tput cup $(($start_row + 7)) $left_col; tput el 
       tput cup $(($start_row + 9)) $left_col; tput el 
    fi

    return $locretVal
}

# -----------------------------------
# Start VLC streaming video 
# -----------------------------------

StartVlc ()
{
    local myPid=0

    if [ $vlcStream == 1 ]; then
       raspivid -o - -t 0 -n -w 600 -h 400 -fps 12 | cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/}' :demux=h264 2> /dev/null &
    else
       raspivid -o - -t 0 -vf |cvlc -v stream:///dev/stdin --sout '#standard{access=http,mux=ts,dst=:8554}' :demux=h264 2> /dev/null 
    fi

    myPid=$!
    tput cup $(($start_row + 7)) $left_col; echo "$myPid started in background"
}

# -----------------------------------
# Start here
# rtsp://localhost:8554/
# -----------------------------------
 
ipAddr=$(sed -e 's/^[ \t]*//;s/[ \t]*$//' <<<"$(hostname -I)")
vlcStream=0

tput clear
tput cup $start_row $left_col; tput rev; echo "   Raspicam Utilities  "
tput cup $(($start_row + 1)) $left_col; echo "       VLC Video       "
tput sgr0

CheckVLC 

if [ $? -eq 0 ]; then
   VLCStream
   if [ $? -eq 0 ]; then
      tput cup $(($start_row + 3)) $left_col; echo "Use URL below to view video from within VLC"
      if [[ $vlcStream =~ [1|2] ]]; then
         if [ $vlcStream == 1 ]; then
            tput cup $(($start_row + 4)) $left_col; echo "rtsp://$ipAddr:8554/"
         else
            tput cup $(($start_row + 4)) $left_col; echo "http://$ipAddr:8554/"
         fi
         tput cup $(($start_row + 6)) $left_col; read -p "Start streaming VLC Video y/n : " ansr
         if [ $ansr = "y" ]; then
            StartVlc
         else
            tput cup $(($start_row + 7)) $left_col; echo "Returning to main menu - No streaming video"
         fi 
      fi
   else
      tput cup $(($start_row + 10)) $left_col; echo "Returning to main menu - No Streaming Video" 
   fi
else
   tput cup $(($start_row + 7)) $left_col; echo "Returning to main menu -  Check VLC is installed"
fi
