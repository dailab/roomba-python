import create
import time
import io
import os
import sys
import argparse

# define silence
r = 30

# map note names in the lilypad notation to irobot commands
c4 = 60
cis4 = des4 = 61
d4 = 62
dis4 = ees4 = 63
e4 = 64
f4 = 65
fis4 = ges4 = 66
g4 = 67
gis4 = aes4 = 68
a4 = 69
ais4 = bes4 = 70
b4 = 71
c5 = 72
cis5 = des5 = 73
d5 = 74
dis5 = ees5 = 75
e5 = 76
f5 = 77
fis5 = ges5 = 78
g5 = 79
gis5 = aes5 = 80
a5 = 81
ais5 = bes5 = 82
b5 = 83
c6 = 84
cis6 = des6 = 85
d6 = 86
dis6 = ees6 = 87
e6 = 88
f6 = 89
fis6 = ges6 = 90

# define some note lengths
# change the top MEASURE (4/4 time) to get faster/slower speeds
MEASURE = 160
HALF = MEASURE/2
Q = MEASURE/4
E = MEASURE/8
Ed = MEASURE*3/16
S = MEASURE/16

MEASURE_TIME = MEASURE/64.

ROOMBA_PORT = "/dev/rfcomm0"
FIFO_PATH = "/tmp/roombaCommands"

parser = argparse.ArgumentParser(description="Roomba Voice Command Control Software")
parser.add_argument("-k", dest="keyword", help="Keyword for addressing the roomba", default="")
parser.add_argument("-p", dest="path", help="path for creating the FIFO", default=FIFO_PATH)
args = parser.parse_args()
print(args.keyword)
FIFO_PATH = args.path
print("created fifo in "+ FIFO_PATH)
telekom = [(c4,S), (c4,S), (c4,S), (e4,S), (c4,Q)]
os.mkfifo(FIFO_PATH)
robot = create.Create(ROOMBA_PORT, create.SAFE_MODE)
robot.setSong(1, telekom)

def clean_up():
    print("clean up and exit")
    os.unlink(FIFO_PATH)
    robot.close()
    sys.exit(0)

def main():
    exit_loop = False
    fifo = open(FIFO_PATH, "r")
    while exit_loop == False:
            line = fifo.readline()
            if line != "":
                line = line.replace(args.keyword, "").strip(" ").strip("\n")
                print(line)

                if line == "clean":
                    robot.toSafeMode()
                    time.sleep(.5)
                    print("starting to clean")
                    robot._write(create.CLEAN)
                if line == "spot":
                    robot.toSafeMode()
                    time.sleep(.5)
                    print("starting to spot clean")
                    robot._write(create.SPOT)
                if line == "stop":
                    print("stopping")
                    robot.toSafeMode()
                    time.sleep(.5)
                if line == "dock":
                    robot.toSafeMode()
                    time.sleep(.5)
                    print("seeking dock")
                    robot._write(create.FORCESEEKINGDOCK)
                if line == "jingle":
                    robot.toSafeMode()
                    time.sleep(.5)
                    robot.playSongNumber(1)
                if line == "close":
                    exit_loop = True


try:
    main()
except:
    print("\nexception -> ")
clean_up()