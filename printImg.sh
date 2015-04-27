#!/bin/bash

# 第一引数に指定した画像を、
# 第二引数の PTS で表示する。
#
# Useag:
# printImg TARGET_IMG_FILE TARGET_PTS_PATH

run_tty=${2}

ext=${1##*.}
out_scale=0.9

read -r rows char_of_row term_width term_height <<< "`termsize.py ${run_tty}`"

if [ "${ext}" = "svg" ]; then
    convert ${1} /tmp/tmp.png
elif [ "${ext}" = "ozcld" ]; then
    ozcld ${1} > /tmp/tmp.dot
    dot -T png /tmp/tmp.dot -o /tmp/tmp.png
fi

read -r image_width image_height <<< `identify -format "%w %h" /tmp/tmp.png`

w_scale=`echo "${term_width}/${image_width}" | bc`
h_scale=`echo "${term_height}/${image_height}" | bc`

if [ $w_scale -lt $h_scale ]; then
    size_opt="--width=`echo \"${term_width}*${out_scale}\" | bc | sed s/\.[0-9,]*$//g`"
else
    size_opt="--height=`echo \"${term_height}*${out_scale}\" | bc | sed s/\.[0-9,]*$//g`"
fi

img2sixel ${size_opt} /tmp/tmp.png > ${run_tty}
