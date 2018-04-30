#!/bin/Bash

# --------------------------------------------
#   Display screen header 
# --------------------------------------------

tput clear
tput rev
tput cup $start_row $left_col; printf "%s" "$hdrLne1"
tput cup $(($start_row + 1)) $left_col; printf "%s" "$hdrLne2"
tput sgr0
