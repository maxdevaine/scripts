#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2024/03
# license: GNU GPLv3
# description: Download exports in files from Vema Cloud (it's used xfer service) and make history/archive of downloaded files

# vema companies numbers
COMPANY1=11111
COMPANY1DIR=/opt/hr-sync/vema-company1/
COMPANY2=22222
COMPANY2DIR=/opt/hr-sync/vema-company2/
COMPANY3=33333
COMPANY3DIR=/opt/hr-sync/vema-company3/



# set variable
SCRIPT=`realpath $0`
SCRIPTDIR=$(dirname "$SCRIPT")
DATADIR=${SCRIPTDIR}/datarx
LOGDIR=${SCRIPTDIR}/logs
TMPDIR=${SCRIPTDIR}/tmp
LIST=${TMPDIR}/list
WSURL=https://xfer.cloud.vema.cz/
SHAREDKEY=supersecretkey
CURDATE=`date '+%Y-%m-%d-%H'`
ARCHIVEDIR=${SCRIPTDIR}/datarx.archive

# get a list of files in to tmp list file
curl -k -F key=${SHAREDKEY} ${WSURL}list.php > ${LIST}

# download all files from the list in to datarx directory
cd ${DATADIR}
while read i; do
  curl -k -OJ -F key=${SHAREDKEY} -F filename=${i} ${WSURL}/fetch.php
done < ${LIST}
chmod -R 600 ${DATADIR}
cd ${SCRIPTDIR}

# move exported files to specific directories for MidPoint
find ${DATADIR} -name "*${COMPANY1}*" -exec cp -t ${COMPANY1DIR} {} +
find ${DATADIR} -name "*${COMPANY2}*" -exec cp -t ${COMPANY2DIR} {} +
find ${DATADIR} -name "*${COMPANY3}*" -exec cp -t ${COMPANY3DIR} {} +

chown -R midpoint ${COMPANY1DIR}
chown -R midpoint ${COMPANY2DIR}
chown -R midpoint ${COMPANY3DIR}

# make archive, check directory
if [ ! -d "${ARCHIVEDIR}/${CURDATE}" ]; then
   mkdir ${ARCHIVEDIR}/${CURDATE}
fi

# make archive, move all files
mv ${DATADIR}/* ${ARCHIVEDIR}/${CURDATE}/
mv ${LIST} ${ARCHIVEDIR}/${CURDATE}/

# clear old archives
find ${ARCHIVEDIR}/* -type d -ctime +30 -exec rm -rf {} \;
