#!/bin/bash

if [ ! -d hue_state ]
then
	mkdir hue_state
fi


# try and remember the state of the hue lights .. and then restore it next time you turn then on via the power switch
# only tested in cygwin 
# GoW doesn't include perl...  and the Strawberry free perl for windows doesn't like the syntax used...

#uncomment if you need logging while running the service
#exec > /tmp/huemem.log

# import my hue bash library
source hue_bashlibrary.sh


# CONFIGURATION
# -----------------------------------------------------------------------------------------

# Mind the gap: do not change the names of these variables, the bash_library needs those...

ip='192.168.1.27'						# IP of hue bridge
devicetype='raspberry'						# Link with bridge: type of device
username='huelibrary'						# Link with bridge: username / app name
loglevel=0							# 0 all logging off, # 1 gossip, # 2 verbose, # 3 errors
delay=2

#work out how many lights there are
LIGHTS=`curl -s -H "Content-Type: application/json" "http://$ip/api/$username/lights/" | tr "{" "\n" | grep modelid | wc -l`
echo LIGHTS=$LIGHTS
lights=`seq 1 $LIGHTS`
echo lights=$lights

#restore saved state from last time this ran (powerloss, etc...)
for j in hue_state/*
do
	LINE=`cat $j`
	echo $j $LINE
	i=`echo $LINE | awk '{ print $1 }'`
	bri=`echo $LINE | awk '{ print $2 }'`
	sat=`echo $LINE | awk '{ print $3 }'`
	hue=`echo $LINE | awk '{ print $4 }'`
	hue_on_hue_sat_brightness $hue $sat $bri $i
done

while true
do
	echo start of loop
	for i in $lights
	do
		#echo i=$i
		REACHABLE=$(hue_is_reachable $i)
		#echo REACHABLE=$REACHABLE
		#if the light has been given power or had power taken away
		if [ "${LASTSTATE[$i]}" != "$REACHABLE" ]
		then
			echo STATE CHANGED $i
			if [ "$REACHABLE" -eq "1" ]
			then
				if [ "${hue[$i]}" != "" ]
				then
					hue_on_hue_sat_brightness ${hue[$i]} ${sat[$i]} ${bri[$i]} $i
				fi
			fi
			LASTSTATE[$i]=$REACHABLE
		fi

		#if the light has power
		if [ "$REACHABLE" -eq "1" ]
		then
			hue_get_brightness $i
			hue_get_saturation $i
			hue_get_hue $i
			#hue_get_ct $i
			IGNORE=0
			if [ "$result_hue_get_brightness" = "254" ]
			then
				if [ "$result_hue_get_saturation" = "144" ]
				then
					if [ "$result_hue_get_hue" = "14910" ]
					then
						hue_on_hue_sat_brightness ${hue[$i]} ${sat[$i]} ${bri[$i]} $i
						IGNORE=1
					fi
				fi
			fi
			if [ "$IGNORE" = "0" ]
			then
				bri[$i]=$result_hue_get_brightness
				sat[$i]=$result_hue_get_saturation
				hue[$i]=$result_hue_get_hue
				#ct[$i]=$result_hue_get_ct
				echo bri/sat/hue $i ${bri[$i]} ${sat[$i]} ${hue[$i]}
				/bin/echo -n $i ${bri[$i]} ${sat[$i]} ${hue[$i]} > hue_state/$i
				#echo ct $i ${ct[$i]}
			fi
		fi
	done
	echo sleeping
	sleep $delay
	echo
done
