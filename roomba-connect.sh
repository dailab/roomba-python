#!/bin/bash

CURDIR=$(dirname $0);

in_file="test-input.txt";

function scan_rfcomm {
	if [ -f $in_file ]; then
		awk '$0~/^Searching for SP on/{hw_addr=$5} $0~/^Service Name/{name=$3} $1~/"RFCOMM"/{print hw_addr " " name}' test-input.txt
	else
		sudo sdptool search SP | awk '$0~/^Searching for SP on/{hw_addr=$5} $0~/^Service Name/{name=$3} $1~/"RFCOMM"/{print hw_addr " " name}'
	fi
}

function rkill {
	#echo "rkill $@..."
	for p in "$@"; do
		#echo "p=$p";
		child_pids=$(/usr/bin/pgrep -P $p)

		rkill $child_pids;

		#echo "killing $p";
		sudo kill $p 2>/dev/null;
	done
}

echo "scanning devices..."
devices=$(scan_rfcomm);

if [ -z "$devices" ]; then
	echo "no device found...";
	zenity --error "No device found!";
	exit -1;
fi

dev=$(zenity --list --text="Text..." --column="Address" --column "Name" $devices)
echo "dev=$dev";

if [ -z $dev ]; then
	echo "no device selected...";
	zenity --error --text="No device selected!";
	exit -1;
fi

echo "connecting to " $dev

sudo rfcomm -r connect 0 $dev &
connect_pid=$!

echo "connect_pid=$connect_pid";

hcitool rssi $dev > /dev/null
c=$?

while [ $c -eq 1 ]; do
	sleep 1;
	echo ".";
	hcitool rssi $dev > /dev/null
	c=$?
done

echo "connected to $dev";


# starting roomba control process

sudo $CURDIR/roomba-control.sh &
control_pid=$!
echo "roomba_control_pid=$control_pid"

sleep 1

sudo $CURDIR/roomba-control-speech.sh &
speech_pid=$!
echo "roomba_speech_pid=$speech_pid"

sleep 1
connect_child_pid=$(/usr/bin/pgrep -P $connect_pid)
echo "connect_child_pid=$connect_child_pid";

zenity --info --text="connected to $dev" --ok-label="disconnect"

rkill $speech_pid $control_pid

echo "disconnecting...";

echo "waiting for connection to be closed...";
while $(sudo /bin/kill -0 $connect_pid 2>/dev/null); do
	echo "killing connect process $connect_pid...";
	#echo "sudo /bin/kill -INT $connect_child_pid;"
	sudo /bin/kill -INT $connect_child_pid 2>/dev/null;
	sleep 1;
done

wait -n $connect_pid

echo "done.";


