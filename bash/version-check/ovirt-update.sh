#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2019/06
# license: GNU GPLv3
# description: parse html web page to check actual version of the oVirt, notify via email in case of new version

STATFILE=/home/version-check/scripts/tmp/ovirt-curver
CURVER=`cat ${STATFILE}`
CONTACT=`head -1 /home/version-check/scripts/_contact`
#CURVER="4.3.3"
#NEWVER=`wget -qO- http://www.ovirt.org/Home |cat |grep "Released" |tr -s "<span>" "\n" |sed -n '9p' |sed 's/^.......//' |tr -s " " "\n" |sed -n '1p'`
#NEWVER=`wget -qO- http://www.ovirt.org |cat |grep "Get started with oVirt" |tr -s "<p>" "\n" |sed -n '5p' | awk '{print $5}'`
#NEWVER=`wget -qO- https://www.ovirt.org/release/ |cat |grep "Release" |cut -c23-27 |tail -n 1`
NEWVER=`wget -qO- https://www.ovirt.org |cat |grep "Release Notes" | cut -c43-47`

if [ "$CURVER" != "$NEWVER" ]; then
     echo "Je nová verze oVirt : ""$NEWVER"" !!!"
     echo "Je nová verze oVirt : $CURVER/$NEWVER" | mail -s "oVirt new version : $NEWVER" ${CONTACT}
     echo "$NEWVER" > ${STATFILE}
  else
     echo "Verze $CURVER je aktuální"
fi
