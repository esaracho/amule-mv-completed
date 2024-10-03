#!/bin/bash

#set -e

###Parameters
#name of the downloaded file with full path 
FILE=$1
#total time the download was active 
DTIME=$2
echo $DTIME >> /home/dietpi/.aMule/mv.log

###Working mode
#1 for rest (time to share - active download time), any other integer for fixed (fixed time to share)
MODE=1

###Directory to which the files will be moved
DIR_COMP="/mnt/disco/amule/completos"

###DTIME unit (days, hours, minutes, seconds)
TUNIT=$(echo $DTIME | cut -d ' ' -f2)

###Time to share in minutes
TIMESH=1440

function mv_completed() {

	###Difference between sharing time and active download time
	DIFFT=$(($TIMESH - $1))
	echo $DIFFT >> /home/dietpi/.aMule/mv.log

	if [ $DIFFT -gt 0 ]

		then

			echo "mv $(printf '%q' "$FILE") $DIR_COMP; amulecmd -c \"reload shared\"" | at now +$DIFFT minutes

		else

			mv $(printf '%q' "$FILE") $DIR_COMP; amulecmd -c "reload shared"

	fi

}

###Function that converts DTIME to minutes

function to_minutes() {

	case $1 in

		"s")

		echo 1
		;;

	"minutos")

		echo $(echo $DTIME | awk -F: '{ print $1}')
		;;

	"horas")

		echo $(echo $DTIME | awk -F: '{ print ($1 * 60) + $2}')
		;;

	"Días")

		#days to minutes
		TIMED=$(echo $DTIME | cut -d ' ' -f1)
		MIND=$(($TIMED * 1440))

		#second part of DTIME
		#time unit: hours, minutes, seconds 
		TUNIT2=$(echo $DTIME | cut -d ' ' -f4)
		#time
		DTIME=$(echo $DTIME | cut -d ' ' -f3,4)
		#to minutes
		MIND2=$(to_minutes $TUNIT2)

		echo $(($MIND + $MIND2))
		;;

	*)

		exit 1
		;;

	esac

}

###Main

#convert DTIME to minutes
MIN=$(to_minutes $TUNIT)
echo $MIN >> /home/dietpi/.aMule/mv.log

#is executed according to the working mode

if [[ $MODE -eq 1 ]]; then

	#time remaining
	mv_completed $MIN

else

	#fixed time
	mv_completed $TIMESH

fi
