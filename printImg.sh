#!/bin/bash

# 第一引数に指定した画像を、
# 第二引数の PTS で表示する。
#
# Useag:
# printImg TARGET_IMG_FILE TARGET_PTS_PATH

run_tty=${2}

# 作業ディレクトリ作成
work_dir=/tmp/sixelPreviewer
mkdir -p ${work_dir}

ext=${1##*.}
out_scale=0.9

read -r rows char_of_row term_width term_height <<< "`termsize.py ${run_tty}`"

if [ "${ext}" = "png" -o "${ext}" = "jpg" -o "${ext}" = "gif" ]; then
    cp ${1} ${work_dir}/tmp.${ext}
elif [ "${ext}" = "svg" ]; then
    convert ${1} ${work_dir}/tmp.png
elif [ "${ext}" = "mkd" -o "${ext}" = "markdown" ]; then
    echo '<html><head><meta charset="UTF-8" /></head><body>' > ${work_dir}/tmp.html
    markdown_py ${1} >> ${work_dir}/tmp.html
    echo '</body></html>' >> ${work_dir}/tmp.html
    phantomjs `type -P sp_capture.js` ${work_dir}/tmp.html ${term_width} ${work_dir}/tmp.png
elif [ "${ext}" = "ozcld" ]; then
    ozcld ${1} > ${work_dir}/tmp.dot
    dot -T png ${work_dir}/tmp.dot -o ${work_dir}/tmp.png
fi

read -r image_width image_height <<< `identify -format "%w %h" ${work_dir}/tmp.png`

w_scale=`echo "${term_width}/${image_width}" | bc`
h_scale=`echo "${term_height}/${image_height}" | bc`

if [ $w_scale -lt $h_scale ]; then
    size_opt="--width=`echo \"${term_width}*${out_scale}\" | bc | sed s/\.[0-9,]*$//g`"
else
    size_opt="--height=`echo \"${term_height}*${out_scale}\" | bc | sed s/\.[0-9,]*$//g`"
fi

img2sixel ${size_opt} ${work_dir}/tmp.png > ${run_tty}
