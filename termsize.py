#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
Get terminal size.
"""

__author__ = "mikoto2000 <mikoto2000@gmail.com>"
__version__ = "1.0.0"
__date__ = "22 Apr 2015"

__USEAGE__ = """Useage: termsize.py PATH_TO_PTS"""

import struct,fcntl,termios,sys;

"""
Get terminal size.

Return terminal size array.
[0] : line count.
[1] : charactor count of line.
[2] : pixels of width.
[3] : pixels of height.
"""
def getTermSize(ptsPath) :
    termSize=struct.unpack(
        'HHHH',
        fcntl.ioctl(
            open(ptsPath),
            termios.TIOCGWINSZ,
            '\0' * 8))
    return termSize

if __name__ == "__main__" :

    if len(sys.argv) != 2 :
        print(__USEAGE__)
        exit()

    if sys.argv[1] == "--help"\
        or sys.argv[1] == "-h" :
        print(__USEAGE__)
        exit()

    termSize = getTermSize(sys.argv[1])
    print(termSize[0], termSize[1], termSize[2], termSize[3])
