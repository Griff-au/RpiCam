#!/bin/bash
 
# -----------------------------------
# Check that VLC is installed
# -----------------------------------

CheckVLC ()
{
    local locRetVal=0
    local vlcDir="/usr/bin/vlc"

    if [ -f $vlcDir ]; then
       locRetVal=0  
    else
       locRetVal=1 
    fi

    return $locRetVal
}

# -----------------------------------
#  Decide which stream to use RTSP or HTTP 
# -----------------------------------

VLCStream ()
{
    local ansr=0
    local locRetVal=0
    local chceOk="n"
    local vlcProt=""
    local vlcPort="8554"
    local ipAddr=$(sed -e 's/^[ \t]*//;s/[ \t]*$//' <<<"$(hostname -I)")

    tput cup $(($start_row + 3)) $left_col; echo "Choose ouput stream to use below"
    tput cup $(($start_row + 5)) $left_col; echo "1. Send output to RTSP"
    tput cup $(($start_row + 6)) $left_col; echo "2. Send output to HTTP"
    tput cup $(($start_row + 7)) $left_col; echo "3. Exit - Return to Main Menu" 

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 9)) $left_col; tput bold; read -p "Enter your choice 1,2 or 3 : " ansr; tput sgr0
        if [[ "$ansr" =~ ^-?[1-3]+$ ]]; then
            chceOk="y"
            vlcStream=$ansr
            if [ $ansr -eq 1 ]; then
                vlcProt="rtsp"
            elif [ $ansr -eq 2 ]; then
                vlcProt="http"
            else
                vlcStream=0
                locRetVal=1
            fi
        else
            msg="Choice must be 1,2 or 3"; . $DisplayMsg; . $PressEnter
        fi
        tput cup $(($start_row + 9)) $left_col; tput el
    done

    if [[ $ansr =~ [1|2] ]]; then
        tput cup $(($start_row + 3)) $left_col; echo "Use URL below to view video from within VLC"
        tput cup $(($start_row + 4)) $left_col; echo "$vlcProt://$ipAddr:$vlcPort/"
        tput cup $(($start_row + 5)) $left_col; tput el 
        tput cup $(($start_row + 6)) $left_col; tput el 
        tput cup $(($start_row + 7)) $left_col; tput el 
        tput cup $(($start_row + 9)) $left_col; tput el 
    fi

    return $locRetVal
}

# -----------------------------------
# Start VLC streaming video 
# -----------------------------------

StartVlc ()
{
    local chceOk="n"
    local ansr=""
    local vlcPid=0

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 6)) $left_col; read -p "Start streaming VLC Video [yn] : " ansr
        if [[ $ansr =~ [YyNn] ]]; then
            chceOk="y"
            if [[ $ansr =~ [Yy] ]]; then
                if [ $vlcStream -eq 1 ]; then
                    raspivid -o - -t 0 -n -w 600 -h 400 -fps 12 | cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://:8554/}' :demux=h264 2> /dev/null &
                else
                    raspivid -o - -t 0 -vf |cvlc -v stream:///dev/stdin --sout '#standard{access=http,mux=ts,dst=:8554}' :demux=h264 2> /dev/null &
                fi
                vlcPid=$!
                msg="VLC started, PID is $vlcPid."; . $DisplayMsg; . $PressEnter
            else
                msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter
            fi
        else
            msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
        fi
        tput cup $(($start_row + 6)) $left_col; tput el
    done
}

# -----------------------------------
#   Main routine - Start here
# -----------------------------------

vlcStream=0

hdrLne2="        VLC Video       "

. $PiCamHdr

CheckVLC 

if [ $? -eq 0 ]; then
   VLCStream
   if [ $? -eq 0 ]; then
      if [ $vlcStream -gt 0 ]; then
         StartVlc
      fi
   fi
else
   msg="Check VLC is installed, returning to main menu."; . $DisplayMsg; . $PressEnter
fi
