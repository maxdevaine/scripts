#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2025/08
# license: GNU GPLv3
# description: parse html web page to check current version of Helios CLA IQ product, notify via email in case of new version

STATFILE=/home/version-check/scripts/tmp/ncentral-curver
CURVER=`cat ${STATFILE}`
CONTACT=`head -1 /home/version-check/scripts/_contact`
BASESTRING=`wget -qO- --no-check-certificate https://documentation.n-able.com/N-central/Release_Notes/GA/Content/n-c-release-notes-home.htm | grep Release_Notes.htm | grep -E -io 'href="[^\"]+"' | awk -F\" '{print$2}'`
NEWVER=`echo $BASESTRING |cut -d _ -f 2`

if [ "$CURVER" != "$NEWVER" ]; then
     echo "Je nová verze N-Central : ""$NEWVER"" !!!"
     echo -e "Je nová verze N-Central : $CURVER/$NEWVER \n https://documentation.n-able.com/N-central/Release_Notes/GA/Content/${BASESTRING}" | mail -s "N-Central new version : $NEWVER" ${CONTACT}
     echo "$NEWVER" > ${STATFILE}
  else
     echo "Verze $CURVER je aktuální"
fi
