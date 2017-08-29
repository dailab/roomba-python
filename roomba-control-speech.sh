#!/bin/bash

CURDIR=$(dirname $0);

FIFO=/var/run/roomba-control


if [ ! -e $FIFO ]; then
        echo "FIFO does not exit, stopping...";
	exit -1
        #echo "FIFO does not exit, creating it...";
        #mkfifo $FIFO
elif [ ! -p $FIFO ]; then
        echo "FIFO is a regular file, creating it...";
        rm -f $FIFO
        mkfifo $FIFO
fi
 
/usr/bin/stdbuf -o0 /usr/bin/pocketsphinx_continuous \
	-jsgf $CURDIR/conf/roomba.jsgf \
	-dict $CURDIR/conf/roomba.dic \
        -inmic yes -kws_threshold 1e-03 \
	-adcdev plughw:1 \
        -logfn /dev/null \
        | /usr/bin/stdbuf -o0 /bin/egrep -v "^READY|^Listening" \
        > $FIFO
