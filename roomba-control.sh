#!/bin/sh

FIFO=/var/run/roomba-control

python demo.py -k robot -p $FIFO
