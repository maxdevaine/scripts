#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/08
# license: GNU GPLv3
# description: parse html web page to check actual version of Alvao product, notify via email in case of new version

CONTACT=`head -1 /home/version-check/scripts/_contact`
STATFILE=/home/version-check/scripts/tmp/alvao-curver
CURVER=`cat ${STATFILE}`
CURURL=`wget -qO- https://www.alvao.com/en/download grep "<a href=" |grep "www.alvao.com/en/download" |grep btn-primary |awk '{print $6}' | cut -d'"' -f 2`
NEWVER=`wget -qO- ${CURURL} |grep "Version:" |tr -s "<strong>" "\n" | tac | sed -n '3p'`
MAJORVER=`echo ${NEWVER} |awk '{print $1}'`
CHANGELOG="https://doc.alvao.com/en/${MAJORVER}/release-notes/updates"
KNOWISSUE="https://doc.alvao.com/en/${MAJORVER}/known-issues"

if [ "$CURVER" != "$NEWVER" ]; then
    echo "Je nová verze Alvao ""$NEWVER"" !!!"
    echo -e "Je nová verze Alvao: ""${NEWVER}""\n""${CURURL}""\n""Changelog:\n${CHANGELOG}""\n""Know issue:\n${KNOWISSUE}"" " | mail -s "Alvao new version: $NEWVER" ${CONTACT}
    echo "$NEWVER" > ${STATFILE}
  else
    echo "Není nová verze, stále je aktuální ${CURVER}"
fi
