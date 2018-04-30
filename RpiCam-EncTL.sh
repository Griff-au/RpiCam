#!/bin/bash

#--------------------------------------------------------
# Decide whether to use full resolution (2592 * 1944) or cropped (1280 * 720). 
#--------------------------------------------------------

EncodeType ()
{
    local ansr=""
    local locretVal=0
    local choiceOk=false

    while [ $choiceOk = false ]; do 
       tput cup $(($start_row + 6)) $left_col; echo "1. Full Resolution (2592 * 1944)"
       tput cup $(($start_row + 7)) $left_col; echo "2. Cropped resolution (1280 * 720)"
       tput cup $(($start_row + 8)) $left_col; echo "x. Exit - Return to Main Menu" 
       tput cup $(($start_row + 10)) $left_col; read -p "Enter your choice 1,2,x : " ansr
       if [[ $ansr =~ [1|2|x|X] ]]; then
          choiceOk=true
          encodeType=$ansr 
          if [ $ansr = "1" ]; then
             tlMp4="rpi_tl_"$tlDate"_full_out.mp4"
          elif [ $ansr = "2" ]; then
             tlMp4="rpi_tl_"$tlDate"_crop_out.mp4"
          fi 
          if [[ $ansr =~ [xX] ]]; then
             locretVal=1
          fi
       else
          tput cup $(($start_row + 11)) $left_col; echo "Choice must be 1,2,x"
       fi
    done
 
    tput cup $(($start_row + 4)) $left_col; echo "TimeLapse mp4 : $tlMp4"
    tput cup $(($start_row + 6))  $left_col; tput el 
    tput cup $(($start_row + 7))  $left_col; tput el 
    tput cup $(($start_row + 8))  $left_col; tput el 
    tput cup $(($start_row + 10)) $left_col; tput el 

    return $locretVal
}

#--------------------------------------------------------
# Encode jpg images using avconv.
#--------------------------------------------------------

EncodeTL ()
{
    local ansr="n"
    local myPid=0

    tlOut="${tlDir}/${tlMp4}"

    tput cup $(($start_row + 6)) $left_col; echo "$numJpg jpg files found."
    tput cup $(($start_row + 7)) $left_col; read -p "Start encoding y/n : " ansr 

    if [ $ansr = "y" ]; then
       if [ $encodeType -eq 1 ]; then
          nohup avconv -r 10 -i $jpgFile -r 10 -vcodec libx264 -crf 20 -g 15 $tlOut 2> /dev/null &
#          nohup avconv -r 10 -i $jpgFile -r 10 -vcodec libx264 -crf 20 -g 15 $tlOut 
       else
          nohup avconv -r 10 -i $jpgFile -r 10 -vcodec libx264 -crf 20 -g 15 -vf crop=2592:1458,scale=1280:720 $tlOut 2> /dev/null & 
       fi
       myPid=$!
       tput cup $(($start_row + 8)) $left_col; echo "$myPid started with NOHUP in background"
    fi
}

#--------------------------------------------------------
# Main Routine - Start here. 
#--------------------------------------------------------

rpiDir=~/Pictures
tlDir=${rpiDir}/Timelapse
numJpg=$(ls -l $tlDir/*.jpg 2> /dev/null | wc -l)
tlFile=$(ls $tlDir/*0001.jpg 2> /dev/null)
encodeType=0
tlDate=""

tput clear
tput cup $start_row $left_col 
tput rev 
echo "   Raspicam Utilities  "
tput cup $(($start_row + 1)) $left_col 
echo "    Encode Timelapse   "
tput sgr0
tput cup $(($start_row + 3)) $left_col; echo "Directory     : $tlDir"

if [ -d $tlDir ]; then
   if [ $numJpg -gt 0 ]; then
      if [ ! -z $tlFile ]; then 
         IFS='_' read part_01 part_02 tlDate part_04 <<< "$tlFile"
         jpgFile=${tlDir}"/rpi_tl_"$tlDate"_%04d.jpg"
         unset IFS
         EncodeType
         if [ $? -eq 0 ]; then
            EncodeTL
         fi
      else
         tput cup $(($start_row + 7)) $left_col; echo "Returning to Main Menu - First JPG file, 0001, not found"
      fi
   else 
      tput cup $(($start_row + 7)) $left_col; echo "Returning to Main Menu - No JPG files found"
   fi
else
   tput cup $(($start_row + 7)) $left_col; echo "Returning to Main Menu - $tlDir not found"
fi
