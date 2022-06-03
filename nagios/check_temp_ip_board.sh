#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/01
# license: GNU GPLv3
#
# nagios module for IP Smart Board device: http://www.mikrovlny.cz/cz/produkt/64
# - SNMP is unstable, this is implementatio via web: http://${HOSTNAME}/status.xml
# 
# This defines if you want to trigger a critical alert if the checked
# 0 = NO NOTIFICATION; 3 = UNKNOWN; 2 = CRITICAL

STATE_OK=0
STATE_CRITICAL=2
STATE_UNKNOWN=3
UNIT=C

# Set help
print_help () {
        echo ""
        echo "Usage: check_temp_ip_board.sh -H <hostname> -s <sensor> -l <larger> -m <minor>"
        echo ""
        echo "Temp is ok, if is temp large than 12 celsia and smaller than 35 celsia"
        echo "check_temp_ip_board.sh -H 192.168.1.1 -s temp -l 12 -m 35"
        echo ""
        echo "This plugin checks temp and humidity for specific hostname/ip based on Arduiono http web server"
        echo ""
        exit 0
}

# Read input
case "$1" in

        --help)
                print_help
                exit $STATE_OK
                ;;
        -h)
                print_help
                exit $STATE_OK
                ;;
esac

HOSTNAME=$2
SENSOR=$4
LARGE=$6
SMALLER=$8
NUMBER='^[0-9]+$'



### Testing parameters :

if ! [[ $LARGE =~ $NUMBER ]]; then
  echo "Large : $LARGE is not number !!!"
exit $STATE_UNKNOWN
fi

if ! [[ $SMALLER =~ $NUMBER ]]; then
  echo "Smaller : $SMALLER is not number !!!"
exit $STATE_UNKNOWN
fi

if [[ $SMALLER -le $LARGE ]]; then
  echo "Smaller: $SMALLER cant be <= than Large: $LARGE !!!"
exit $STATE_UNKNOWN
fi

if [ $SENSOR == temp ]; then
SNR=Temperature
fi


### Main ###

if [ $LARGE ] && [ $SMALLER ] && [ $HOSTNAME ] && [ $SENSOR ]; then

  TEMPREAL=`curl -s http://${HOSTNAME}/status.xml |grep -oP '(?<=<temp1>).*?(?=</temp1>)'`
  TEMP=`echo $TEMPREAL |cut -f1 -d"."`

   if [ $SENSOR == temp ]; then
     if [ $TEMP -ge $LARGE ] && [ $TEMP -le $SMALLER ]; then
       STATE=0
       VAL=$TEMPREAL
      else
       STATE=2
       VAL=$TEMPREAL
     fi
   fi

else
 echo $HOSTNAME $SENSOR $LARGE $SMALLER
 STATE=$STATE_UNKNOWN
fi


### Notification ###

if [ $VAL ]; then
  if [ $STATE -eq  $STATE_OK ]; then
    echo "OK: The $SNR is ${VAL} ${UNIT} | $SNR=${VAL}${UNIT};$LARGE;$SMALLER;0;0"
  exit $STATE_OK

  elif [ $STATE -eq  $STATE_CRITICAL ]; then
     echo "Critical: The $SNR is ${VAL} ${UNIT} | $SNR=${VAL}${UNIT};$LARGE;$SMALLER;0;0"
  exit $STATE_CRITICAL
  elif [ $STATE -eq  $STATE_UNKNOWN ]; then
     echo "Unknown | $SNR state is unknown"
  exit $STATE_UNKNOWN
 fi

else
  echo "Someone value not defined"
exit $STATE_UNKNOWN
fi




# In case we received a wrong syntax, do the following
if [ $STATE -eq $STATE_UNKNOWN ]; then
        echo "Error: Please check your syntax!"
        echo "Use 'check_temp_humi --help' for help!"
        exit $STATE_UNKNOWN
fi
