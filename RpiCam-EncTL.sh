#!/bin/bash

#--------------------------------------------------------
# Decide whether to use full resolution (2592 * 1944) or cropped (1280 * 720). 
#--------------------------------------------------------

EncodeType ()
{
    local ansr=""
    local locRetVal=0
    local choiceOk=false

    tput cup $(($start_row + 5)) $left_col; echo "1. Full Resolution (2592 * 1944)"
    tput cup $(($start_row + 6)) $left_col; echo "2. Cropped resolution (1280 * 720)"
    tput cup $(($start_row + 7)) $left_col; echo "3. Exit - Return to Main Menu" 

    while [ $choiceOk = false ]; do 
       tput cup $(($start_row + 10)) $left_col; read -p "Enter your choice [1-3] : " ansr
       if [[ "$ansr" =~ ^-?[1-3]+$  ]]; then
          choiceOk=true
          encodeType=$ansr 
          if [ $ansr = "1" ]; then
             tlMp4="pitl_${tlDate}_${tlTime}.mp4"
          elif [ $ansr = "2" ]; then
             tlMp4="pitl_${tlDate}_${tlTime}_crop.mp4"
          else
             locRetVal=1
          fi 
       else
          msg="Choice must be 1,2 or 3."; . $DisplayMsg; . $PressEnter
       fi
       tput cup $(($start_row + 10)) $left_col; tput el 
    done

    tput cup $(($start_row + 4)) $left_col; echo "TimeLapse mp4 : $tlMp4"
    tput cup $(($start_row + 5))  $left_col; tput el 
    tput cup $(($start_row + 6))  $left_col; tput el 
    tput cup $(($start_row + 7))  $left_col; tput el 
    tput cup $(($start_row + 10)) $left_col; tput el 

    return $locRetVal
}

#--------------------------------------------------------
#   Check that MP4 file doesn't already exist. 
#--------------------------------------------------------

MP4Exists ()
{
    local ansr="n"
    local chceOk="n"
    local locRetVal=0

    tput cup $(($start_row + 6)) $left_col; echo "$tlOut exists."

    while [ $chceOk = "n" ]; do
       tput cup $(($start_row + 7)) $left_col; read -p "Delete it [yn] : " ansr 
       if [[ $ansr =~ [YyNn] ]]; then       
          chceOk="y"
          if [[ $ansr =~ [Yy] ]]; then
             rm ${tlOut}
          else
             locRetVal=1
             msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter
          fi
       else
          msg="Must by [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
       fi
       tput cup $(($start_row + 7)) $left_col; tput el 
    done

    tput cup $(($start_row + 6)) $left_col; tput el
    tput cup $(($start_row + 7)) $left_col; tput el

    return $locRetVal
}

#--------------------------------------------------------
# Encode jpg images using avconv.
#--------------------------------------------------------

EncodeTL ()
{
    local ansr="n"
    local encPid=0
    local chceOk="n"
    local tlBash="${piTL}/pitl_${tlDate}_${tlTime}.sh"
    local tlLog="${piTL}/pitl_${tlDate}_${tlTime}.avconvlog"
    local avConv01="nohup avconv -r 10 -i $jpgFile -r 10 -vcodec libx264 -crf 20 -g 15"
    local avConvCrop="-vf crop=2592:1458,scale=1280:720"

    $(echo "#!/bin/bash" > $tlBash)
    $(echo "rm $tlOut" >> $tlBash)
    $(chmod u+x $tlBash)

    tput cup $(($start_row + 6)) $left_col; echo "$numJpg jpg files found."

    while [ $chceOk = "n" ]; do
       tput cup $(($start_row + 7)) $left_col; read -p "Start encoding y/n : " ansr 
       if [[ $ansr =~ [YyNn] ]]; then       
          chceOk="y"
          if [[ $ansr =~ [Yy] ]]; then
             if [ $encodeType -eq 1 ]; then
                $(echo "$avConv01 $tlOut &> $tlLog &" >> $tlBash)
                $avConv01 $tlOut &> $tlLog &
             else
                $(echo "$avConv01 $avConvCrop $tlOut &> $tlLog &" >> $tlBash)
                $avConv01 $avConvCrop $tlOut &> $tlLog &
             fi
             encPid=$!
             msg="Encode started, PID is $encPid."; . $DisplayMsg; . $PressEnter
          else
             msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter
          fi
       else
          msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
       fi
       tput cup $(($start_row + 7)) $left_col; tput el
    done
}

#--------------------------------------------------------
# Main Routine - Start here. 
#--------------------------------------------------------

numJpg=$(ls -l $piTL/*.jpg 2> /dev/null | wc -l)
tlFile=$(ls $piTL/*0001.jpg 2> /dev/null)

encodeType=0
tlMp4=""
tlOut=""
tlDate=""
tlTime=""

hdrLne2="    Encode Timelapse    "

. $PiCamHdr
. $CheckDir "$piTL"

if [ $? -eq 0 ]; then
   tput cup $(($start_row + 3)) $left_col; echo "Directory     : $piTL"
   if [ $numJpg -gt 0 ]; then
      if [ ! -z $tlFile ]; then 
         IFS='_' read part_01 tlDate tlTime part_04 <<< "$tlFile"
         jpgFile="${piTL}/pitl_${tlDate}_${tlTime}_%04d.jpg"
         unset IFS
         EncodeType
         if [ $? -eq 0 ]; then
            tlOut="${piTL}/${tlMp4}"
            if [ -e "$tlOut" ]; then
                MP4Exists
                if [ $? -eq 0 ]; then
                    EncodeTL
                fi
            else
                EncodeTL
            fi
         fi
      else
         msg="First jpg file, 0001, not found, returning to main menu."; . $DisplayMsg; . $PressEnter
      fi
   else 
      msg="No jpg files found, returning to main menu."; . $DisplayMsg; . $PressEnter
   fi
else
   msg="Timelapse directory not found, returning to main menu."; . $DisplayMsg; . $PressEnter
fi
