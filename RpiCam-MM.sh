#!/bin/bash

# --------------------------------------------
#   Define system variables and menu array. 
# --------------------------------------------

export piHome="/home/pi"
export piStills="${piHome}/Pictures/Stills"
export piTL="${piHome}/Pictures/Timelapse"
export piVideo="${piHome}/Videos"
export piCamDir="${piHome}/Shell/RpiCam"
export PiCamHdr="${piCamDir}/RpiCam-Hdr.sh"
export DisplayMsg="${piCamDir}/RpiCam-DM.sh"
export PressEnter="${piCamDir}/RpiCam-PE.sh"
export CheckDir="${piCamDir}/RpiCam-ChkDir.sh"
export msg=""
export start_row=5
export left_col=$(($(tput cols) / 3))
export rowOffSet=3
export mnuOption=1
export hdrLne1="   Raspicam Utilities   "
export hdrLne2="        Main Menu       "

mnuArray=(
            "Single Shot"                   "RpiCam-Still.sh" 
            "Start Timelapse"               "RpiCam-TL.sh" 
            "Take Video"                    "RpiCam-Video.sh"
            "Start VLC Streaming video"     "RpiCam-VLC.sh"
            "Check Timelapse sequence"      "RpiCam-TLSeq.sh"
            "Encode Timelapse"              "RpiCam-EncTL.sh"
            "Mount USB"                     "RpiCam-MntUSB.sh"
            "Start VNC Server"              "RpiCam-VNC.sh"
            "Exit/Stop"
        );

# --------------------------------------------
#   Main loop, display main menu. Option between 1 or 9 must be selected. 
# --------------------------------------------

while :
do
    . $PiCamHdr
 
    for ((mnuItem=0; mnuItem<=${#mnuArray[*]}; mnuItem+=2)); do
        tput cup $(($start_row + $rowOffSet))  $left_col; echo "[$(($mnuOption))] ${mnuArray[$mnuItem]}"
        rowOffSet=$(($rowOffSet + 1))
        mnuOption=$(($mnuOption + 1))
    done

    tput bold
    tput cup $(($start_row + 13)) $left_col 
    read -p "Enter your menu choice [1-9]: " mnuChce
    tput sgr0

    if [[ "$mnuChce" =~ ^-?[1-9]+$ ]]; then
        if [ $mnuChce -ge 1 ] && [ $mnuChce -le 8 ]; then
            mnuChce=$(($mnuChce + ($mnuChce - 1)))
            . ${piCamDir}/${mnuArray[$mnuChce]}
        elif [ $mnuChce -eq 9 ]; then
            clear
            exit 0
        else
            msg="Value must be between 1 and 9."; . $DisplayMsg; . $PressEnter 
        fi
    else
        msg="Value must be an integer between 1 and 9."; . $DisplayMsg; . $PressEnter 
    fi

    rowOffSet=3
    mnuOption=1
    hdrLne2="        Main Menu       "
done
