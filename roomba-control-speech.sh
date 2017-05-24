#!/bin/bash

#FIFO=/var/run/desk-control
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
        -jsgf ./conf/roomba.jsgf \
        -dict ./conf/roomba.dic \
        -inmic yes -kws_threshold 1e-03 \
        -logfn /dev/null \
        | /usr/bin/stdbuf -o0 /bin/egrep -v "^READY|^Listening" \
        > $FIFO
