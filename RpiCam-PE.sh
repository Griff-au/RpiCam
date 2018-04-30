#!/bin/bash

tput bold
tput cup $(($start_row + 14)) $left_col; read -p "Press [Enter] key to continue... "
tput cup $(($start_row + 13)) $left_col; tput el
tput cup $(($start_row + 14)) $left_col; tput el
tput sgr0
