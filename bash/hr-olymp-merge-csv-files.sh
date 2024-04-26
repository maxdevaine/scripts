#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2024/04
# license: GNU GPLv3
# description: Download csv exports from multiple Olymp HR and make history/archive of downloaded files, modify csv files and merge all to the new one

# set variable
SCRIPT=`realpath $0`
SCRIPTDIR=$(dirname "$SCRIPT")
LOGDIR=${SCRIPTDIR}/logs
TMPDIR=${SCRIPTDIR}/tmp
SHAREDIR=${SCRIPTDIR}/share
CURDATE=`date '+%Y-%m-%d-%H'`
ARCHIVEDIR=${SCRIPTDIR}/archive
MIDPOINTDIR=/opt/hr-sync/olymp-sk/
CONTACT=no-reply@domain.tld
FSTAB=`cat /etc/fstab |grep ${SHAREDIR}`
COMPLETEFILE=${TMPDIR}/olymp-merge-$(date '+%Y-%m-%d-%H%M%S').csv

# check if is share mapped
if [ ! -d "${SHAREDIR}/DUST" ]; then
   echo "ERROR: Share is not mapped, ending..."
   echo -e "IDM Olymp Script: Error - share with csv files is not mapped\nServer: $(hostname)\nShare path:\n${FSTAB}" | mail -s "IDM error: SK share is not mapped" ${CONTACT}
   exit 0
fi

# set last file in to variable
METSKFILE=$(ls -t ${SHAREDIR}/DUST | head -n1)
MTRSKFILE=$(ls -t ${SHAREDIR}/MTRS | head -n1)
TIPZAFILE=$(ls -t ${SHAREDIR}/TIPZA | head -n1)

# add prefix to all csv files (because possible personal numbers collision)
sed -e '2,$ s_.*_DUST&_' ${SHAREDIR}/DUST/${METSKFILE} > ${TMPDIR}/${METSKFILE}
sed -e '2,$ s_.*_MTRS&_' ${SHAREDIR}/MTRS/${MTRSKFILE} > ${TMPDIR}/${MTRSKFILE}
sed -e '2,$ s_.*_TIPZA&_' ${SHAREDIR}/TIPZA/${TIPZAFILE} > ${TMPDIR}/${TIPZAFILE}

# modify column names in METSK csv file
sed -e '1s/Osobné číslo/OsobneCislo/'  -e '1s/Priezvisko/Priezvisko/' -e '1s/Meno/Meno/' -e '1s/Pracovný pomer/PracovnyPomer/' -e '1s/Typ pracovníka/TypPracovnika/' -e '1s/ Pracovná pozícia/PracovnaPozicia/' -e '1s/Začiatok PP/ZaciatokPP/' ->

# cut column names from other csv files and merge it to the final file
sed -e '1d' ${TMPDIR}/${MTRSKFILE} >> ${COMPLETEFILE}
sed -e '1d' ${TMPDIR}/${TIPZAFILE} >> ${COMPLETEFILE}

# copy new csv file to MidPoint directory
yes | cp -rf ${COMPLETEFILE} ${MIDPOINTDIR}/olymp-merge.csv
chown -R midpoint ${MIDPOINTDIR}

# make archive, check directory
if [ ! -d "${ARCHIVEDIR}/${CURDATE}" ]; then
   mkdir ${ARCHIVEDIR}/${CURDATE}
fi

# make archive, move all files
mv -f ${TMPDIR}/* ${ARCHIVEDIR}/${CURDATE}/

# clear old archives
find ${ARCHIVEDIR}/* -type d -ctime +30 -exec rm -rf {} \;
find ${SHAREDIR}/* -type f -ctime +7 -exec rm -rf {} \;
