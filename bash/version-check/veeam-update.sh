#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2023/08
# license: GNU GPLv3
# description: parse html web page to check current version of Helios CLA IQ product, notify via email in case of new version

CONTACT=`head -1 /home/version-check/scripts/_contact`
STATFILE=/home/version-check/scripts/tmp/veeam-curver
CURVER=`cat ${STATFILE}`
URLVERS="https://www.veeam.com/kb2680"
NEWVER=`wget -qO- ${URLVERS} |grep "<td>Veeam Backup" |tr -s "<\tr>" "\n" | grep "Veeam Backup" | head -1 | awk '{print $5}'`


if [ "$CURVER" != "$NEWVER" ]; then
    echo "Je nová verze Veeam: ""$NEWVER"" !!!"
    echo -e "New version of Veeam:\n ""$NEWVER""\n""See KB:""\n""$URLVERS"" " | mail -s "${NEWVER}" ${CONTACT}
    echo "$NEWVER" > ${STATFILE}
  else
    echo "Není nová verze, stále je aktuální ${CURVER}"
fi
