#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/08
# license: GNU GPLv3
# description: parse html web page to check current version of Helios CLA IQ product, notify via email in case of new version

CONTACT=`head -1 /home/version-check/scripts/_contact`
STATFILE=/home/version-check/scripts/tmp/helios-curver
CURVER=`cat ${STATFILE}`
ROK=$(date '+%Y')
NEWVER=`wget -qO- https://public.helios.eu/inuvio/doc/cs/index.php?title=Kategorie:Zm%C4%9Bny_dle_verze_${ROK} |cat |grep "Verze_" |grep "<td><a href=" |tr -s "<a>" "\n" |sed -n '4p'`

CHANGELOG="https://public.helios.eu/inuvio/doc/cs/index.php?title=Verze_${NEWVER}_-_Zm%C4%9Bny_${ROK}"
URLVERS="https://public.helios.eu/inuvio/doc/cs/index.php?title=Kategorie:Zm%C4%9Bny_dle_verze_${ROK}"

if [ "$CURVER" != "$NEWVER" ]; then
    echo "Je nová verze Helios ""$NEWVER"" !!!"
    echo -e "Je nová verze Helios : ""$NEWVER""\n""$CHANGELOG""\n\n""Změny dle verze $ROK:""\n""$URLVERS"" " | mail -s "Helios CLA/IQ new version : $NEWVER" ${CONTACT}
    echo "$NEWVER" > ${STATFILE}
  else
    echo "Není nová verze, stále je aktuální ${CURVER}"
fi
