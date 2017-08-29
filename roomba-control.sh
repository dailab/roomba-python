#!/bin/bash

CURDIR=$(dirname $0);

FIFO=/var/run/roomba-control

python $CURDIR/demo.py -k robot -p $FIFO
