#!/bin/bash

# 第一引数に指定した画像を、
# 第二引数の PTS で表示する。
#
# Useag:
# printImg TARGET_IMG_FILE [TARGET_PTS_PATH]


usage() {
    echo "Useag: printImg [OPTIONS] TARGET_IMG_FILE [TARGET_PTS_PATH]"
    echo
    echo "TARGET_PTS_PATH:"
    echo "  Output image pts.(ex: /dev/pts/0, /dev/tty0)"
    echo "  default : 'tty' command result."
    echo
    echo "Options:"
    echo "  -h, --help : print help."
    echo "  -c, --css CSS_PATH : stylesheet path.(markdown only.)"
    echo "  -w : fit width mode."
    echo
    exit 1
}

# オプション抽出
while [ -n "$1" ]
do
    case "${1}" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '-c'|'--css' )
            shift 1
            css_path=${1}
            shift 1
            ;;
        '-w' )
            fit_width_mode="yes"
            shift 1
            ;;
        *)
            param+=( "${1}" )
            shift 1
            ;;
    esac
done

# オプション以外の抽出
target_img_file=${param[0]}

if [ ${#param[@]} -lt 2 ]; then
    run_tty=`tty`
else
    run_tty=${param[1]}
fi

# 作業ディレクトリ作成
work_dir=/tmp/sixelPreviewer
mkdir -p ${work_dir}

ext=${param[0]##*.}
out_scale=0.9

read -r rows char_of_row term_width term_height <<< "`termsize.py ${run_tty}`"

if [ "${ext}" = "png" -o "${ext}" = "jpg" -o "${ext}" = "gif" ]; then
    convert ${target_img_file} ${work_dir}/tmp.png
elif [ "${ext}" = "svg" ]; then
    convert ${target_img_file} ${work_dir}/tmp.png
elif [ "${ext}" = "htm" -o "${ext}" = "html" ]; then
    cp ${target_img_file} ${work_dir}/tmp.html
    phantomjs `type -P sp_capture.js` ${work_dir}/tmp.html ${term_width} ${work_dir}/tmp.png
elif [ "${ext}" = "mkd" -o "${ext}" = "markdown" ]; then
    if type pandoc > /dev/null 2>&1; then
        # css が指定されていれば設定する。
        css_opt=''
        if [ "${css_path}" != "" ]; then
            css_opt="--css file://`realpath ${css_path}`"
        fi
        pandoc -i ${target_img_file} -o ${work_dir}/tmp.html -t html5 --standalone ${css_opt}
    else
        echo '<html><head><meta charset="UTF-8" />' > ${work_dir}/tmp.html
        # css が指定されていれば挿入する。
        if [ "${css_path}" != "" ]; then
            echo '<link rel="stylesheet" href="'file://`realpath ${css_path}`'"></link>' >> ${work_dir}/tmp.html
        fi
        echo '</head><body>' >> ${work_dir}/tmp.html
        markdown_py ${target_img_file} >> ${work_dir}/tmp.html
        echo '</body></html>' >> ${work_dir}/tmp.html
    fi
    phantomjs `type -P sp_capture.js` ${work_dir}/tmp.html ${term_width} ${work_dir}/tmp.png
elif [ "${ext}" = "ozcld" ]; then
    ozcld ${target_img_file} > ${work_dir}/tmp.dot
    dot -T png ${work_dir}/tmp.dot -o ${work_dir}/tmp.png
fi

read -r image_width image_height <<< `identify -format "%w %h" ${work_dir}/tmp.png`

w_scale=`echo "${term_width}/${image_width}" | bc`
h_scale=`echo "${term_height}/${image_height}" | bc`

if [ "$fit_width_mode" ]; then
    size_opt="--width=`echo \"${term_width}\"`"
elif [ "$fit_width_mode" -o  $w_scale -lt $h_scale ]; then
    size_opt="--width=`echo \"${term_width}*${out_scale}\" | bc | sed s/\.[0-9,]*$//g`"
else
    size_opt="--height=`echo \"${term_height}*${out_scale}\" | bc | sed s/\.[0-9,]*$//g`"
fi

img2sixel ${size_opt} ${work_dir}/tmp.png > ${run_tty}

if [ -e "${work_dir}/tmp.png" ]; then
    rm ${work_dir}/tmp.png
fi

if [ -e "${work_dir}/tmp.html" ]; then
    rm ${work_dir}/tmp.html
fi
