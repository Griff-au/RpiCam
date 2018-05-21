#!/bin/bash

# -------------------------------------------------------------------
#   Confirm sequence check. 
# -------------------------------------------------------------------

ConfSeq ()
{
    local ansr=""
    local locRetVal=0
    local chceOk="n"
    local missFleCnt=0

    tput cup $(($start_row + 3)) $left_col; echo "Directory : $piTL"
    tput cup $(($start_row + 4)) $left_col; echo "File Name : $tlFile"

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 6)) $left_col; read -p "Check file sequence [yn] " ansr
        if [[ $ansr =~ [YyNn] ]]; then
            chceOk="y"
            if [[ $ansr =~ [Yy] ]]; then 
                tput cup $(($start_row + 7)) $left_col; echo "Checking sequence." 
                CheckSeq
                missFleCnt=$?
                if [ $missFleCnt -gt 0 ]; then
                    msg="$missFleCnt files missing"; . $DisplayMsg; . $PressEnter
                    ConfReSeq "$missFleCnt"
                else
                    msg="$missFleCnt files missing"; . $DisplayMsg; . $PressEnter
                fi 
            else
                locRetVal=1
                msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter
            fi
        else
            msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
        fi
        tput cup $(($start_row + 6)) $left_col; tput el
    done

    return $locRetVal
}

# -------------------------------------------------------------------
#   Confirm re sequence of files. 
# -------------------------------------------------------------------

ConfReSeq ()
{
    local missFleCnt=$1
    local ansr=""
    local locRetVal=0
    local chceOk="n"

    tput cup $(($start_row + 3)) $left_col; echo "Directory : $piTL"
    tput cup $(($start_row + 4)) $left_col; echo "File Name : $tlFile"

    while [ $chceOk = "n" ]; do
        tput cup $(($start_row + 6)) $left_col; read -p "Resequence $missFleCnt files [yn] " ansr
        if [[ $ansr =~ [YyNn] ]]; then
            chceOk="y"
            if [[ $ansr =~ [Yy] ]]; then 
                tput cup $(($start_row + 7)) $left_col; echo "Resequencing files." 
                ReSeqJpg 
                if [ $? -eq 0 ]; then
                    msg="Resequence ok."; . $DisplayMsg; . $PressEnter
                else
                    msg="Problem with ReSequence."; . $DisplayMsg; . $PressEnter
                fi 
            else
                locRetVal=1
                msg="Ok, returning to main menu."; . $DisplayMsg; . $PressEnter
            fi
        else
            msg="Must be [Yy] or [Nn]."; . $DisplayMsg; . $PressEnter
        fi
        tput cup $(($start_row + 6)) $left_col; tput el
    done

    return $locRetVal
}

# -------------------------------------------------------------------
#   Check sequence of timelapse files. 
# -------------------------------------------------------------------

CheckSeq ()
{
    local fileCnt=1;
    local missFileCnt=0

    cd ${piTL}
    ls *.jpg > ${jpgFile}

    if [ -e $missJpg ]; then
        $(rm $missJpg)
    fi

    while read fileName
    do
        IFS=- read tlPref tlDate tlTime tlSeq <<< ${fileName}
        IFS=. read jpgSeq jpgExt <<< ${tlSeq}
        if [ $fileCnt -ne $jpgSeq ]; then
            while [ $fileCnt -lt $jpgSeq ]; do
                outFile=$(printf "%s-%s-%s-%04d.%s\n" ${tlPref} ${tlDate} ${tlTime} $((10#${fileCnt})) ${jpgExt})
                echo ${outFile} >> ${missJpg}
                ((fileCnt++))
                ((missFileCnt++))
            done
        fi  
        ((fileCnt++))
    done < ${jpgFile} 

    unset IFS

    return $missFileCnt
}

# -------------------------------------------------------------------
#   Resequence jpg files.
# -------------------------------------------------------------------

ReSeqJpg ()
{
    while read fileName
    do
        IFS=- read tlPref tlDate tlTime tlSeq <<< ${fileName}
        IFS=. read jpgSeq jpgExt <<< ${tlSeq}
        prevSeq=$(printf "%04d" $((10#${jpgSeq} - 1)))
        prevFile="${tlPref}-${tlDate}-${tlTime}-${prevSeq}.jpg"
        $(cp ${prevFile} ${fileName})
    done < ${missFile} 

    unset IFS
}

# -------------------------------------------------------------------
# 	Main routine - Start here.
# -------------------------------------------------------------------

jpgFile="tlJpg.out"
tlJpg="${piTL}/${jpgFile}"
missFile="missingjpg.out"
missJpg="${piTL}/${missFile}"
hdrLne2="Check TimeLapse Sequence"

. $PiCamHdr
. $CheckDir "$piTL"

if [ $? -eq 0 ]; then
    numJpg=$(ls -l $piTL/*.jpg 2> /dev/null | wc -l)
    tlFile=$(ls $piTL/*0001.jpg 2> /dev/null)
    if [ $numJpg -gt 0 ]; then
        ConfSeq 
    else
        msg="No jpg files found, returning to main menu."; . $DisplayMsg; . $PressEnter
    fi
fi
