#!/bin/bash

tput bold
tput cup $(($start_row + 13)) $left_col; echo $msg
tput sgr0

