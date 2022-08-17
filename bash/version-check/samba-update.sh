#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2019/06
# license: GNU GPLv3
# description: parse html web page to check actual version of Samba, notify via email in case of new version

STATFILE=/home/version-check/scripts/tmp/samba4-curver
CONTACT=`head -1 /home/version-check/scripts/_contact`
CURVER=`cat ${STATFILE}`
NEWVER=`wget -qO- "https://wiki.samba.org/index.php/Samba_Features_added/changed_(by_release)" |grep "\"tocnumber\">1.1<" |tr -s "<" "\n" |grep toctext | awk '{print $3}'`


if [ "$CURVER" != "$NEWVER" ]; then
    echo "Je nová verze Samba4 ""$NEWVER"" !!!"
    echo -e "Je nová verze Samba4 : ""$NEWVER""\n https://wiki.samba.org/index.php/Samba_Features_added/changed_(by_release)" | mail -s "Samba4 new version : $NEWVER" ${CONTACT}
    echo "$NEWVER" > ${STATFILE}
  else
    echo "Verze $CURVER je aktuální."
fi
