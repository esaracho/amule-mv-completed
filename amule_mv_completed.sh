#!/bin/bash

set -e
#name of the downloaded file with full path 
FILE=$1
#total time the download was active 
DTIME=$2
#1 for rest (time to share - active download time), any other integer for fixed (fixed time to share)
MODE=1
#directory to which the files will be moved
DIR_COMP=/mnt/disco/amule/completos
#DTIME parts: time and its unit
TIME=$(echo $DTIME | cut -d ' ' -f1)
TUNIT=$(echo $DTIME | cut -d ' ' -f2)
#Time to share in seconds
TIMESH=86400

function mv_completed() {

#difference between sharing time and active download time
DIFFT=$(($TIMESH - $1))

if [ $DIFFT -gt 0 ]

then

	sleep $DIFFT; mv $FILE $DIR_COMP
	amulecmd -c "reload shared" && echo "reload shared" >> /home/dietpi/.aMule/fecha_movido

else

	mv $FILE $DIR_COMP
	amulecmd -c "reload shared" && echo "reload shared" >> /home/dietpi/.aMule/fecha_movido

fi


}

#function that converts DTIME to seconds
function to_seconds() {

case $1 in

"s")

echo $TIME

;;
"minutos")

echo $(echo $DTIME | awk -F: '{ print ($1 * 60) + $2}')

;;
"horas")

echo $(echo $DTIME | awk -F: '{ print ($1 * 3600) + ($2 * 60)}')

;;
"Días")

#days to seconds
TIMED=$(echo $DTIME | cut -d ' ' -f1)
SECD=$(($TIMED * 86400))

#second part of DTIME
#time unit: hours, minutes, seconds 
TUNIT2=$(echo $DTIME | cut -d ' ' -f4)
#time
DTIME=$(echo $DTIME | cut -d ' ' -f3,4)
#to seconds
SECD2=$(to_seconds $TUNIT2)

echo $(($SECD + $SECD2))

;;

*)

exit 1

;;

esac

}

SEC=$(to_seconds $TUNIT)

if [[ $MODE -eq 1 ]]; then

	#time remaining
	mv_completed $SEC

else

	#fixed time
	mv_completed 0

fi
